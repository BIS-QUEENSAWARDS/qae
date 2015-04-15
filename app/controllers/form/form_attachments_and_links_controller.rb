class Form::FormAttachmentsAndLinksController < Form::BaseController

  # This controller handles saving of attachments and website links
  # This section is used in case if JS disabled

  def index
    @form_link = FormLink.new
    @form_answer_attachment = current_user.form_answer_attachments.new(
      form_answer: @form_answer
    )
    @existing_materials = JSON.parse(@form_answer.document["innovation_materials"])
  end

  def create
  end

  def destroy
  end

  private

    def attachment_params
      params.require(:attachment).permit(
        :description
      )
    end

    def link_params
      params.require(:form_link).permit(
        :link,
        :description
      )
    end
end
