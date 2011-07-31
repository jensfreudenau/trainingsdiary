class AddSortToSports < ActiveRecord::Migration
  def self.up
    add_column :sports, :sort, :integer
  end

  def self.down
    remove_column :sports, :sort
  end
end
