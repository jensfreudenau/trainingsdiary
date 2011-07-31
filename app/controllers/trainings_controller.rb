
require 'rexml/document'
require 'lib/forerunner'
require 'json'
require 'chronic_duration'
require "FileUtils"

class TrainingsController < ApplicationController
    #	include Devise::Controllers::Helpers
    before_filter :authenticate_user!, :except => [:index, :show]
    load_and_authorize_resource
    
    def index
      #files = Dir.glob("public/tracks/uploader/*.TCX", File::FNM_CASEFOLD)
      #for file in @files 
      #  self.batch(file)
      #end
        #@log = Logger.new('log/trainings.log')
        items_per_page = 5

        sort = case params['sort']
        when "name"  then "name"
        when "sportlevel"   then "sport_levels.name"
        when "sports.name" then "sports.name"
        when "start_time"  then "start_time ASC"
        when "time_total"   then "time_total ASC"
        when "distance" then "distance_total"
        else 
            "trainings.start_time DESC"
        end

        trainings = Training.find(
            :all,
            :conditions => ['trainings.user_id = ?', current_user ],
            :select => 'trainings.id,
                        trainings.comment,
                        trainings.start_time as start_time,
                        trainings.map_data,
                        trainings.distance_total,
                        trainings.time_total,
                        course_names.name as coursename,
                        sport_levels.name as sportlevel,
                        sport_levels.css as css,
                        start_time,                        
                        sports.name as sportname',
            :order => sort,
            :joins => [:sport_level, :sport, :course_name]
        )
        @trainings = trainings.paginate:page => params[:page], :per_page => items_per_page        
        respond_to do |format|
            format.html # index.html.erb
            format.xml  { render :xml => @trainings }
        end

    end

    # GET /trainings/1
    # GET /trainings/1.xml
    def show
        @training = Training.find(:all, 
            :select => '    
                    trainings.id,
                    trainings.map_data,
                    trainings.heartrate,
                    trainings.time_total,  
                    trainings.comment,                      
                    trainings.start_time as start_time,
                    trainings.distance_total as distance_total,
                    course_names.name as coursename,
                    sport_levels.name as sportlevel,
                    sports.name as sportname
            ',
            :joins => [ :course_name, :sport, :sport_level] ,
            :conditions => ['trainings.user_id = ? AND trainings.id = ?', current_user , params[:id]])
        @laps = Lap.find(
            :all,
            :conditions => ['training_id = ?', params[:id]]
        )    
                            
        respond_to do |format|
            format.html # show.html.erb
            format.xml  { render :xml => @training }
        end
    end

    # GET /trainings/new
    # GET /trainings/new.xml
    def new
        @training = current_user.trainings.new
       
        @sportlevel = SportLevel.find(
            :all,
            :select => 'id, name',
            :conditions => {:user_id => current_user.id}
        )
        @sport = Sport.find(
            :all,
            :select => 'id, name',
            :conditions => {:user_id => current_user.id}
        )
        @coursename = CourseName.find(
            :all,
            :select => 'id, name',
            :conditions => {:user_id => current_user.id}
        )
        respond_to do |format|
            format.html # new.html.erb
            format.xml  { render :xml => @training }
        end
    end

    # GET /trainings/1/edit
    def edit
        @training = Training.find(:first,
            :conditions => {:user_id => current_user.id , :id => params[:id]},
            :select => 'id,
                        user_id,
                        start_time,
                        sport_level_id,
                        course_name_id,
                        sport_id,
                        comment,
                        time_total,
                        distance_total'
                        )
                       
        @sportlevel = SportLevel.find(
            :all,
            :select => 'id, name',
            :conditions => {:user_id => current_user.id}
        )
        @sport = Sport.find(
            :all,
            :select => 'id, name',
            :conditions => {:user_id => current_user.id}
        )
        @coursename = CourseName.find(
            :all,
            :select => 'id, name',			
            :conditions => {:user_id => current_user.id}
        )
    end

    # POST /trainings
    # POST /trainings.xml
    def create
        #params[:training][:user_id] = current_user.id
        Training.mounting
        file_data = params[:training][:filename]
        if params[:training][:start_time].empty?
            params[:training][:start_time] = Time.now.to_s(:db)
        end
        @sportlevel = SportLevel.find(
            :all,
            :select => 'id, name',
            :conditions => {:user_id => current_user.id}
        )
        @sport = Sport.find(
            :all,
            :select => 'id, name',
            :conditions => {:user_id => current_user.id}
        )
        @coursename = CourseName.find(
            :all,
            :select => 'id, name',
            :conditions => {:user_id => current_user.id}
        )
        @training = current_user.trainings.new(params[:training])

        respond_to do |format|
          if @training.update_attributes(params[:training])
            if file_data
                path = "public/uploads/training/filename/#{@training.user_id}/#{@training.id}/#{file_data.original_filename.to_s}"
                f = File.open(path, "r")
                begin
                    save_file_data(f)
                end
            end
            if @training.save
              format.html { redirect_to(trainings_url, :notice => 'Training was successfully updated.') }
              format.xml  { head :ok }
            else
              format.html { render :action => "new" }
              format.xml  { render :xml => @training.errors, :status => :unprocessable_entity }
            end  
          end
        end
    end
    
    # PUT /trainings/1
    # PUT /trainings/1.xml#
    def update
        params[:training][:user_id] = current_user.id
        Training.mounting
        file_data = params[:training][:filename]
        params[:training][:time_total] = ChronicDuration.parse(params[:training][:time_total].to_s)
        if params[:training][:start_time].nil?
            params[:training][:start_time] = Time.now.to_s(:db)
        end
        @training = Training.find(params[:id])

        respond_to do |format|

            if @training.update_attributes(params[:training])
                if file_data
                    path = "public/uploads/training/filename/#{@training.user_id}/#{@training.id}/#{file_data.original_filename.to_s}"
                    f = File.open(path, "r")				
                    begin				  
                        save_file_data(f)
                    end
                end
                if @training.save
                  format.html { redirect_to(trainings_url, :notice => 'Training was successfully updated.') }
                  format.xml  { head :ok }
                else
                  format.html { render :action => "edit" }
                  format.xml  { render :xml => @training.errors, :status => :unprocessable_entity }
                end
            end
        end
    end
    
    # DELETE /trainings/1
    # DELETE /trainings/1.xml
    def destroy
        @training = Training.find(params[:id])

        @training.destroy
        respond_to do |format|
            format.html { redirect_to(trainings_url, :notice => 'Training was successfully deleted.') }
            format.xml  { head :ok }
            format.js
        end
    end
  
    protected
    
    def batch (file)
      f = File.open(file, "r")
      @training = current_user.trainings.new()
      @training.user_id = 1
      @training.sport_id = 1
      @training.sport_level_id = 1
      @training.course_name_id = 2
      @training.filename = File.basename(file).to_s
      @training_orl = Training.find(:first,
          :conditions => {:user_id => @training.user_id , :filename => @training.filename},
          :select => 'id')
     
      if @training_orl.nil?
        @training.save
        
        FileUtils.mv file, "public/tracks/uploader/ok/"+File.basename(file).to_s
        begin
          
          self::save_file_data(f)
          @training.save
        end
      end
    end

    def add_attachment
        # get file name
        file_name = params[:qqfile]
        # get file content type
        att_content_type = (request.content_type.to_s == "") ? "application/octet-stream" : request.content_type.to_s
        # create temporal file
        file = Tempfile.new(file_name)
        # put data into this file from raw post request
        file.print request.raw_post

        # create several required methods for this temporal file
        Tempfile.send(:define_method, "content_type") {return att_content_type}
        Tempfile.send(:define_method, "original_filename") {return file_name}

        # save file into attachment
        attach = Attachment.new(:uploaded_data => file)
        attach.person_id = params[:person_id]
        attach.save!

        respond_to do |format|
            format.json{render(:layout => false , :json => {"success" => true, "data" => attach}.to_json )}
            format.html{render(:layout => false , :json => attach.to_json )}
        end
        rescue Exception => err
        respond_to do |format|
            format.json{render(:layout => false , :json => {"error" => err.to_s}.to_json )}
        end
    end

    def save_file_data(f)
        fr = Forerunner.new(f)
        
        @fore_runner = fr.rounds.to_a.sort_by {|key|key}   
        @timepoint = ''
        map = []
        heartrate = []
        height = []
       
        @training.distance_total = fr.distance_total
        @training.time_total = fr.time_total
        @training.start_time = fr.start_time
        
        @fore_runner.each do |round, value|  
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
                if v.type.to_s == "Hash" && lap.to_s == 'laps'                    
                    load_track_data(v.to_a.sort)                    
                end
            end	
            @training.laps.create(
                :distance_total => @distance,
                :heartrate_avg => @heartrate_avg,
                :calories => @calories,
                :heartrate_max => @heartrate_max,
                :duration => @seconds,
                :heartrate => @lap_heartrate.to_json,
                :height => @lap_height.to_json,
                :map => @lap_map.to_json
            )
            map << @lap_map
            heartrate << @lap_heartrate
            height << @lap_height
        end
        @training.map_data = map.to_json
        @training.heartrate = heartrate.to_json
        @training.height = height.to_json
    end
    
    def load_track_data (data)
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
end
