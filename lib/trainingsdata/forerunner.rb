require 'yaml'
module Trainingsdata
  class Forerunner  < Trainingsdata::Base
    attr_accessor :xml, :rounds, :time_total,
                  :distance_total, :speed_max,
                  :calories, :heartrate_avg, :heartrate_max,
                  :start_time, :course, :sport,
                  :lap_single_map, :lap_single_heartrate, :lap_single_height, :source_doc
    
    def initialize
      @log = Logger.new('log/fore_runner.log')
      @lap_single_map       = Array.new
      @lap_single_heartrate = Array.new
      @lap_single_height    = Array.new

      #if (new == false)
      #  self.open_file
      #  @source_doc = Nokogiri::XML.parse(@file) { |cfg| cfg.noblanks }

      #elsif (ajax == true)
      #
      #
      #
      #
      #else
      #  self.create_file
      #end

      @rounds               = Hash.new


      @heartrate_max  = 0
      @xml            = ''
      @heartrate_avg  = 0
      @speed_max      = 0
      @time_total     = 0
      @distance_total = 0
      @calories       = 0
      @start_time     = 0
      @course         = ''
      @distance       = 0
      @deg            = ''
      @training       = ''
      @time           = ''
      @prev_lat       = ''
      @prev_lon       = ''
      @running_total  = 0
      @sport          = ''
      @source_doc     = ''
    end
    
    def start_import(file_or_xml = 'xml')
      if file_or_xml == 'file'
        @file       = File.new(@xml, "r")
        @source_doc = Nokogiri::XML.parse(@file) { |cfg| cfg.noblanks }

      elsif file_or_xml=='xml'
        #garmin
        @source_doc = Nokogiri::XML(@xml)
      end

      self.generate_laps
      self.save_file_data
      #self.cleanup
    end
    
    def create_trainings_file(deg, training, name)
      @deg        = deg
      @training   = training
      begin_lat   = @deg.first[0]
      begin_lon   = @deg.first[1]
      end_lat     = @deg.last[0]
      end_lon     = @deg.last[1]     
      
      xm = Builder::XmlMarkup.new(:indent=>2,:target => @file)
      xm.instruct!
      xm.TrainingCenterDatabase(:xmlns =>"http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2",
        'xmlns:xsi' =>"http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' =>"http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd") {                       

        xm.Folders {                     
          xm.Courses {
            xm.CourseFolder(:Name=>"Trainingsdiary"){
              xm.CourseNameRef {
                xm.Id(name)
              }
            }
          }
        }                             
        xm.Courses {                     
          xm.Course {
            xm.Name(name)
                    
            xm.Lap{
              xm.TotalTimeSeconds(@training.time_total)
              xm.DistanceMeters(@training.distance_total)
              xm.BeginPosition{
                xm.LatitudeDegrees(begin_lat)
                xm.LongitudeDegrees(begin_lon)
              }
              xm.EndPosition{
                xm.LatitudeDegrees(end_lat)
                xm.LongitudeDegrees(end_lon)
              }
              xm.Intensity("Active")
            }
            xm.Track {
              @deg.each_with_index do |item, index| 
                
                @lat = item[0] 
                @lon = item[1]
                @time = @training.start_time
                if (index > 0 )                
                  
                  @prev_lat = @deg[index-1][0]
                  @prev_lon = @deg[index-1][1]
                  self.calculate_distance
                  self.calculate_time
                  
                else
                  
                  @prev_lat = begin_lat
                  @prev_lon = begin_lon
                  self.calculate_distance
                end
                
                xm.Trackpoint {
                  xm.Time(@time.to_formatted_s(:en28601))
                  xm.DistanceMeters(@distance)
                  xm.AltitudeMeters(250)
                  xm.Position {
                    xm.LatitudeDegrees(@lat)
                    xm.LongitudeDegrees(@lon)
                  }
                }
              end
            }
          }  
        }                             
      }  
      @file.close
    end
  
    def calculate_time 
      # s = 10m * 1000 / 4min * 60 s = 10 m * 30(km/h) * 1000 / 3600 sec
      # 
      
      t = @time.to_i
      @time = @time+10
      
      
    end


    def calculate_distance 
      begin
        first_loc = LatLng.new(@prev_lat, @prev_lon)
        second_loc= LatLng.new(@lat,@lon)
        @distance = first_loc.distance_to(second_loc, :units=>:kms)
      rescue
        @distance = 0
      end
    end
    
    
    def generate_course
      @source_doc.root.children.children.children.each do |node|    
        
        if node.name.to_s == 'Track'   
          
          node.children.children.each do |sub_node|
             
            if sub_node.name == 'Position'
              @course += '[' + sub_node.children[0].text.to_s + ',' + sub_node.children[1].text.to_s + '],'
            end
          end          
        end
      end    
      
      @course = '[[' + @course.chomp(',') + ']]'
    end

    protected
    
    def generate_laps
      @log.debug('generate_laps')
      counter = 0
      round = 0
      trackpoint = 0

      @source_doc.root.children.children.each do |activity|

        #activity["Sport"].to_s
        if activity.name == 'Activity'
          @sport = activity['Sport'].to_s

        end
      end

      @source_doc.root.children.children.children.each do |node|

        if node.name == 'Lap'
          counter +=1
          round +=1
          if counter == 1
            @start_time = node['StartTime'].to_s
          end
          round = counter.to_i
          round -=1

          @rounds[round]||= {}
          @rounds[round][:lap_start_time] = node['StartTime'].to_s
          
          node.children.each do |main_sub_node|

            if main_sub_node.name == 'MaximumHeartRateBpm'
              @rounds[round] ||= {}
              @rounds[round][:heartrate_max] = main_sub_node.children.text.to_i
              if @heartrate_max < main_sub_node.children.text.to_i
                @heartrate_max = main_sub_node.children.text.to_i
              end
            end

            if main_sub_node.name == 'AverageHeartRateBpm'
              @rounds[round] ||= {}
              @rounds[round][:heartrate_avg] = main_sub_node.children.text.to_i
              @heartrate_avg = main_sub_node.children.text.to_i
            end
            if main_sub_node.name == 'TotalTimeSeconds'
              @rounds[round] ||= {}
              @rounds[round][:seconds_total] = main_sub_node.text.to_f
              @time_total += main_sub_node.text.to_f
            end
            
            if main_sub_node.name == 'DistanceMeters'
              @rounds[round] ||= {}
              @rounds[round][:distance_lap] = main_sub_node.text.to_f
              @distance_total += main_sub_node.text.to_f
            end


            if main_sub_node.name == 'MaximumSpeed'
              @rounds[round] ||= {}
              @rounds[round][:maximum_speed] = main_sub_node.text.to_f
            end
            if main_sub_node.name == 'Calories'
              @rounds[round] ||= {}
              @rounds[round][:calories] = main_sub_node.text.to_i
              @calories += main_sub_node.text.to_i
            end
          end
            
          node.children.children.each do |sub_node|
              
            if sub_node.name == 'Trackpoint'
              trackpoint +=1  
              @rounds[round][:laps] ||= {}
              sub_node.children.each do |working_node|
                if working_node.name == 'Time'
                  @rounds[round][:laps][trackpoint.to_i] ||= {}
                  @rounds[round][:laps][trackpoint.to_i][:time] = working_node.inner_text.to_s 
               
                end
                 
                if working_node.name == 'Position' && !working_node.children[0].text.to_s.nil? &&  !working_node.children[1].text.nil? 
                  working_node.children.each do |sub_sub_node|
                    @rounds[round][:laps][trackpoint.to_i] ||= {}

                    if sub_sub_node.name == 'LatitudeDegrees'
                        @rounds[round][:laps][trackpoint.to_i][:latitude_degrees] = sub_sub_node.text.to_f
                    end

                    if sub_sub_node.name == 'LongitudeDegrees'
                      @rounds[round][:laps][trackpoint.to_i][:longitude_degrees]  = sub_sub_node.text.to_f
                    end
                      
                      
                     #if sub_sub_node.name == 'LatitudeDegrees'
                     #   @rounds[round][:laps][trackpoint.to_i][:latitude_degrees]=sub_sub_node.text.to_f
                     #end
                     # if sub_sub_node.name == 'LongitudeDegrees'
                     #   @rounds[round][:laps][trackpoint.to_i][:longitude_degrees]=sub_sub_node.text.to_f
                     # end
                  end
                  
                  #@rounds[round][:laps][trackpoint.to_i][:latitude_degrees]	= working_node.children[1].text.to_f
                  #@rounds[round][:laps][trackpoint.to_i][:longitude_degrees]	= working_node.children[2].text.to_f
                end
                if working_node.name == 'AltitudeMeters'
                  @rounds[round][:laps][trackpoint.to_i] ||= {}
                  @rounds[round][:laps][trackpoint.to_i][:altitude] = working_node.inner_text.to_f
                end				

                if working_node.name == 'DistanceMeters'
                  @rounds[round][:laps][trackpoint.to_i] ||= {}
                  @rounds[round][:laps][trackpoint.to_i][:distance] = working_node.inner_text.to_f
                end
                if working_node.name == 'HeartRateBpm'
                  @rounds[round][:laps][trackpoint.to_i] ||= {}
                  @rounds[round][:laps][trackpoint.to_i][:heart_rate_bpm] = working_node.children.text.to_i
                end

              end
            end              
          end            
        end            
      end
    end
  end #class
end #module