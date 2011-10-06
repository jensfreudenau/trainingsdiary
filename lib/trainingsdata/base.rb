require 'json'
require 'zip/zip'
module Trainingsdata 
  class Base       
    attr_accessor :map_data, :heartrate, :height, :laps, :file
    include GeoKit
    
    def save_file_data()  
      @file = '' 
      @runner = self.rounds.sort
      @timepoint = ''
      map = []
      local_heartrate = []
      local_height = [] 
      @laps = []
      key = 0
       
      @distance_total = self.distance_total
      
      @time_total = self.time_total
      @start_time = self.start_time
     
      @runner.each do |round, value|
        value.each do |lap, v|
          if lap.to_s == 'seconds_total'
            @seconds = v.to_f
          end
          if lap.to_s == 'distance_lap'
            @distance = v.to_f
          end
        
          if lap.to_s == 'heartrate_avg'
            @heartrate_avg = v.to_f
          end
          if lap.to_s == 'heartrate_max'
            @heartrate_max = v.to_f
          end
          if lap.to_s == 'calories'
            @calories = v.to_f
          end
          if v.kind_of?(Hash) && lap.to_s == 'laps'
            
            load_track_data(v.to_a.sort)
            @laps[key] ||= {}
            @laps[key][:heartrate] = @lap_heartrate
            @laps[key][:height] = @lap_height
            @laps[key][:map] = @lap_map
            @laps[key][:time] = @time
            @laps[key][:distance] = @distance
            @laps[key][:heartrate_avg] = @heartrate_avg
            @laps[key][:heartrate_max] = @heartrate_max
            @laps[key][:calories] = @calories
            @laps[key][:duration] = @seconds
            key +=1
          end
        end
        
        map << @lap_map
        local_heartrate << @lap_heartrate
         
        local_height << @lap_height
        
      end
      
      @map_data = map.to_json
      @heartrate = local_heartrate.to_json
      @height = local_height.to_json
    end
      
    def load_track_data (data)
      @log = Logger.new('log/base.log') 
      @lap_map = []
      @lap_heartrate = []
      @lap_height =  []
      @lap_time = []
      data.each do |index, value|
      
        @height     = value[:height]
        @lat        = value[:latitude_degrees].to_f
        @lon        = value[:longitude_degrees].to_f
        @heartrate  = value[:heart_rate_bpm].to_f
        @time       = value[:time]
      
        if !@lat.to_f.zero? && !@lon.to_f.zero?
          @lap_map << [@lat, @lon]
        end
      
        if @timepoint == '' && !@time.nil?
          @time_prev = Time.parse(@time).to_f
          @timepoint = 0
        elsif @timepoint >= 0
          diff = Time.parse(@time.to_s).to_f - @time_prev
          @timepoint += diff
          @time_prev = Time.parse(@time.to_s).to_f
        end
        @lap_height << [@timepoint, @height]
        if !@heartrate.to_f.zero?
          @lap_heartrate << [@timepoint, @heartrate]
        end
      end      
    end
    
    def open_file     
      @file = File.open(@path, "r")
    end
    
    def create_file
      @file = File.new(@path+'.tcx', "w")
    end
    
    #rdoc
    
    
    def cleanup
      filegz = @path.to_s + '.zip' 
      Zip::ZipFile.open(filegz, Zip::ZipFile::CREATE) do |zipfile|
          zipfile.get_output_stream(@path) do |out_file|
            File.open(@path) do |in_file|
              while blk = in_file.read(1024**2)
                out_file << blk
              end
            end
          end
      end
      if File.exist?(@path)
        File.delete(@path) 
      end    
    end
   end
end
