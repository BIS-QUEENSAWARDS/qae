class EmailNotification < ActiveRecord::Base
  extend Enumerize
  include FormattedTime::DateTimeFor

  date_time_for :trigger_at

  belongs_to :settings

  enumerize :kind, in: [
                         :reminder_to_submit,
                         :ep_reminder_support_letters,
                         :winners_notification,
                         :winners_press_release_comments_request,
                         :unsuccessful_notification,
                         :all_unsuccessful_feedback,
                         :shortlisted_notifier,
                         :shortlisted_audit_certificate_reminder,
                         :not_shortlisted_notifier
                       ]

  validates :kind, :trigger_at, presence: true

  after_save :clear_cache
  after_destroy :clear_cache

  scope :current, -> { where("trigger_at < ?", Time.now.utc).where("sent = 'f' OR sent IS NULL") }

  def self.not_shortlisted
    where(kind: "not_shortlisted_notifier")
  end

  def self.not_awarded
    where(kind: "unsuccessful_notification")
  end

  private

  def clear_cache
    Rails.cache.clear("current_settings")
    Rails.cache.clear("current_award_year")
    Rails.cache.clear("#{kind.value}_notification")
  end
end
