require 'test_helper'

class Facebook::HumansControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    @pet = pets(:siamese)
    @user = @pet.user
  end
  
  def test_should_get_index_without_pet
    mock_user_facebooking
    facebook_get :index
    assert_response :success
    assert_template 'index'
    assert assigns(:occupation)
  end

  def test_should_get_index_with_pet
    mock_user_facebooking(@user.facebook_id)
    facebook_get :index, :fb_sig_user => @user.facebook_id
    assert_response :success
    assert_template 'index'
    assert assigns(:humans)
    assert assigns(:occupation)
    assert_tag :tag => "div", :attributes => { :id => "tame-human" }, :descendant => {
      :tag => "span", :attributes => { :class => "occupation-button" }, :descendant => {
        :tag => "a"
      }
    }
  end
  
  def test_should_get_human
    facebook_get :show, :id => humans(:sarah).id, :fb_sig_user => nil
    assert_response :success
    assert_template 'show'
    assert assigns(:human)
  end
end