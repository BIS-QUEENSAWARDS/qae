class AddSubmittedAtToAssessorAssignments < ActiveRecord::Migration
  def change
    add_column :assessor_assignments, :submitted_at, :datetime
  end
end
