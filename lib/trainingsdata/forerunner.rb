module Trainingsdata
  class Forerunner  < Trainingsdata::Base
    attr_accessor :rounds, :time_total, :distance_total, :speed_max, :calories, :heartrate_avg, :heartrate_max, :start_time, :course
    
    def initialize (path, new = false)
      @path = path
      @log = Logger.new('log/fore_runner.log')
      
      if (new == false) 
        self.open_file        
        @source_doc = Nokogiri::XML.parse(@file) { |cfg| cfg.noblanks }
      else 
        self.create_file
      end
      @rounds         = Hash.new
      @heartrate_max  = 0
      @heartrate_avg  = 0
      @speed_max      = 0
      @time_total     = 0
      @distance_total = 0
      @calories       = 0
      @start_time     = 0
      @course         = ''
    end
    
    def start_import
      self.generate_laps
      self.save_file_data
      self.cleanup
    end
    
    def create_trainings_file(deg, training)
      @deg        = deg
      @training   = training
      name        = "Steigerwald"
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
                
                if (index > 0 )                
                  
                  @prev_lat = @deg[index-1][0]
                  @prev_lon = @deg[index-1][1]
                  self.calculate_distance
                  self.calculate_time
                  
                else
                  @time = @training.start_time
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
      @log.debug(@time)
      @time = @time+10
      @log.debug(@time)
      
    end
    def calculate_distance 
      first_loc=LatLng.new(@prev_lat, @prev_lon)
      second_loc=LatLng.new(@lat,@lon)
      @distance = first_loc.distance_to(second_loc, :units=>:kms)
    end
    
    
    def generate_course
      @source_doc.root.children.children.children.each do |node|    
        @log.debug(node.name.to_yaml)
        if node.name.to_s == 'Track'   
          @log.debug(node.text.to_yaml)
          node.children.children.each do |sub_node|
            @log.debug(sub_node.to_yaml)
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
      counter = 0
      round = 0
      trackpoint = 0
      @source_doc.root.children.children.children.each do |node|
        if node.name == 'Lap'          
          counter +=1
          round +=1
          if counter == 1
            @start_time = node["StartTime"].to_s
          end
          round = counter.to_i
          round -=1

          @rounds[round]||= {}
          @rounds[round][:lap_start_time] = node["StartTime"].to_s				  

          node.children.each do |main_sub_node|

            if main_sub_node.name == 'MaximumHeartRateBpm'
              @rounds[round] ||= {}
              @rounds[round][:heartrate_max] = main_sub_node.children[0].text.to_i
              if @heartrate_max < main_sub_node.children[0].text.to_i
                @heartrate_max = main_sub_node.children[0].text.to_i
              end
            end

            if main_sub_node.name == 'AverageHeartRateBpm'
              @rounds[round] ||= {}
              @rounds[round][:heartrate_avg] = main_sub_node.children[0].text.to_i
              @heartrate_avg = main_sub_node.children[0].text.to_i
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
              @rounds[round][:speed_max_lap] = main_sub_node.text.to_f
              if @speed_max < main_sub_node.text.to_f
                @speed_max += main_sub_node.text.to_f
              end
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

                  @rounds[round][:laps][trackpoint.to_i] ||= {}
                  @rounds[round][:laps][trackpoint.to_i][:latitude_degrees]	= working_node.children[0].text.to_f
                  @rounds[round][:laps][trackpoint.to_i][:longitude_degrees]	= working_node.children[1].text.to_f
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
                  @rounds[round][:laps][trackpoint.to_i][:heart_rate_bpm] = working_node.children[0].text.to_i
                end
                if working_node.name == 'AltitudeMeters'
                  @rounds[round][:laps][trackpoint.to_i] ||= {}
                  @rounds[round][:laps][trackpoint.to_i][:height] = working_node.children[0].text.to_f
                end                
              end                
            end              
          end            
        end            
      end
    end
  end
end