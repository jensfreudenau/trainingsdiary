class AddScheduledOnToWorkout < ActiveRecord::Migration
  def change
    add_column :workouts, :scheduled_on, :date
  end
end
