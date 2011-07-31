class AddStartTimeToLap < ActiveRecord::Migration
  def self.up
    add_column :laps, :start_time, :datetime
  end

  def self.down
    remove_column :laps, :start_time
  end
end
