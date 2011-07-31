class Lap < ActiveRecord::Base
  belongs_to :training
  default_scope :order => 'start_time'  
end
