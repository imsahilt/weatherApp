class City < ApplicationRecord
  def self.autocomplete(query)
    where("name ILIKE ?","#{query}%").limit(5).select("(name || ', ' || country_code) as name, open_map_id as id")
  end
end
