class SportLevel < ActiveRecord::Base
  has_many :trainings
  belongs_to :user  
  default_scope :order => 'sort'   
end
