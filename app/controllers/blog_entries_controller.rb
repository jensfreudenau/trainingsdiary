class BlogEntriesController < ApplicationController
	#layout "standard", :except => [:ajax_method, :more_ajax, :another_ajax]
  # GET /blog_entries
  # GET /blog_entries.xml
  before_filter :authenticate_user!, :except => [:index, :show]
  load_and_authorize_resource
  def index
		@blog_entries = 12345
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blog_entries }
    end
  end

	def test
		respond_to do |format|
=begin     if @blog_entries.save
        format.html { redirect_to(@blog_entries, :notice => 'Post created.') }
        format.js
=end      else
        format.html { render :action => "new" }
        format.js { render :nothing => true } 
    #  end
    end
=begin
		respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blog_entry }
    end
		rescue ActiveRecord::RecordNotFound
		  flash[:notice] = "Wrong post it"
		  redirect_to :action => 'index'
		if (request.xhr?)
	    render :text => @name.to_s
	  else
	    # No?  Then render an action.
	    render :action => 'view_attribute', :attr => @name
	  end
=end
	end
  # GET /blog_entries/1
  # GET /blog_entries/1.xml
  def show
    @blog_entry = BlogEntry.find(params[:id])
      respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blog_entry }
    end
  end

  # GET /blog_entries/new
  # GET /blog_entries/new.xml
  def new
    @blog_entry = BlogEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @blog_entry }
    end
  end

  # GET /blog_entries/1/edit
  def edit
    @blog_entry = BlogEntry.find(params[:id])
  end

  # POST /blog_entries
  # POST /blog_entries.xml
  def create
    @blog_entry = BlogEntry.new(params[:blog_entry])

    respond_to do |format|
      if @blog_entry.save
        format.html { redirect_to(@blog_entry, :notice => 'Blog entry was successfully created.') }
        format.xml  { render :xml => @blog_entry, :status => :created, :location => @blog_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blog_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /blog_entries/1
  # PUT /blog_entries/1.xml
  def update
    @blog_entry = BlogEntry.find(params[:id])
    respond_to do |format|
      if @blog_entry.update_attributes(params[:blog_entry])
        format.html { redirect_to(@blog_entry, :notice => 'Blog entry was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blog_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /blog_entries/1
  # DELETE /blog_entries/1.xml
  def destroy
    @blog_entry = BlogEntry.find(params[:id])
    @blog_entry.destroy

    respond_to do |format|
      format.html { redirect_to(blog_entries_url) }
      format.xml  { head :ok }
    end
  end
end
