#! /usr/bin/env ruby

require "rubygems"
require "nokogiri"

xml = <<-EOXML
<TrainingCenterDatabase xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd">
               <Id>2011-04-29T15:29:42Z</Id> 
</TrainingCenterDatabase>
EOXML

doc = Nokogiri::XML xml
puts doc
puts "---"
doc.remove_namespaces!
puts doc