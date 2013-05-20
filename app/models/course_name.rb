class CourseName < ActiveRecord::Base
	has_many :trainings
	belongs_to :user
	default_scope :order => 'sort'
  validates :name, :presence => true
  
  def self.get_coursename_by_user (user_id)
      return CourseName.select('id, name').where('user_id = ?', user_id).all
  end
  def self.get_last_coursename_by_user (user_id)
    return CourseName.select('id, name').where('user_id = ?', user_id).order('sort DESC').first
  end
end
