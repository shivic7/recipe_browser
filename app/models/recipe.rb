class Recipe < ApplicationRecord
  has_many :recipe_ingredients, -> { order(:position) }, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  validates :title, presence: true

  MIN_INGREDIENTS_FOR_RANKING = 3

  MATCHED_INGREDIENTS_JOIN = <<~SQL
    INNER JOIN (
      SELECT recipe_id, COUNT(*) AS matched_count
      FROM recipe_ingredients
      WHERE ingredient_id IN (?)
      GROUP BY recipe_id
    ) matched ON matched.recipe_id = recipes.id
    INNER JOIN (
      SELECT recipe_id, COUNT(*) AS total_count
      FROM recipe_ingredients
      GROUP BY recipe_id
    ) totals ON totals.recipe_id = recipes.id
  SQL

  def self.ranked_by_pantry(ingredient_ids)
    return none if ingredient_ids.blank?

    join_sql = sanitize_sql_array([ MATCHED_INGREDIENTS_JOIN, ingredient_ids ])

    joins(join_sql)
      .where("matched.matched_count >= ?", MIN_INGREDIENTS_FOR_RANKING - 1)
      .select("recipes.*, matched.matched_count AS matched_count, totals.total_count AS total_count, (matched.matched_count::float / totals.total_count) AS match_ratio")
      .order(Arel.sql("match_ratio DESC, matched.matched_count DESC, recipes.rating DESC NULLS LAST"))
  end
end