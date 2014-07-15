class AddTimeInMoveToTraining < ActiveRecord::Migration
  def change
    add_column :trainings, :time_in_move, :float
  end
end
