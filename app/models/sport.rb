class Sport < ActiveRecord::Base
  has_many :trainings
  belongs_to :user
  default_scope :order => 'sort'
  
  #:conditions => ["user_id = ?", current_user ]
end
