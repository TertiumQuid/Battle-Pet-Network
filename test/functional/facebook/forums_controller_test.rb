require 'test_helper'

class Facebook::ForumsControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    @pet = pets(:siamese)
    @user = @pet.user
    @forum = forums(:discussion)
  end
  
  def test_index
    facebook_get :index, :fb_sig_user => nil
    assert_response :success
    assert_template 'index'
    assert !assigns(:forums).blank?
    assert assigns(:forums).select{|f| f.forum_type != 'user'}.blank?
    assert_tag :tag => "table", :attributes => { :class => "forums"}, :descendant => { 
      :tag => "tr", :attributes => { :class => "forum" }
    }
  end
  
  def test_index_with_staff
    @user.update_attribute(:role, 'admin')
    facebook_get :index, :fb_sig_user => @user.facebook_id
    assert !assigns(:forums).blank?
    assert !assigns(:forums).select{|f| f.forum_type == 'staff'}.blank?
  end
  
  def test_show
    facebook_get :show, :id => @forum.id, :fb_sig_user => nil
    assert_response :success
    assert_template 'show'
    assert !assigns(:forum).blank?
    assert !assigns(:topics).blank?
    assert_tag :tag => "table", :attributes => { :class => "topics"}, :descendant => { 
      :tag => "tr", :attributes => { :class => "topic" }
    }
  end  
end