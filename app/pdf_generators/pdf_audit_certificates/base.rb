class PdfAuditCertificates::Base < AuditCertificatePdf
  private

  def initialize_form_answer(form)
    if notification = form.award_year.settings.email_notifications.where(kind: "shortlisted_notifier").order(:trigger_at).first
      form.version_at(notification.trigger_at).decorate
    else
      super
    end
  end
end
