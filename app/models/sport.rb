class Sport < ActiveRecord::Base
  has_many :trainings
  has_many :downloads
  belongs_to :user
  default_scope :order => 'sort_order' 
  scope :unorder,  order('sort_order DESC')
  
  def self.get_sports_by_user (user_id)
      return Sport.find(
                            :all,
                            :select => 'id, name',
                            :conditions => {:user_id => user_id}
                          )
    end
end
