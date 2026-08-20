class Ingredient < ApplicationRecord
	has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.search(term, limit: 10)
    return none if term.blank?

    where("name ILIKE ?", "%#{sanitize_sql_like(term)}%")
      .order(Arel.sql("similarity(name, #{connection.quote(term)}) DESC"), :name)
      .limit(limit)
  end
end
