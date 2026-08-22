module RecipesHelper
  def missing_ingredient_names(recipe, pantry_ingredient_ids, limit: 4)
    names = recipe.recipe_ingredients
                   .reject { |ri| pantry_ingredient_ids.include?(ri.ingredient_id) }
                   .map { |ri| ri.ingredient.name }
    return "" if names.empty?
    shown = names.first(limit).join(", ")
    names.size > limit ? "#{shown} + #{names.size - limit} more" : shown
  end

  def recipe_time_summary(recipe)
    [
      ("#{recipe.prep_time_minutes} min prep" if recipe.prep_time_minutes.present?),
      ("#{recipe.cook_time_minutes} min cook" if recipe.cook_time_minutes.present?)
    ].compact.join(" · ")
  end
end