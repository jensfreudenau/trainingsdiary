class AddCaloriesToTrainings < ActiveRecord::Migration
  def change
    add_column :trainings, :calories, :integer
  end

  def down
    remove_column :trainings, :calories
  end
end
