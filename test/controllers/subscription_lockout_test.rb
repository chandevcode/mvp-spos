require "test_helper"

class SubscriptionLockoutTest < ActionDispatch::IntegrationTest
  test "expired tenant is redirected to profile" do
    tenants(:one).update!(subscription_status: :expired)
    sign_in users(:one)

    get root_url
    assert_redirected_to edit_profile_path
  end

  test "active tenant can access the app" do
    tenants(:one).update!(subscription_status: :active, subscription_expires_at: 1.month.from_now)
    sign_in users(:one)

    get root_url
    assert_response :success
  end

  test "expired user can still reach profile and extend plan" do
    tenants(:one).update!(subscription_status: :expired)
    sign_in users(:one)

    get edit_profile_path
    assert_response :success
    get extend_subscription_path
    assert_response :success
  end
end
