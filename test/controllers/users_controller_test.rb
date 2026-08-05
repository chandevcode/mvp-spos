require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(email: "owner@test.com", password: "password", role: :owner, tenant: tenants(:one))
    sign_in @owner
  end

  test "should get index" do
    get users_path
    assert_response :success
  end

  test "should get new" do
    get new_user_path
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_path, params: { user: { email: "newuser@test.com", password: "password", password_confirmation: "password", role: :admin } }
    end
    assert_redirected_to users_path
  end

  test "should destroy user" do
    user_to_delete = User.create!(email: "delete@test.com", password: "password", role: :admin, tenant: tenants(:one))
    assert_difference("User.count", -1) do
      delete user_path(user_to_delete)
    end
    assert_redirected_to users_path
  end
end
