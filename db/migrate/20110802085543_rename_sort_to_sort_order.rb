class RenameSortToSortOrder < ActiveRecord::Migration
  def self.up
    rename_column :sports, :sort, :sort_order
  end

  def self.down
    rename_column :sports, :sort_order, :sort
  end
end
