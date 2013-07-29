class Weather < ActiveRecord::Base
  has_one :weather_translation
  belongs_to :training
end
