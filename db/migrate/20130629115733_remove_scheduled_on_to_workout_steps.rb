class RemoveScheduledOnToWorkoutSteps < ActiveRecord::Migration
  def up
    remove_column :workout_steps, :scheduled_on
  end

  def down
    add_column :workout_steps, :scheduled_on, :date
  end
end
