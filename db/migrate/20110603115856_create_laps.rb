class CreateLaps < ActiveRecord::Migration
  def self.up
    create_table :laps do |t|
      t.integer :trainings_id
      t.float :distance_total
      t.float :heartrate_max
      t.float :calories
      t.integer :heartrate_avg
      t.float :duration
      t.timestamps
    end
  end

  def self.down
    drop_table :laps
  end
end
