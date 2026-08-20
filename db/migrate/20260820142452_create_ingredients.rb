class CreateIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :ingredients, "lower(name)", unique: true, name: "index_ingredients_on_lower_name"
    add_index :ingredients, :name, opclass: :gin_trgm_ops, using: :gin
  end
end
