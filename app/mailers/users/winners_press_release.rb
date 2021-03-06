class Users::WinnersPressRelease < AccountMailer
  def notify(form_answer_id)
    @form_answer = FormAnswer.find(form_answer_id).decorate
    @user = @form_answer.user.decorate

    email = if @form_answer.promotion?
      @form_answer.document["nominee_email"]
    else
      @user.email
    end

    @deadline = Settings.current.deadlines.where(kind: "press_release_comments").first
    @deadline = @deadline.trigger_at.strftime("%d/%m/%Y")

    @token = @form_answer.press_summary.token
    @subject = "[Queen's Awards for Enterprise] Press Comment"

    mail to: email, subject: @subject
  end
end
