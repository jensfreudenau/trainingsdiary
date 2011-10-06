# Load the rails application
require File.expand_path('../application', __FILE__)

@download_path = Rails.root+'public/uploads/download/file/'

# Initialize the rails application
Trainings1::Application.initialize!

Haml::Template.options[:format] = :xhtml


