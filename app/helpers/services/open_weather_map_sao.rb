module Services
  module OpenWeatherMapSao
    class << self
      require 'net/http'

      def get_request(url)
        url = URI.parse(url)
        req = Net::HTTP::Get.new(url.to_s)
        res = Net::HTTP.start(url.host, url.port) {|http|
          http.request(req)
        }
      end
      
      def get_weather_by_city_id(city_id)
        Rails.logger.info("calling weather api for city id #{city_id}")
        res = get_request("http://api.openweathermap.org/data/2.5/forecast?APPID=#{WeatherAppConfig.OPEN_WEATHER_MAP_API_KEY}&id=#{city_id}&units=metric")
        response = JSON.parse(res.body) rescue {"cod" => "500", :errors => ["Unable to parse openweathermap response"]}
        build_custom_weather_response(response)
      end

      def get_weather_by_city_name(city_name)
        res = get_request("http://api.openweathermap.org/data/2.5/forecast?APPID=#{WeatherAppConfig.OPEN_WEATHER_MAP_API_KEY}&q=#{city_name}&units=metric")
        response = JSON.parse(res.body) rescue {"cod" => "500", :errors => ["Unable to parse openweathermap response"]}
        build_custom_weather_response(response)
      end

      # If weather api response changes our clients will not break.
      def build_custom_weather_response(open_weather_response)
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
  end
end