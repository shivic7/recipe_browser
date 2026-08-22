require "test_helper"

class PantryFlowTest < ActionDispatch::IntegrationTest
  test "adding, removing, and clearing pantry items" do
    post pantry_items_path, params: { ingredient_id: ingredients(:egg).id }
    follow_redirect!
    assert_select ".pantry-list li", text: /egg/i

    delete pantry_item_path(ingredients(:egg).id)
    follow_redirect!
    assert_select ".pantry-list", count: 0

    post pantry_items_path, params: { ingredient_id: ingredients(:milk).id }
    delete clear_pantry_items_path
    follow_redirect!
    assert_select ".pantry-list", count: 0
  end

  test "recipes index is gated until the pantry has at least 3 ingredients" do
    get recipes_path
    assert_redirected_to pantry_items_path                          # 0 items

    post pantry_items_path, params: { ingredient_id: ingredients(:egg).id }
    post pantry_items_path, params: { ingredient_id: ingredients(:milk).id }
    get recipes_path
    assert_redirected_to pantry_items_path                          # 2 items

    post pantry_items_path, params: { ingredient_id: ingredients(:salt).id }
    get recipes_path
    assert_response :success                                        # 3 items — gate opens
    assert_select ".recipe-card", minimum: 1

    delete pantry_item_path(ingredients(:salt).id)
    get recipes_path
    assert_redirected_to pantry_items_path                          # back to 2 — gate re-closes
  end

  test "recipe detail page marks which ingredients are in the pantry" do
    post pantry_items_path, params: { ingredient_id: ingredients(:egg).id }

    get recipe_path(recipes(:omelette))
    assert_select ".ingredient-list li.have", text: /egg/i
    assert_select ".ingredient-list li.missing", minimum: 1
  end
end