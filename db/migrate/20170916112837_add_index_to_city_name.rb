class AddIndexToCityName < ActiveRecord::Migration[5.0]
  def change
    add_index :cities, :name, order: {name: :varchar_pattern_ops}
  end
end
