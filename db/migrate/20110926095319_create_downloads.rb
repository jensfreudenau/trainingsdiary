class CreateDownloads < ActiveRecord::Migration
  def self.up
    create_table :downloads do |t|
      t.string :name
      t.string :file
      t.text :comment
      t.references :sport
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :downloads
  end
end
