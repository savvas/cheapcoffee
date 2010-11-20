require 'test_helper'

class PricesControllerTest < ActionController::TestCase
  setup do
    @price = prices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:prices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create price" do
    assert_difference('Price.count') do
      post :create, :price => @price.attributes
    end

    assert_redirected_to price_path(assigns(:price))
  end

  test "should show price" do
    get :show, :id => @price.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @price.to_param
    assert_response :success
  end

  test "should update price" do
    put :update, :id => @price.to_param, :price => @price.attributes
    assert_redirected_to price_path(assigns(:price))
  end

  test "should destroy price" do
    assert_difference('Price.count', -1) do
      delete :destroy, :id => @price.to_param
    end

    assert_redirected_to prices_path
  end
end
