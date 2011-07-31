class AddCssToSportLevel < ActiveRecord::Migration
  def self.up
    add_column :sport_levels, :css, :string
  end

  def self.down
    remove_column :sport_levels, :css
  end
end
