require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(email: "owner-dash@test.com", password: "password", role: :owner, tenant: tenants(:one))
    sign_in @owner
  end

  test "should get index" do
    get dashboard_url
    assert_response :success
  end
end
