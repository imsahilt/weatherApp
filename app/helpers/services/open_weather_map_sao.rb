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
        JSON.parse(res.body) rescue {"cod" => "500", :errors => ["Unable to parse openweathermap response"]}
      end

      def get_weather_by_city_name(city_name)
        res = get_request("http://api.openweathermap.org/data/2.5/forecast?APPID=#{WeatherAppConfig.OPEN_WEATHER_MAP_API_KEY}&q=#{city_name}&units=metric")
        JSON.parse(res.body) rescue {"cod" => "500", :errors => ["Unable to parse openweathermap response"]}
      end

    end
  end
end