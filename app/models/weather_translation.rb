class WeatherTranslation < ActiveRecord::Base
  #has_one    :training
  belongs_to :weather
end
