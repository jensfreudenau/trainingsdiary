class CourseNamesController < ApplicationController
    # GET /course_names
    # GET /course_names.xml
    before_filter :authenticate_user!, :except => [:sort]
    #load_and_authorize_resource
    def index
        @course_names = CourseName.all(
            :conditions => ["course_names.user_id = ?", current_user ]
            )
        #@course_names = course_names.paginate:page => params[:page], :per_page => 25
        respond_to do |format|
            format.html # index.html.erb
            format.xml  { render :xml => @course_names }
        end
    end

    # GET /course_names/1
    # GET /course_names/1.xml
    def show
        @course_name = CourseName.find(
            :first,
            :conditions => {:user_id => current_user.id , :id => params[:id]}
        )
        respond_to do |format|
            format.html # show.html.erb
            format.xml  { render :xml => @course_name }
        end
    end

    # GET /course_names/new
    # GET /course_names/new.xml
    def new
        @course_name = CourseName.new
        respond_to do |format|
            format.html # new.html.erb
            format.xml  { render :xml => @course_name }
        end
    end

    # GET /course_names/1/edit
    def edit
        @course_name = CourseName.find(
            :first,
            :conditions => {:user_id => current_user.id , :id => params[:id]}
        )
    end

    # POST /course_names
    # POST /course_names.xml
    def create
        params[:course_name][:user_id] = current_user.id
        @course_name = CourseName.new(params[:course_name])

        respond_to do |format|
            if @course_name.save
                format.html { redirect_to(course_names_url, :notice => 'Course name was successfully created.') }
                format.xml  { render :xml => @course_name, :status => :created, :location => @course_name }
            else
                format.html { render :action => "new" }
                format.xml  { render :xml => @course_name.errors, :status => :unprocessable_entity }
            end
        end
    end

    # PUT /course_names/1
    # PUT /course_names/1.xml
    def update
        params[:course_name][:user_id] = current_user.id
        @course_name = CourseName.find(params[:id])

        respond_to do |format|
            if @course_name.update_attributes(params[:course_name])
                format.html { redirect_to(course_names_url, :notice => 'Course name was successfully updated.') }
                format.xml  { head :ok }
            else
                format.html { render :action => "edit" }
                format.xml  { render :xml => @course_name.errors, :status => :unprocessable_entity }
            end
        end
    end

    # DELETE /course_names/1
    # DELETE /course_names/1.xml
    def destroy
        @course_name = CourseName.find(params[:id])
        @course_name.destroy

        respond_to do |format|
            format.html { redirect_to(course_names_url) }
            format.xml  { head :ok }
        end
    end
    
    def sort
      @course_names = CourseName.all
      @course_names.each do |course_name|
        course_name.sort = params[:list].index(course_name.id.to_s)
        course_name.save
      end 
      render :nothing => true 
    end
end
