# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

cities_data = File.read("#{Rails.root}/private/city.list.min.json")
cities_json = JSON.parse(cities_data) rescue []
cities_json.map{|city| City.find_or_create_by(:name=>city["name"], :open_map_id=>city["id"], :country_code=>city["country"],:coordinates_lat=>(city["coord"]["lat"] rescue nil), :coordinates_lng =>(city["coord"]["lon"] rescue nil))}