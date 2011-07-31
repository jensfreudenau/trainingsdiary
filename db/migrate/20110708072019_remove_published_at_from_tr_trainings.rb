class RemovePublishedAtFromTrTrainings < ActiveRecord::Migration
  def self.up
    remove_column :trainings, :published_at
  end

  def self.down
    add_column :trainings, :published_at, :timestamp
  end
end
