require 'qae_2014_forms'

class FormAnswer < ActiveRecord::Base
  include PgSearch
  extend Enumerize
  include FormAnswerStatesHelper

  has_paper_trail

  attr_accessor :current_step, :validator_errors, :steps_with_errors

  pg_search_scope :basic_search,
                  against: [
                    :urn,
                    :award_type_full_name,
                    :company_or_nominee_name,
                    :nominee_full_name,
                    :user_full_name
                  ],
                  using: {
                    tsearch: {
                      prefix: true
                    }
                  }

  POSSIBLE_AWARDS = [
    "trade", # International Trade Award
    "innovation", # Innovation Award
    "development", # Sustainable Development Award
    "promotion" # Enterprise Promotion Award
  ]

  AWARD_TYPE_FULL_NAMES = {
    "trade" => "International Trade",
    "innovation" => "Innovation",
    "development" => "Sustainable Development",
    "promotion" => "Enterprise Promotion"
  }

  enumerize :award_type, in: POSSIBLE_AWARDS, predicates: true

  begin :associations
    belongs_to :user
    belongs_to :account
    belongs_to :award_year
    belongs_to :company_details_editable, polymorphic: true

    has_one :form_basic_eligibility, class_name: 'Eligibility::Basic', dependent: :destroy
    has_one :trade_eligibility, class_name: 'Eligibility::Trade', dependent: :destroy
    has_one :innovation_eligibility, class_name: 'Eligibility::Innovation', dependent: :destroy
    has_one :development_eligibility, class_name: 'Eligibility::Development', dependent: :destroy
    has_one :promotion_eligibility, class_name: 'Eligibility::Promotion', dependent: :destroy
    has_one :audit_certificate, dependent: :destroy
    has_one :feedback, dependent: :destroy
    has_one :press_summary, dependent: :destroy
    has_one :draft_note, as: :notable, dependent: :destroy
    has_one :company_detail, dependent: :destroy
    has_one :palace_invite, dependent: :destroy
    has_one :form_answer_progress, dependent: :destroy

    belongs_to :primary_assessor, class_name: "Assessor", foreign_key: :primary_assessor_id
    belongs_to :secondary_assessor, class_name: "Assessor", foreign_key: :secondary_assessor_id
    has_many :form_answer_attachments, dependent: :destroy
    has_many :support_letter_attachments, dependent: :destroy

    has_many :supporters, dependent: :destroy, autosave: true
    has_many :support_letters, dependent: :destroy
    has_many :comments, as: :commentable, dependent: :destroy
    has_many :form_answer_transitions
    has_many :assessor_assignments, dependent: :destroy
    has_many :lead_or_primary_assessor_assignments,
             -> { where.not(submitted_at: nil)
                       .where(position: [3, 4])
                       .order(position: :desc) },
             class_name: "AssessorAssignment",
             foreign_key: :form_answer_id
    has_many :previous_wins, dependent: :destroy
    has_many :assessors, through: :assessor_assignments do
      def primary
        where(assessor_assignments:
          {
            position: 0
          }
        ).first
      end

      def secondary
        where(assessor_assignments:
          {
            position: 1
          }
        ).first
      end
    end
  end

  begin :validations
    validates :user, presence: true
    validates :award_type, presence: true,
                           inclusion: {
                             in: POSSIBLE_AWARDS
                           }
    validates_uniqueness_of :urn, allow_nil: true, allow_blank: true
    validates :sic_code, format: { with: SICCode::REGEX }, allow_nil: true
    validate :validate_answers
  end

  begin :scopes
    scope :for_award_type, -> (award_type) { where(award_type: award_type) }
    scope :for_year, -> (year) { joins(:award_year).where(award_years: { year: year }) }
    scope :shortlisted, -> { where(state: %w(reserved recommended)) }
    scope :not_shortlisted, -> { where(state: "not_recommended") }
    scope :winners, -> { where(state: %(recomended awarded)) }
    scope :unsuccessful, -> { where(state: %w(not_recommended not_awarded reserved)) }
    scope :submitted, -> { where(submitted: true) }
    scope :business, -> { where(award_type: %w(trade innovation development)) }
    scope :promotion, -> { where(award_type: "promotion") }
  end

  begin :callbacks
    before_save :set_award_year, unless: :award_year
    before_save :set_urn
    before_save :set_progress
    before_save :assign_searching_attributes

    before_create :set_account
    before_create :set_user_full_name
  end

  store_accessor :document
  store_accessor :financial_data

  begin :state_machine
    delegate :current_state, :trigger!, :available_events, to: :state_machine
    delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
      to: :state_machine

    def state_machine
      @state_machine ||= FormAnswerStateMachine.new(self, transition_class: FormAnswerTransition)
    end
  end

  accepts_nested_attributes_for :previous_wins,
                                allow_destroy: true,
                                reject_if: proc { |attrs|
                                  attrs[:year].blank? && attrs[:category].blank?
                                }

  def award_form
    QAE2014Forms.public_send(award_type) if award_type.present?
  end

  def eligibility
    public_send("#{award_type}_eligibility")
  end

  def eligibility_class
    "Eligibility::#{award_type.capitalize}".constantize
  end

  def eligible?
    eligibility && eligibility.eligible? && (promotion? || (form_basic_eligibility && form_basic_eligibility.eligible?))
  end

  def document
    super || {}
  end

  def head_of_business
    head_of_business = document["head_of_business_first_name"].to_s
    head_of_business += " "
    head_of_business += document["head_of_business_last_name"].to_s
  end

  def company_or_nominee_from_document
    comp_attr = promotion? ? 'organization_name' : 'company_name'
    name = document[comp_attr]
    name = nominee_full_name_from_document if promotion? && name.blank?
    name = name.try(:strip)
    name.presence
  end

  def fill_progress_in_percents
    ((fill_progress || 0) * 100).round.to_s + "%"
  end

  def performance_years
    case award_type
    when "innovation"
      document["innovation_performance_years"]
    end
  end

  private

  def nominee_full_name_from_document
    "#{document['nominee_info_first_name']} #{document['nominee_info_last_name']}".strip
  end

  def set_urn
    builder = UrnBuilder.new(self)
    builder.assign
  end

  def set_account
    self.account = user.account
  end

  def set_award_year
    self.award_year = AwardYear.current
  end

  def set_progress
    form = award_form.decorate(answers: HashWithIndifferentAccess.new(document || {}))
    self.fill_progress = form.progress

    unless new_record?
      progress = (form_answer_progress || build_form_answer_progress)
      progress.assign_sections(form)
      progress.save
    end
    true
  end

  def assign_searching_attributes
    unless submitted_and_after_the_deadline?
      self.company_or_nominee_name = company_or_nominee_from_document
    end
    self.nominee_full_name = nominee_full_name_from_document
    self.award_type_full_name = AWARD_TYPE_FULL_NAMES[award_type]
  end

  def set_user_full_name
    self.user_full_name ||= user.full_name if user.present?
  end

  def validate_answers
    if submitted && (current_step || submitted_changed?)
      validator = FormAnswerValidator.new(self)

      unless validator.valid?
        errors.add(:base, "Answers invalid")
        self.validator_errors = validator.errors
      end
    end
  end
end
