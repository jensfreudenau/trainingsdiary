module TrainingsHelper
  def minutesPerKm(distance, time) 
    res = (time*1000)/(distance*60);    
    return sprintf('%02d:%02d', res.floor, res*60 % 60);
  end
end
