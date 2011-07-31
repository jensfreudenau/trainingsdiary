class AddFieldsToLaps < ActiveRecord::Migration
  def self.up
    add_column :laps, :heartrate_avg, :integer
    add_column :laps, :duration, :float
  end

  def self.down
    remove_column :laps, :duration
    remove_column :laps, :heartrate_avg
  end
end
