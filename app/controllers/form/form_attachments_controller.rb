class Form::FormAttachmentsController < Form::MaterialsBaseController

  # This controller handles saving of attachments
  # This section is used in case if JS disabled

  expose(:form_answer_attachments) do
    current_user.form_answer_attachments
                .where(form_answer_id: @form_answer.id)
  end

  expose(:form_answer_attachment) do
    current_user.form_answer_attachments.new(
      form_answer_id: @form_answer.id
    )
  end

  expose(:created_attachment_ops) do
    {
      "file" => form_answer_attachment.id.to_s,
      "description" => attachment_params[:description]
    }
  end

  expose(:original_filename) do
    attachment_params[:file].present? ? attachment_params[:file].original_filename : nil
  end

  expose(:add_attachment_result_doc) do
    result_materials = existing_materials
    result_materials[next_document_position.to_s] = created_attachment_ops

    @form_answer.document.merge(
      innovation_materials: result_materials.to_json
    )
  end

  expose(:remove_attachment_result_doc) do
    result_materials = existing_materials
    result_materials.delete_if do |k, v|
      v["file"] == params[:id].to_s
    end
    result_materials = result_materials.present? ? result_materials.to_json : ""

    @form_answer.document.merge(
      innovation_materials: result_materials
    )
  end

  def index
  end

  def new
  end

  def create
    self.form_answer_attachment = current_user.form_answer_attachments.new(
      attachment_params.merge({
        form_answer_id: @form_answer.id,
        non_js_creation: true,
        original_filename: original_filename
      })
    )

    if form_answer_attachment.save
      @form_answer.document = add_attachment_result_doc
      @form_answer.save

      redirect_to form_form_answer_form_attachments_url(@form_answer)
    else
      render :new
    end
  end

  def destroy
    @form_answer.document = remove_attachment_result_doc

    if @form_answer.save
      form_answer_attachment.destroy
    end

    redirect_to form_form_answer_form_attachments_url(@form_answer)
  end

  private

    def attachment_params
      params.require(:form_answer_attachment).permit(
        :file,
        :description
      )
    end
end
