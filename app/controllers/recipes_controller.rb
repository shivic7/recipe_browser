class RecipesController < ApplicationController
  RESULTS_LIMIT = 30

  def index
    minimum = Recipe::MIN_INGREDIENTS_FOR_RANKING
    if pantry_ingredient_ids.empty?
      redirect_to pantry_path, alert: "Add a few ingredients to your pantry first." and return
    elsif pantry_ingredient_ids.size < minimum
      missing = minimum - pantry_ingredient_ids.size
      noun = missing == 1 ? "ingredient" : "ingredients"
      redirect_to pantry_items_path, alert: "Add #{missing} more #{noun} to your pantry — recipes need at least #{minimum} matches to show up." and return
    end

    @recipes = Recipe.ranked_by_pantry(pantry_ingredient_ids)
                      .includes(recipe_ingredients: :ingredient)
                      .limit(RESULTS_LIMIT)
    @pantry_ingredient_ids = pantry_ingredient_ids.to_set
  end

  def show
    @recipe = Recipe.includes(recipe_ingredients: :ingredient).find(params[:id])
    @pantry_ingredient_ids = pantry_ingredient_ids.to_set
  end
end