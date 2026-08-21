class PantryItemsController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @suggestions = @query.present? ? Ingredient.search(@query) : Ingredient.none
    @pantry_ingredients = Ingredient.where(id: pantry_ingredient_ids).order(:name)
  end

  def create
    ingredient = Ingredient.find_by(id: params[:ingredient_id])
    session[:pantry_ingredient_ids] = (pantry_ingredient_ids + [ ingredient.id ]).uniq if ingredient
    redirect_to pantry_items_path(q: params[:q])
  end

  def destroy
    session[:pantry_ingredient_ids] = pantry_ingredient_ids - [ params[:id].to_i ]
    redirect_to pantry_items_path(q: params[:q])
  end

  def destroy_all
    session[:pantry_ingredient_ids] = []
    redirect_to pantry_items_path, notice: "Pantry cleared."
  end
end