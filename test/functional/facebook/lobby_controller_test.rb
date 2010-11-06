require 'test_helper'

class Facebook::LobbyControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    mock_user_facebooking
  end
  
  def test_index
    facebook_get :index, :fb_sig_user => nil
    assert_response :success
    assert_template 'index'
    assert !assigns(:pet_activity).blank?
    assert !assigns(:world_activity).blank?
    assert !assigns(:forum_posts).blank?
    assert_tag :tag => "ul", :attributes => { :class => "activity-stream", :id => "pet-activity" }, :descendant => { :tag => "li", :attributes => { :class => "activity" } }
    assert_tag :tag => "ul", :attributes => { :class => "activity-stream", :id => "world-activity" }, :descendant => { :tag => "li", :attributes => { :class => "activity" } }
    assert_tag :tag => "ul", :attributes => { :class => "activity-stream", :id => "forum-posts" }, :descendant => { :tag => "li", :attributes => { :class => "activity" } }
  end

  def test_tos
    facebook_get :tos, :fb_sig_user => nil
    assert_response :success
    assert_template 'tos'
  end

  def test_staff
    facebook_get :staff, :fb_sig_user => nil
    assert_response :success
    assert_template 'staff'
  end

  def test_contact
    facebook_get :contact, :fb_sig_user => nil
    assert_response :success
    assert_template 'contact'
  end
  
  def test_about
    facebook_get :about, :fb_sig_user => nil
    assert_response :success
    assert_template 'about'
  end
  
  def test_guide
    facebook_get :guide, :fb_sig_user => nil
    assert_response :success
    assert_template 'guide'
  end
  
  def test_should_get_invite
    facebook_get :invite, :fb_sig_user => users(:one).facebook_id
    assert_response :success
    assert_template 'invite'
    assert_tag :tag => "fb:request-form"
    assert_tag :tag => "fb:multi-friend-selector"
    assert assigns(:exclude_ids)
  end
  
  def test_facebook_user_set
    new_user_sig = "0010100111"
    assert_difference 'User.count', +1, "user should create from facebook" do
      facebook_get :index, :fb_sig_user => new_user_sig
      assert_response :success
      assert assigns(:current_user)
    end
    
    existing_user_id = assigns(:current_user).facebook_id
    assert_no_difference 'User.count', "existing user should have been found facebook" do
      facebook_get :index, :fb_sig_user => existing_user_id
    end
  end
end