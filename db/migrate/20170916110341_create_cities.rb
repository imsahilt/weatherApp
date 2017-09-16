class CreateCities < ActiveRecord::Migration[5.0]
  def change
    create_table :cities do |t|
      t.string :name
      t.string :open_map_id
      t.string :country_code
      t.string :coordinates_lat
      t.string :coordinates_lng

      t.timestamps
    end
  end
end
