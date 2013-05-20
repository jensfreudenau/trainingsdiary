require 'json'
require 'net/http'
module Trainingsdata 
  class Base       
    attr_accessor :map_data, :heartrate, :height, :laps, :file, :avg_heartrate
    def initialize
      @log = Logger.new('log/base.log')

    end
    #
    # loads the main data into a new hash
    #
    def load_lap_data (index)
      
      @laps[index] ||= {}
      @laps[index][:duration]           = @runner[index][:seconds_total]
      @laps[index][:distance]           = @runner[index][:distance_lap]
      @laps[index][:heartrate_avg]      = @runner[index][:heartrate_avg]
      @laps[index][:heartrate_max]      = @runner[index][:heartrate_max]
      @laps[index][:calories]           = @runner[index][:calories]
      @laps[index][:start_time]         = @runner[index][:lap_start_time]
      @laps[index][:maximum_speed]      = @runner[index][:maximum_speed]
      @laps[index][:height]             = @lap_single_height
      @laps[index][:heartrate]          = @lap_single_heartrate
      @laps[index][:map]                = @lap_single_map
      @diagramm << @runner[index][:laps].sort

    end
    
    #
    # saves the data of the file
    # 
    #  
    def save_file_data
      @log.debug('base save_file_data')
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

      @diagramm.each_with_index do |data, data_index|
        self.load_track_data(data, data_index)

        map             << @lap_map
        local_heartrate << @lap_heartrate
        local_height    << @lap_height
      end
      @laps           = @laps.sort
      @lap_calories   = self.calories
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
    def load_track_data (data, data_index)
      
      @lap_map              = []
      @lap_single_heartrate[data_index]  ||= {}
      @lap_single_map[data_index]        ||= {}
      @lap_single_height[data_index]     ||= {}
      @lap_heartrate        = []
      @lap_height           = []
      @lap_time             = []

      data.each do |v|
        v.each do |value|
          if (value.kind_of? Hash)
            
            @height     = value[:altitude]
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
            elsif @timepoint.to_i >= 0
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
      @lap_single_height[data_index]    = @lap_height

      @lap_single_heartrate[data_index] = @lap_heartrate
      @lap_single_map[data_index]       = @lap_map
    end
    
    ##
    # open an existing file
    ##    
    def open_file
      #uri = URI(@path)
      #@file = Net::HTTP.get(uri)
      #@path ="/Users/jensfreudenau/Development/trainingsdiary/public/uploads/tmp/klein.TCX"
      @file = File.new(@path, "r")
      @log.debug('@file')
      @log.debug(@file)
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

    def calculate_avg_heartrate (distance_total)
      calc_heartrate_sum = 1
      res = 1
      begin
        @distances.each_with_index do |value, index|

          if (@heartrate_avg[index.to_i].nil?)
            @heartrate_avg[index.to_i] = 1
          end
          if (@distances[index.to_i] == 0.0)
            @distances[index.to_i] = 1.0
          end
          if @heartrate_avg[index.to_i] && !@heartrate_avg[index.to_i].nil?

            calc_heartrate_sum += @distances[index.to_i] * @heartrate_avg[index.to_i]
          end
        end
        res = calc_heartrate_sum/distance_total
      end
      return res
    end
  end #class
   
end #module
