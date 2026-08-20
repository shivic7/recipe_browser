class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes do |t|
      t.string :title
      t.string :category
      t.string :cuisine
      t.string :author
      t.string :image_url
      t.integer :prep_time_minutes
      t.integer :cook_time_minutes
      t.decimal :rating

      t.timestamps
    end

    add_index :recipes, :title
    add_index :recipes, :category
  end
end
