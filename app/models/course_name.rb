class CourseName < ActiveRecord::Base
	has_many :trainings
	belongs_to :user
	default_scope :order => 'sort'
	validates_presence_of :name
end
