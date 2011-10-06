class Sport < ActiveRecord::Base
  has_many :trainings
  has_many :downloads
  belongs_to :user
  default_scope :order => 'sort_order' 
  scope :unorder,  order('sort_order DESC')
end
