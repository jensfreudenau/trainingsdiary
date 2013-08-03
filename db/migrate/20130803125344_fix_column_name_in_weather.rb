class FixColumnNameInWeather < ActiveRecord::Migration
  def up
    rename_column :weathers, :weather_id, :weather
    change_column(:weathers , :weather, :string)
  end

  def down
  end
end
