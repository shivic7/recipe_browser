require "test_helper"

class IngredientNormalizerTest < ActiveSupport::TestCase
  test "strips quantities, units, and unicode fractions" do
    assert_equal "all-purpose flour", IngredientNormalizer.call("1 cup all-purpose flour")
    assert_equal "vegetable oil", IngredientNormalizer.call("⅓ cup vegetable oil")
    assert_equal "active dry yeast", IngredientNormalizer.call("2 (.25 ounce) packages active dry yeast")
  end

  test "does not eat the first letter of words that look like a unit abbreviation" do
    assert_equal "ground cinnamon", IngredientNormalizer.call("2 teaspoons ground cinnamon")
    assert_equal "garlic", IngredientNormalizer.call("3 cloves garlic")
  end

  test "cuts trailing prep notes and normalizes casing/whitespace" do
    assert_equal "garlic", IngredientNormalizer.call("1 tablespoon garlic, peeled and minced")
    assert_equal "white sugar", IngredientNormalizer.call("1  Cup   White   Sugar")
  end
end