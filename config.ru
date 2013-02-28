# This file is used by Rack-based servers to start the application.
ENV['GEM_HOME'] = '/home/www/trainings/vendor/ruby/1.8/gems'  
ENV['GEM_PATH'] = '/home/www/trainings/vendor/ruby/1.8/gems:/usr/lib/ruby/gems/1.8'  
require 'rubygems'  
Gem.clear_paths
require ::File.expand_path('../config/environment',  __FILE__)
run Trainings1::Application
