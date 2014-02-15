# Load the rails application
require File.expand_path('../application', __FILE__)

@download_path = Rails.root+'public/uploads/download/file/'

# Initialize the rails application
Trainingsdiary::Application.initialize!

Haml::Template.options[:format] = :xhtml
require "will_paginate"
require 'logger'
API = '2d6eb9cf703ffda7c25ee3ec1e9f845b'
CLOUDMADE_API = '68ee3ca235dd4e4f973298bc343e9b73'



