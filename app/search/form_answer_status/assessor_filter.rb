class FormAnswerStatus::AssessorFilter
  extend FormAnswerStatus::FilteringHelper

  OPTIONS = {
    application_in_progress: {
      label: "Application in progress",
      states: [:application_in_progress]
    },
    assessment_in_progress: {
      label: "Assessment in progress",
      states: [:assessment_in_progress]
    },
    recommended: {
      label: "Recommended",
      states: [:recommended]
    },
    not_recommended: {
      label: "Not Recommended",
      states: [:not_recommended]
    },
    reserved: {
      label: "Reserved",
      states: [:reserved]
    },
    withdrawn: {
      label: "Withdrawn",
      states: [:withdrawn]
    },
    submitted: {
      label: "Submitted",
      states: [:submitted]
    },
    awarded: {
      label: "Awarded",
      states: [:awarded]
    },
    not_awarded: {
      label: "Not Awarded",
      states: [:not_awarded]
    }
  }

  SUB_OPTIONS = {
    missing_sic_code: {
      label: "Missing SIC code"
    },
    assessors_not_assigned: {
      label: "Assessors not assigned"
    },
    missing_audit_certificate: {
      label: "Missing Audit Certificate"
    },
    missing_feedback: {
      label: "Missing Feedback"
    },
    missing_press_summary: {
      label: "Missing Press Summary"
    }
  }

  def self.options
    OPTIONS
  end

  def self.sub_options
    SUB_OPTIONS
  end
end
