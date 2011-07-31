class AddCommentToTrainings < ActiveRecord::Migration
  def self.up
    add_column :trainings, :comment, :text
  end

  def self.down
    remove_column :trainings, :comment
  end
end
