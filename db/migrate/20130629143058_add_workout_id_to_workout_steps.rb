class AddWorkoutIdToWorkoutSteps < ActiveRecord::Migration
  def change
    add_column :workout_steps, :workout_id, :integer
  end
end
