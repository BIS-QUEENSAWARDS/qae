class Reports::CasesStatusReport
  include Reports::CSVHelper

  MAPPING = [
    {
      label: "URN",
      method: :urn
    },
    {
      label: "Category",
      method: :category
    },
    {
      label: "CompanyOrNominee",
      method: :company_or_nominee_name
    },
    {
      label: "FirstAssessor",
      method: :first_assessor
    },
    {
      label: "SecondAssessor",
      method: :second_assessor
    },
    {
      label: "CaseAssigned",
      method: :case_assigned
    },
    {
      label: "FirstAssessmentComplete",
      method: :first_assessment_complete
    },
    {
      label: "SecondAssessmentComplete",
      method: :second_assessment_complete
    },
    {
      label: "MSO_OutcomeAgreed",
      method: :mso_outcome_agreed
    },
    {
      label: "MSO_GradeAgreed",
      method: :mso_grade_agreed
    },
    {
      label: "CaseSummaryOverallGrade",
      method: :case_summary_overall_grade
    },
    {
      label: "PressReleaseUpdated",
      method: :press_release_updated
    },
    {
      label: "ACReceived",
      method: :ac_received
    },
    {
      label: "ACChecked",
      method: :ac_checked
    },
    {
      label: "DCRChecked",
      method: :dcr_checked
    },
    {
      label: "CaseSummaryStatus",
      method: :case_summary_status
    },
    {
      label: "FeedbackComplete",
      method: :feedback_complete
    },
    {
      label: "CaseWithdrawn",
      method: :case_withdrawn
    },
    {
      label: "QAEOPermission",
      method: :qao_permission
    },
    {
      label: "SubCategory",
      method: :sub_category
    }
  ]

  def initialize(year)
    @year = year
  end

  def build
    rows = []

    scope = @year.form_answers.where(submitted: true).order(:id)
    scope.find_in_batches do |batch|
      form_answers = FormAnswer.where(id: batch.map(&:id))
                     .order(:id)
                     .includes(:user,
                               :assessor_assignments,
                               :audit_certificate,
                               :feedback,
                               :primary_assessor,
                               :secondary_assessor
                               )
      form_answers.each do |fa|
        f = Reports::FormAnswer.new(fa)
        rows << mapping.map do |m|
          f.call_method(m[:method])
        end
      end
    end

    as_csv(rows)
  end

  private

  def mapping
    MAPPING
  end
end
