require 'test_helper'

class PlaidItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @plaid_item = plaid_items(:one)
  end

  test "should get index" do
    get plaid_items_url
    assert_response :success
  end

  test "should get new" do
    get new_plaid_item_url
    assert_response :success
  end

  test "should create plaid_item" do
    assert_difference('PlaidItem.count') do
      post plaid_items_url, params: { plaid_item: { access_token: @plaid_item.access_token, item_id: @plaid_item.item_id } }
    end

    assert_redirected_to plaid_item_url(PlaidItem.last)
  end

  test "should show plaid_item" do
    get plaid_item_url(@plaid_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_plaid_item_url(@plaid_item)
    assert_response :success
  end

  test "should update plaid_item" do
    patch plaid_item_url(@plaid_item), params: { plaid_item: { access_token: @plaid_item.access_token, item_id: @plaid_item.item_id } }
    assert_redirected_to plaid_item_url(@plaid_item)
  end

  test "should destroy plaid_item" do
    assert_difference('PlaidItem.count', -1) do
      delete plaid_item_url(@plaid_item)
    end

    assert_redirected_to plaid_items_url
  end
end
