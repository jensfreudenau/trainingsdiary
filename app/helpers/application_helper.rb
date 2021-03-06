module ApplicationHelper
    
  def resource_name
    :users
  end
  
  def resource
    @resource ||= Users.new
  end
  
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
  
  def to_dot_time(s)
    h = s / 3600
    s -= h * 3600
    m = s / 60
    s -= m * 60
    [h, m, s].join(":")
  end

  def time2hmsms
    t = Time.parse(time)

    return t.strftime( "%H:%M:%S,%L")
  end
  def time2hms (time)
    #    DateTime.parse(time)
    t = Time.parse(time)
    
    return t.strftime( "%H:%M:%S")
    
    #    return time.strptime(time, "%I:%M:%S")
    
    #  return time.strftime( "%I:%M:%S")
  end
  
  def date2dmy(d)      # International -> Deutsch, Rückgabe als String
    return d.to_s.sub(/(\w+)-(\w+)-(\w+)/, '\\3.\\2.\\1')
  end
  
  def date2ymd(date)   # Deutsch -> International, Rückgabe als Date
    return Date.strptime(date, "%d.%m.%Y")
  end
  
  def sort_td_class_helper(param)
    result = 'class="sortup"' if params[:sort] == param
    result = 'class="sortdown"' if params[:sort] == param + "_reverse"
    return result
  end
  
  def sort_link_helper(text, model_name ,param)
    key = param
    key += "_reverse" if params[:"#{model_name}_sort"] == param
    options = {
      :url => {:action => 'index', :params => params.merge({:"#{model_name}_sort" => key, :page => nil})},
      :update => 'content',
      :method => :get
    }
    html_options = {
      :title => "Sort by this field",
      :href => url_for(:action => 'index', :params => params.merge({:"#{model_name}_sort" => key, :page => nil}))
    }
    
    link_to(text, options, html_options,:remote=>true)
  end
  
  def minutes_per_km(distance, time) 
    begin
      res = (time.to_f*1000)/(distance.to_f*60);    
      return sprintf('%02d:%02d', res.floor, res*60 % 60);
    rescue
      return 0
    end
    
  end
  
  def km_per_hours(distance, time) 
    begin
      res = (distance.to_f / 1000) / (time.to_f / 3600)
      return sprintf('%02d:%02d', res.floor, res*60 % 60);
    rescue
      return 0
    end
  end


  def sortable(column, title = nil)
     title ||= column.titleize
     css_class = column == sort_column ? "current #{sort_direction}" : nil
     direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
     link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end


end
