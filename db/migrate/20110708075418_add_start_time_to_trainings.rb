class AddStartTimeToTrainings < ActiveRecord::Migration
  def self.up
    add_column :trainings, :start_time, :datetime
  end

  def self.down
    remove_column :trainings, :start_time
  end
end
