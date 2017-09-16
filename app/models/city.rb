class City < ApplicationRecord

  AUTOCOMPLETE_LIMIT = 10
  
  def self.autocomplete(query)
    where("name ILIKE ?","#{query}%").limit(AUTOCOMPLETE_LIMIT).select("(name || ', ' || country_code) as name, open_map_id as id")
  end

  def self.get_weather(city_id, city_name)
    if city_id.to_i == 0
      return build_custom_weather_response(Services::OpenWeatherMapSao.get_weather_by_city_name(city_name))
    else
      # assuming weather report is updated every 6 - 12 hours
      open_weather_response = Rails.cache.fetch("open_weather_response:#{city_id}", :expires_in => 6.hours) do
        Services::OpenWeatherMapSao.get_weather_by_city_id(city_id)
      end
      return build_custom_weather_response(open_weather_response)
    end
  end

  # If weather api response changes our clients will not break.
  def self.build_custom_weather_response(open_weather_response)
    response = {:status => open_weather_response["cod"], :errors => [], :weather_infos => []}
    if open_weather_response["cod"] == "200"
      response[:city_name] = "#{open_weather_response["city"]["name"]}, #{open_weather_response["city"]["country"]}"
      open_weather_response["list"].each do |info|
        # For cached results if some of them are before current time.
        if info["dt"] > Time.now.to_i
          weather_info  = {}
          weather_info[:datetime] = "#{info["dt_txt"]} UTC"
          main = info["main"]
          next unless main.present?
          weather_info[:temp] = {
            :curr => main["temp"],
            :min => main["temp_min"],
            :max => main["temp_max"],
            :metric => "°C"
          }
          weather_info[:humidity] = main["humidity"]
          weather_info[:more_info] = {
            :description => (info["weather"].first["description"] rescue ""),
            :weather_icon => (info["weather"].first["icon"] rescue ""),
            :wind_speed => ("#{info["wind"]["speed"]} m/s" rescue "")
          }
          response[:weather_infos] << weather_info
        end
      end
    elsif open_weather_response["cod"] == "404"
      response[:errors] << "We could not find for city you were looking for. Please try some other city."
    else
      Rails.logger.error("Something went wrong calling openweathermap ERROR: #{open_weather_response["errors"].join(",")}")
      response[:errors].add("We are sorry something went wrong. Please try again later")
    end
    response
  end
end
