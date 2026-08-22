require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "ranked_by_pantry orders recipes by share of ingredients the user has" do
    ids = [ ingredients(:egg).id, ingredients(:milk).id, ingredients(:salt).id ]
    results = Recipe.ranked_by_pantry(ids)

    assert_equal [ recipes(:omelette), recipes(:salted_egg), recipes(:pancakes) ], results.to_a
    assert_equal 3, results.find(recipes(:omelette).id).matched_count  # 3/3
    assert_equal 3, results.find(recipes(:pancakes).id).matched_count  # 3/5
  end

  test "ranked_by_pantry returns none when the pantry is empty" do
    assert_equal [], Recipe.ranked_by_pantry([]).to_a
  end
end