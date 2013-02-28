require 'json'
require 'zip/zip'
module Trainingsdata 
  class Base       
    attr_accessor :map_data, :heartrate, :height, :laps, :file
    include GeoKit
    #      @log = Logger.new('log/base.log')
        
         
    #
    # loads the main data into a new has
    #
    def load_lap_data (index)
      
      @laps[index] ||= {}
      @laps[index][:duration]          = @runner[index.to_i][:seconds_total]
      @laps[index][:distance]          = @runner[index.to_i][:distance_lap]
      @laps[index][:heartrate_avg]     = @runner[index.to_i][:heartrate_avg]
      @laps[index][:heartrate_max]     = @runner[index.to_i][:heartrate_max]
      @laps[index][:calories]          = @runner[index.to_i][:calories]
      @laps[index][:start_time]        = @runner[index.to_i][:lap_start_time]
      @diagramm << @runner[index.to_i][:laps].sort
      
    end
    
    #
    # saves the data of the file
    # 
    #  
    def save_file_data

      @laps             = Hash.new
      @diagramm         = []
      @file             = '' 
      @runner           = self.rounds
      @timepoint        = ''
      map               = []
      local_heartrate   = []
      local_height      = [] 
      
      @runner.each_with_index do |value, index|
        self.load_lap_data(index)
      end

      f = @diagramm.sort
      f.each do |data|
        self.load_track_data(data)
        map << @lap_map
        local_heartrate << @lap_heartrate
        local_height << @lap_height
      end
      @laps = @laps.sort 
      @distance_total = self.distance_total
      @time_total     = self.time_total
      @start_time     = self.start_time
      
      @map_data       = map.to_json
      @heartrate      = local_heartrate.to_json
      @height         = local_height.to_json
    end
     
    
    ##
    # loads the tracking data
    # for map and height diagram
    # :attr_accessor data
    ##    
    def load_track_data (data)
      
      @lap_map        = []
      @lap_heartrate  = []
      @lap_height     = []
      @lap_time       = []
      
      data.each do |v|
        v.each do |value|
          if (value.kind_of? Hash)
            
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
      end
    end
    
    ##
    # open an existing file
    ##    
    def open_file     
      @file = File.open(@path, "r")
    end
    
    ##
    # creates a new file
    ##
    def create_file
      @file = File.new(@path+'.tcx', "w")
    end
    
    
    ##
    # compress the file
    # and deletes the old one
    ##
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
    
  end #class
   
end #module
