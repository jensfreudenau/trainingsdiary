class CreateWeathers < ActiveRecord::Migration
  def change
    create_table :weathers do |t|
      t.references :training
      t.integer :weather_id
      t.float :temp
      t.string :icon
      t.float :wind_speed
      t.integer :wind_deg
      t.integer :humidity

      t.timestamps
    end
    add_index :weathers, :training_id
  end
end
