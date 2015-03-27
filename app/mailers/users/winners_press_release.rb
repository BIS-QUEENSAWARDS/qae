class Users::WinnersPressRelease < ApplicationMailer
  def notify(form_answer_id)
    @form_answer = FormAnswer.find(form_answer_id).decorate
    @user = @form_answer.user.decorate
    @token = @form_answer.press_summary.token
    @subject = "[Queen's Awards for Enterprise] Press Comment"

    mail to: @user.email, subject: @subject
  end
end