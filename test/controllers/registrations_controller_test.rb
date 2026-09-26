require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "create with valid data signs the user in" do
    assert_difference -> { User.count } do
      post registration_path, params: { user: { email_address: "Nowy@Example.com", password: "tajnehaslo1", password_confirmation: "tajnehaslo1" } }
    end

    assert_redirected_to root_path
    assert cookies[:session_id]
    assert_equal "nowy@example.com", User.last.email_address
  end

  test "create with too short password" do
    assert_no_difference -> { User.count } do
      post registration_path, params: { user: { email_address: "nowy@example.com", password: "krotkie", password_confirmation: "krotkie" } }
    end

    assert_response :unprocessable_entity
  end

  test "create with taken email" do
    assert_no_difference -> { User.count } do
      post registration_path, params: { user: { email_address: users(:one).email_address, password: "tajnehaslo1", password_confirmation: "tajnehaslo1" } }
    end

    assert_response :unprocessable_entity
  end
end
