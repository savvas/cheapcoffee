require 'test_helper'

class CafeteriasControllerTest < ActionController::TestCase
  setup do
    @cafeteria = cafeterias(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cafeterias)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cafeteria" do
    assert_difference('Cafeteria.count') do
      post :create, :cafeteria => @cafeteria.attributes
    end

    assert_redirected_to cafeteria_path(assigns(:cafeteria))
  end

  test "should show cafeteria" do
    get :show, :id => @cafeteria.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cafeteria.to_param
    assert_response :success
  end

  test "should update cafeteria" do
    put :update, :id => @cafeteria.to_param, :cafeteria => @cafeteria.attributes
    assert_redirected_to cafeteria_path(assigns(:cafeteria))
  end

  test "should destroy cafeteria" do
    assert_difference('Cafeteria.count', -1) do
      delete :destroy, :id => @cafeteria.to_param
    end

    assert_redirected_to cafeterias_path
  end
end
