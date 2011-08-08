class Forerunner
	attr_accessor :rounds, :time_total, :distance_total, :speed_max, :calories, :heartrate_avg, :heartrate_max, :start_time
	def initialize (file)
		@source_doc = Nokogiri::XML.parse(file) { |cfg| cfg.noblanks }
		@log = Logger.new('log/fore_runner.log')
		@rounds = Hash.new
		@heartrate_max = 0
		@heartrate_avg = 0
		@speed_max = 0
		@time_total = 0
		@distance_total = 0
		@calories = 0
		@start_time = 0
		self.generate_laps
	end
	
	protected
	def generate_laps
		counter = 0
		trackpoint = 0
		@source_doc.root.children.children.children.each do |node|
			if node.name == 'Lap'
				counter +=1
				if counter == 1
					@start_time = node["StartTime"].to_s
				end
				round = counter.to_s
				@rounds[round.to_i]||= {}
				@rounds[round.to_i][:lap_start_time] = node["StartTime"].to_s
				 
				
				node.children.each do |main_sub_node|
					
					if main_sub_node.name == 'MaximumHeartRateBpm'
						@rounds[round.to_i] ||= {}
						@rounds[round.to_i][:heartrate_max] = main_sub_node.children[0].text.to_f
						if @heartrate_max < main_sub_node.children[0].text.to_f
							@heartrate_max = main_sub_node.children[0].text.to_f
						end
					end
					
					if main_sub_node.name == 'AverageHeartRateBpm'
						@rounds[round.to_i] ||= {}
						@rounds[round.to_i][:heartrate_avg] = main_sub_node.children[0].text.to_f
						@heartrate_avg = main_sub_node.children[0].text.to_f
					end
					if main_sub_node.name == 'TotalTimeSeconds'
						@rounds[round.to_i] ||= {}
						@rounds[round.to_i][:seconds_total] = main_sub_node.text.to_f
						@time_total += main_sub_node.text.to_f
					end
					
					if main_sub_node.name == 'DistanceMeters'
						@rounds[round.to_i] ||= {}
						@rounds[round.to_i][:distance_lap] = main_sub_node.text.to_f
						@distance_total += main_sub_node.text.to_f
					end
					
					if main_sub_node.name == 'MaximumSpeed'
						@rounds[round.to_i] ||= {}
						@rounds[round.to_i][:speed_max_lap] = main_sub_node.text.to_f
						if @speed_max < main_sub_node.text.to_f
							@speed_max += main_sub_node.text.to_f
						end
					end
					
					if main_sub_node.name == 'Calories'
						@rounds[round.to_i] ||= {}
						@rounds[round.to_i][:calories] = main_sub_node.text.to_f
						@calories += main_sub_node.text.to_f
					end
				end
				
				node.children.children.each do |sub_node|
					if sub_node.name == 'Trackpoint'
						trackpoint +=1
						@rounds[round.to_i][:laps] ||= {}
						sub_node.children.each do |working_node|
							if working_node.name == 'Time'
								@rounds[round.to_i][:laps][trackpoint.to_i] ||= {}
								@rounds[round.to_i][:laps][trackpoint.to_i][:time] = working_node.inner_text.to_s 
							end
							if working_node.name == 'Position' && !working_node.children[0].text.to_s.nil? &&  !working_node.children[1].text.nil? 
							  
								@rounds[round.to_i][:laps][trackpoint.to_i] ||= {}
								@rounds[round.to_i][:laps][trackpoint.to_i][:latitude_degrees]	= working_node.children[0].text.to_s
								@rounds[round.to_i][:laps][trackpoint.to_i][:longitude_degrees]	= working_node.children[1].text.to_s
							end
							if working_node.name == 'AltitudeMeters'
								@rounds[round.to_i][:laps][trackpoint.to_i] ||= {}
								@rounds[round.to_i][:laps][trackpoint.to_i][:altitude] = working_node.inner_text
							end				
							
              if working_node.name == 'DistanceMeters'
								@rounds[round.to_i][:laps][trackpoint.to_i] ||= {}
								@rounds[round.to_i][:laps][trackpoint.to_i][:distance] = working_node.inner_text
							end
							if working_node.name == 'HeartRateBpm'
								@rounds[round.to_i][:laps][trackpoint.to_i] ||= {}
								@rounds[round.to_i][:laps][trackpoint.to_i][:heart_rate_bpm] = working_node.children[0].text.to_i
							end
							if working_node.name == 'AltitudeMeters'
								@rounds[round.to_i][:laps][trackpoint.to_i] ||= {}
								@rounds[round.to_i][:laps][trackpoint.to_i][:height] = working_node.children[0].text.to_f
							end
						end
					end
				end
			end
		end
	end
end
