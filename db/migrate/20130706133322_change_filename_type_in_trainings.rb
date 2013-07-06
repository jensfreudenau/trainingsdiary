class ChangeFilenameTypeInTrainings < ActiveRecord::Migration
  def up
    change_column(:trainings , :filename, :text)
  end

  def down
    change_column(:trainings , :filename, :string)
  end
end
