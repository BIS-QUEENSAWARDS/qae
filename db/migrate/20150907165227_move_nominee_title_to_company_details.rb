class MoveNomineeTitleToCompanyDetails < ActiveRecord::Migration[4.2]
  def change
    remove_column :form_answers, :nominee_title, :string
    add_column :company_details, :nominee_title, :string
  end
end
