require "application_system_test_case"

class PlaidItemsTest < ApplicationSystemTestCase
  setup do
    @plaid_item = plaid_items(:one)
  end

  test "visiting the index" do
    visit plaid_items_url
    assert_selector "h1", text: "Plaid Items"
  end

  test "creating a Plaid item" do
    visit plaid_items_url
    click_on "New Plaid Item"

    fill_in "Access token", with: @plaid_item.access_token
    fill_in "Item", with: @plaid_item.item_id
    click_on "Create Plaid item"

    assert_text "Plaid item was successfully created"
    click_on "Back"
  end

  test "updating a Plaid item" do
    visit plaid_items_url
    click_on "Edit", match: :first

    fill_in "Access token", with: @plaid_item.access_token
    fill_in "Item", with: @plaid_item.item_id
    click_on "Update Plaid item"

    assert_text "Plaid item was successfully updated"
    click_on "Back"
  end

  test "destroying a Plaid item" do
    visit plaid_items_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Plaid item was successfully destroyed"
  end
end
