module TrainingsHelper
  def minutesPerKm(distance, time) 
    res = (time*1000)/(distance*60);    
    return sprintf('%02d:%02d', res.floor, res*60 % 60);
  end

  def convertTimeToDuration(total_seconds, opts = {})
    opts[:format] ||= :default
    puts "total: #{total_seconds.to_f}"
    case opts[:format]
      when :default
        seconds = total_seconds % 60
        minutes = (total_seconds / 60) % 60
        hours   = total_seconds / (60 * 60)
        return format("%02d:%02d:%02d", hours, minutes, seconds)
      when :milliseconds
        #millis  = total_seconds.ceil
        puts seconds = total_seconds % 60
        minutes = (total_seconds / 60) % 60
        hours   = total_seconds / (60 * 60)
        puts sec = sprintf("%.2f", seconds)
        puts sec.to_f
        return sprintf("%02d:%02d:%02.2f", hours, minutes, sec.to_f)
    end


    #return hours+':'+minutes+':'+minutes
  end

  def convertTimeToDuration1(total_seconds)
    seconds = total_seconds % 60
    minutes = (total_seconds / 60) % 60
    hours = total_seconds / (60 * 60)
    return format("%02d:%02d:%02d", hours, minutes, seconds)
    #return hours+':'+minutes+':'+minutes
  end

  def kelvin_to_celsius(kelvin)
    return (kelvin.to_f - 273.16).round(2)
  end
end
