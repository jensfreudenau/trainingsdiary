class AddUserIdToWorkout < ActiveRecord::Migration
  def change
    add_column :workouts, :user_id, :integer
  end

  def down
    remove_column :workouts, :user_id
  end
end
