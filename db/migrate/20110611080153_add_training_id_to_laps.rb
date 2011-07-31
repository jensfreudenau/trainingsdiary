class AddTrainingIdToLaps < ActiveRecord::Migration
  def self.up
    add_column :laps, :training_id, :integer
  end

  def self.down
    remove_column :laps, :training_id
  end
end
