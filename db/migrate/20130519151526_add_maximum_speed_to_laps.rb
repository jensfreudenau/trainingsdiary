class AddMaximumSpeedToLaps < ActiveRecord::Migration
  def change
    add_column :laps, :maximum_speed, :float
  end

  def down
    remove_column :laps, :maximum_speed
  end
end
