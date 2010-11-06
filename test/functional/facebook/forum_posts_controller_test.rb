require 'test_helper'

class Facebook::ForumPostsControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    @pet = pets(:siamese)
    @user = @pet.user
    @forum = forums(:discussion)
    @topic = forum_topics(:discussion_rules)
    @topic.update_attribute(:locked,false)
  end
  
  def test_create
    mock_user_facebooking(@user.facebook_id)
    assert_difference ['ForumPost.count'], +1 do
      facebook_post :create, :forum_id => @forum.id, :forum_topic_id => @topic.id, :forum_post => {:body => "test"}, :fb_sig_user => @user.facebook_id
      assert_response :success
      assert !assigns(:forum).blank?
      assert !assigns(:topic).blank?
      assert !assigns(:post).blank?
      assert flash[:success]
    end
  end

  def test_fail_create
    mock_user_facebooking(@user.facebook_id)
    assert_no_difference ['ForumPost.count'] do
      facebook_post :create, :forum_id => @forum.id, :forum_topic_id => @topic.id, :forum_post => {:body => ""}, :fb_sig_user => @user.facebook_id
      assert_response :success
      assert !assigns(:forum).blank?
      assert !assigns(:topic).blank?
      assert !assigns(:post).blank?
      assert flash[:error]
      assert flash[:error_message]
    end
  end
  
  def test_edit
    @post = @topic.last_post
    facebook_get :edit, :forum_id => @forum.id, :forum_topic_id => @topic.id, :id => @post.id, :fb_sig_user => @post.user.facebook_id
    assert_response :success
    assert_template 'edit'
    assert !assigns(:forum).blank?
    assert !assigns(:topic).blank?
    assert !assigns(:post).blank?
    assert_tag :tag => "form", :attributes => {:action => @controller.facebook_nested_url(facebook_forum_forum_topic_forum_post_path(@forum,@topic,@post))}
    assert_tag :tag => "form", :descendant => { :tag => "textarea", :attributes => { :name => "forum_post[body]" } }
  end
  
  def test_update
    @post = @topic.last_post
    facebook_put :update, :forum_id => @forum.id, :forum_topic_id => @topic.id, :id => @post.id, :fb_sig_user => @post.user.facebook_id, :forum_post => {:body => "EDITED"}
    assert flash[:notice]
    assert !assigns(:post).blank?
    assert_equal 'EDITED', @post.reload.body
  end
end