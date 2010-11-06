require 'test_helper'

class Facebook::LeaderboardsControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
  end
  
  def test_index
    mock_user_facebooking
    facebook_get :index
    assert_response :success
    assert_template 'index'
    assert !assigns(:leaderboards).blank?
  end 
  
  def test_index_empty
    Leaderboard.destroy_all
    mock_user_facebooking
    facebook_get :index
    assert_response :success
    assert_template 'index'
    assert assigns(:leaderboards).blank?
  end 
end