class AddSortToSportLevel < ActiveRecord::Migration
  def self.up
    add_column :sport_levels, :sort, :integer
  end

  def self.down
    remove_column :sport_levels, :sort
  end
end
