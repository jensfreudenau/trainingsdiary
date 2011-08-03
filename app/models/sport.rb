class Sport < ActiveRecord::Base
  has_many :trainings
  belongs_to :user
  scope :order,  order('sort_order')
  scope :unorder,  order('sort_order DESC')
end
