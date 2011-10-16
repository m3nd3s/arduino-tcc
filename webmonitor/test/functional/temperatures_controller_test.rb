require 'test_helper'

class TemperaturesControllerTest < ActionController::TestCase
  setup do
    @temperature = temperatures(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:temperatures)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create temperature" do
    assert_difference('Temperature.count') do
      post :create, temperature: @temperature.attributes
    end

    assert_redirected_to temperature_path(assigns(:temperature))
  end

  test "should show temperature" do
    get :show, id: @temperature.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @temperature.to_param
    assert_response :success
  end

  test "should update temperature" do
    put :update, id: @temperature.to_param, temperature: @temperature.attributes
    assert_redirected_to temperature_path(assigns(:temperature))
  end

  test "should destroy temperature" do
    assert_difference('Temperature.count', -1) do
      delete :destroy, id: @temperature.to_param
    end

    assert_redirected_to temperatures_path
  end
end
