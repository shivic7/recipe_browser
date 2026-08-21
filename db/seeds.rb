require "json"
require "zlib"

DATASET_PATH = Rails.root.join("db/seed_data/recipes-en.json.gz")

def fix_image_url(url)
  return url if url.blank?
  return url unless url.include?("imagesvc.meredithcorp.io") && !url.include?("w=")
  "#{url}&w=750&q=60"
end

if Recipe.exists?
  puts "Already seeded (#{Recipe.count} rows) - skipping."
else
  raw_json = Zlib::GzipReader.open(DATASET_PATH) { |gz| gz.read }
  recipes_data = JSON.parse(raw_json)

  ingredient_names = Set.new
  recipes_data.each do |recipe|
    recipe.fetch("ingredients", []).each do |line|
      name = IngredientNormalizer.call(line)
      ingredient_names << name if name.present?
    end
  end

  now = Time.current
  ingredient_names.each_slice(1000) do |names|
    Ingredient.insert_all(names.map { |n| { name: n, created_at: now, updated_at: now } })
  end

  ingredient_id_by_name = Ingredient.pluck(:name, :id).to_h

  recipes_data.each_slice(500) do |batch|
    recipe_rows = batch.map do |r|
      {
        title: r["title"].presence || "Untitled recipe",
        category: r["category"], cuisine: r["cuisine"], author: r["author"],
        image_url: fix_image_url(r["image"]),
        prep_time_minutes: r["prep_time"], cook_time_minutes: r["cook_time"],
        rating: r["ratings"], created_at: now, updated_at: now
      }
    end

    inserted_ids = Recipe.insert_all(recipe_rows, returning: [ :id ]).rows.flatten

    recipe_ingredient_rows = []
    batch.each_with_index do |r, i|
      recipe_id = inserted_ids[i]
      seen = Set.new
      r.fetch("ingredients", []).each_with_index do |line, position|
        name = IngredientNormalizer.call(line)
        next if name.blank?
        ingredient_id = ingredient_id_by_name[name]
        next unless ingredient_id
        next unless seen.add?(ingredient_id)

        recipe_ingredient_rows << {
          recipe_id: recipe_id, ingredient_id: ingredient_id,
          raw_text: line, position: position, created_at: now, updated_at: now
        }
      end
    end

    RecipeIngredient.insert_all(recipe_ingredient_rows) if recipe_ingredient_rows.any?
  end
end