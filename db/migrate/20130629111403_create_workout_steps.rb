class CreateWorkoutSteps < ActiveRecord::Migration
  def change
    create_table :workout_steps do |t|
      t.integer :user_id
      t.string :name
      t.string :duration
      t.string :intensity
      t.string :target
      t.date :scheduled_on
      t.text :notes

      t.timestamps
    end
  end
end
