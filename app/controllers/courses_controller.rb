require 'rexml/document'

require 'json'
load "fileutils.rb"
class CoursesController < ApplicationController
  #@log = Logger.new('log/courses.log')
  before_filter :authenticate_user!, :except => [:index, :show, :find_club]
  before_filter :init
  load_and_authorize_resource
  include Trainingsdata
  
  def init
    @log = Logger.new('log/courses.log')  
    @course_path = Rails.root + 'public/uploads/course/file/' + current_user.id.to_s
   
  end
  
  # GET /courses
  # GET /courses.xml
  def index
    @courses = Course.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end
  
  def download
    filename  = params[:filename]
    send_file @course_path.to_s + '/' + params[:id].to_s + '/' + filename.to_s, :type=>"application/text"
    
  end

  # GET /courses/1
  # GET /courses/1.xml
  def show
    
    @course = Course.find(params[:id])    
    file = @course_path.to_s + '/' + params[:id].to_s + '/' +  @course.file.to_s    
    
    td = Trainingsdata::Forerunner.new(file)   
    td.generate_course
    @route = td.course.to_s
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @course }
    end
  end

  # GET /courses/new
  # GET /courses/new.xml
  def new
    @course = Course.new
    @sport = Sport.find(
      :all,
      :select => 'id, name',
      :conditions => {:user_id => current_user.id}
    )
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @course }
    end
  end

  # GET /courses/1/edit
  def edit
    @sport = Sport.find(
      :all,
      :select => 'id, name',
      :conditions => {:user_id => current_user.id}
    )
    @course = Course.find(params[:id])
  end

  # POST /courses
  # POST /courses.xml
  def create
    
    Course.mounting

    @sport = Sport.find(
      :all,
      :select => 'id, name',
      :conditions => {:user_id => current_user.id}
    )
    
    @course = Course.new(params[:course])
    @course.user = current_user
    respond_to do |format|
      
       
      if @course.save
        format.html { redirect_to(@course, :notice => 'Course was successfully created.') }
        format.xml  { render :xml => @course, :status => :created, :location => @course }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /courses/1
  # PUT /courses/1.xml
  def update
    Course.mounting
     
    @course = Course.find(params[:id])
    @course.user = current_user
    respond_to do |format|
      if @course.update_attributes(params[:course])
        format.html { redirect_to(@course, :notice => 'Course was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.xml
  def destroy
    @course = Course.find(params[:id])
    @file = @course_path.to_s + '/' + params[:id].to_s + '/' +  @course.file.to_s
    @filetree = @course_path.to_s + '/' + params[:id].to_s
    self.cleanup
    @course.destroy

    respond_to do |format|
      format.html { redirect_to(courses_url) }
      format.xml  { head :ok }
    end
  end
  
  def create_from_activity
#    @course = Course.new
#    @sport = Sport.find(
#      :all,
#      :select => 'id, name',
#      :conditions => {:user_id => current_user.id}
#    )
    
    @training = Training.find(:first,
                    :select => 'trainings.map_data, trainings.distance_total, trainings.time_total, trainings.start_time',
                    :conditions => ['trainings.user_id = ? AND trainings.id = ?', current_user , params[:trainings_id]])
   
    @training.map_data = @training.map_data.squeeze("]]")
    
    @training.map_data.slice!(0..2)
    degrees = @training.map_data.split('],[')
    @deg = Array.new
    degrees.each do |item| 
      pair = item.split(',')
      if (pair.count() == 2)
        @deg << pair
      end
    end
    path = @course_path.to_s + '/' + params[:id].to_s + '/' + 'glucks'
    td = Trainingsdata::Forerunner.new(path, true)
    td.create_trainings_file(@deg, @training)
    
  end
  
  
  
  def cleanup
    File.delete(@file) if File.exist?(@file)
    (@filetree).rmtree if @filetree.directory?

  end
  
  def bigmap
    id        = params[:id]
    @course = Course.find(id)
    file = @course_path.to_s + '/' + params[:id].to_s + '/' +  @course.file.to_s   
    td = Trainingsdata::Forerunner.new(file)
    td.generate_course
    @course = td.course.to_s                    
    render :partial => 'bigmap.html.haml'
  end
end
