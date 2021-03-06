class FormAnswerPolicy < ApplicationPolicy
  def index?
    admin? || assessor?
  end

  def review?
    return true if admin?
    subject.lead_or_assigned?(record)
  end

  def show?
    admin? || assessor?
  end

  def update?
    admin? || subject.lead?(record)
  end

  def update_financials?
    true
  end

  def assign_assessor?
    admin? || subject.lead?(record)
  end

  def toggle_admin_flag?
    admin?
  end

  def toggle_assessor_flag?
    admin? || subject.lead_or_assigned?(record)
  end

  def download_feedback_pdf?
    admin? && record.submitted? && record.feedback.present?
  end

  def download_case_summary_pdf?
    admin? && record.submitted? && record.lead_or_primary_assessor_assignments.any?
  end

  def download_audit_certificate_pdf?
    (admin? || subject.lead_or_assigned?(record)) &&
    record.audit_certificate.present? &&
    record.audit_certificate.attachment.present? &&
    record.audit_certificate.scan.present? &&
    record.audit_certificate.scan.clean?
  end

  def has_access_to_post_shortlisting_docs?
    download_feedback_pdf? ||
    download_case_summary_pdf? ||
    download_audit_certificate_pdf?
  end
end
