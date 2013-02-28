require 'rexml/document'

require 'json'
require 'chronic_duration'
load "fileutils.rb"

class TrainingsController < ApplicationController
  #	include Devise::Controllers::Helpers
  before_filter :authenticate_user!, :except => [:index, :show]
  load_and_authorize_resource
  include Trainingsdata
  
  def index
    @log = Logger.new('log/trainings.log')
    #@files = Dir.glob("public/tracks/uploader/temp/*.TCX", File::FNM_CASEFOLD)
    #
    #for file in @files
     
     # self.batch(file)
   # end
    #
    items_per_page = 7
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
     
    dir = case params['dir']
            when "asc" then "ASC"
            when "desc" then "DESC"
            else 
            "ASC"
          end
            
    trainings = Training.find(
      :all,
      :conditions => ['trainings.user_id = ?', current_user ],
      :select => 'trainings.id,
                          trainings.comment,
                          trainings.start_time as start_time,
                          trainings.map_data,
                          trainings.heartrate_avg,
                          trainings.heartrate_max,
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

    #trainings = Training.search(current_user.id, params[:start_date], params[:end_date], sort)
    
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
                    trainings.height,
                    trainings.heartrate_avg,
                    trainings.heartrate_max,
                    trainings.time_total,
                    trainings.comment,
                    trainings.start_time as start_time,
                    trainings.distance_total as distance_total,
                    course_names.name as coursename,
                    sport_levels.name as sportlevel,
                    sports.name as sportname',
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
    
    @training   = current_user.trainings.new

    @sportlevel = SportLevel.get_sportlevel_by_user(current_user.id)
    @sport      = Sport.get_sports_by_user(current_user.id)    
    @coursename = CourseName.get_coursename_by_user(current_user.id)
    
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
    
    @sportlevel = SportLevel.get_sportlevel_by_user(current_user.id)
    @sport      = Sport.get_sports_by_user(current_user.id)   
    @coursename = CourseName.get_coursename_by_user(current_user.id)
  end

  # POST /trainings
  # POST /trainings.xml
  def create
    @log = Logger.new('log/trainings.log')
    Training.mounting
    
    if params[:training][:start_time].empty?
      params[:training][:start_time] = Time.now.to_s(:db)
    end
    
    if !params[:training][:time_total].nil?
      params[:training][:time_total] = ChronicDuration::parse((params[:training][:time_total]))
    end
    
    @sportlevel = SportLevel.get_sportlevel_by_user(current_user.id)
    @sport      = Sport.get_sports_by_user(current_user.id)   
    @coursename = CourseName.get_coursename_by_user(current_user.id)
    @training   = current_user.trainings.new(params[:training])
    
    file_data = params[:training][:filename]
    respond_to do |format|
      if @training.update_attributes(params[:training])
        if file_data           
          self.save_file_data(file_data)
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
    
    Training.mounting
    file_data = params[:training][:filename]
    
    
    
    if params[:training][:start_time].nil?
      params[:training][:start_time] = Time.now.to_s(:db)
    end
    
    params[:training][:time_total] = ChronicDuration.parse(params[:training][:time_total].to_s)
    if !params[:training][:time_total].nil?
      params[:training][:time_total] = params[:training][:time_total].to_f
    end
    @training       = Training.find(params[:id])
    @training.user  = current_user
    respond_to do |format|

      if @training.update_attributes(params[:training])
        if file_data
          self.save_file_data(file_data)
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

    def save_file_data(file_data)
      path = "public/uploads/training/filename/#{@training.user_id}/#{@training.id}/#{file_data.original_filename.to_s}"
      begin
        td = Trainingsdata::Forerunner.new(path)
        td.start_import
        
        @distances          = Array.new
        @heartrate_avg      = Array.new
        @calc_heartrate_avg = 0

        td.laps.each do |index, value|

          @distances[index.to_i]      = value[:distance]
          @heartrate_avg[index.to_i]  = value[:heartrate_avg]

          @training.laps.create(
                :distance_total => value[:distance],
                :heartrate_avg  => value[:heartrate_avg],
                :calories       => value[:calories],
                :heartrate_max  => value[:heartrate_max],
                :duration       => value[:duration],
                :heartrate      => value[:heartrate].to_json,
                :height         => value[:height].to_json,
                :map            => value[:map].to_json,
                :start_time     => value[:start_time]
              )
        end  
        
        @training.start_time      = td.start_time
        @training.distance_total  = td.distance_total
        @training.time_total      = td.time_total
        @training.map_data        = td.map_data
        @training.heartrate       = td.heartrate
        @training.height          = td.height
        @training.heartrate_avg   = self.calculate_avg_heartrate(td.distance_total)
        @training.heartrate_max   = td.heartrate_max

      end     
    end

    def calculate_avg_heartrate (distance_total)
      calc_heartrate_sum = 1
      res = 1
      begin
        @distances.each_with_index do |value, index| 
          
          if(@heartrate_avg[index.to_i].nil?) 
            @heartrate_avg[index.to_i] = 1 
          end
          if(@distances[index.to_i] == 0.0) 
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

    def batch (file)
      f = File.open(file, "r")
      @training = current_user.trainings.new()
      @training.user_id = @training.user_id
      @training.sport_id = 5
      @training.sport_level_id = 1
      @training.course_name_id = 4
      @training.filename = File.basename(file).to_s
      @training_orl = Training.find(:first,
      :conditions => {:user_id => @training.user_id , :filename => @training.filename},
      :select => 'id')

      if @training_orl.nil?
        @training.save

        FileUtils.mv file, "public/tracks/uploader/ok/"+File.basename(file).to_s
        begin

          td = Trainingsdata::Forerunner.new(f)

          td.laps.each_with_index do |value|

            @training.laps.create(
                  :distance_total => value[:distance],
                  :heartrate_avg => value[:heartrate_avg],
                  :calories => value[:calories],
                  :heartrate_max => value[:heartrate_max],
                  :duration => value[:duration],
                  :heartrate => value[:heartrate].to_json,
                  :height => value[:height].to_json,
                  :map => value[:map].to_json,
                  :start_time => value[:time]
                )
          end      
          @training.distance_total = td.distance_total
          @training.time_total = td.time_total
          @training.map_data = td.map_data
          @training.heartrate = td.heartrate
          @training.heartrate_avg = td.heartrate_avg
          @training.heartrate_max = td.heartrate_max
          @training.height = td.height
          @training.save
        end
      end
    end

end
