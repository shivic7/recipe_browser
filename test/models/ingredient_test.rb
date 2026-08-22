require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  test "search matches by substring, case-insensitively, and ignores blank terms" do
    assert_includes Ingredient.search("EGG").to_a, ingredients(:egg)
    assert_equal [], Ingredient.search("").to_a
  end

  test "name is unique, case-insensitively" do
    assert_not Ingredient.new(name: "EGG").valid?
  end
end