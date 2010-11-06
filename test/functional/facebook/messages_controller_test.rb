require 'test_helper'

class Facebook::MessagesControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def test_inbox
    mock_user_facebooking(users(:three).facebook_id)
    facebook_get :inbox, :fb_sig_user => users(:three).facebook_id
    assert_response :success
    assert_template 'inbox'
    assert !assigns(:messages).blank?
  end

  def test_outbox
    mock_user_facebooking(users(:two).facebook_id)
    facebook_get :outbox, :fb_sig_user => users(:two).facebook_id
    assert_response :success
    assert_template 'outbox'
    assert !assigns(:messages).blank?
  end
  
  def test_show_message
    message = messages(:first)
    mock_user_facebooking(users(:two).facebook_id)

    facebook_get :show, :fb_sig_user => users(:two).facebook_id, :id => message.id
    assert_response :success
    assert_template 'show'
    assert assigns(:message)
    assert_tag :tag => "table", :attributes => {:class => "message"}, :descendant => {
      :tag => "a", :content => "Reply",
      :tag => "a", :content => "Delete"
    }
  end
    
  def test_new_message
    mock_user_facebooking(users(:two).facebook_id)
    facebook_get :new, :fb_sig_user => users(:two).facebook_id
    assert_response :success
    assert_template 'new'
    assert !assigns(:message).blank?
    assert_tag :tag => "form", 
      :attributes => {:action => "/pets/home/messages", :method => "post"}, 
      :descendant => { 
        :tag => "input", :attributes => { :name => "message[recipient_name]", :type => "text" },
        :tag => "input", :attributes => { :name => "message[subject]", :type => "text" },
        :tag => "textarea", :attributes => { :name => "message[body]" },
        :tag => "input", :attributes => { :type => "submit" }
    }
  end
  
  def test_new_message_with_recipient
    recipient = users(:three).pet
    mock_user_facebooking(users(:two).facebook_id)
    facebook_get :new, :fb_sig_user => users(:two).facebook_id, :pet_id => recipient.id
    assert_response :success
    assert_template 'new'
    assert !assigns(:message).blank?
    assert !assigns(:recipient).blank?
    assert_tag :tag => "input", :attributes => { :type => "hidden", :name => "message[recipient_id]", :value => "#{recipient.id}"}
    assert_no_tag :tag => "input", :attributes => { :type => "text", :name => "message[recipient_name]" }    
  end
  
  def test_create_message
    mock_user_facebooking(users(:two).facebook_id)
    pet = users(:two).pet
    message_params = {:recipient_name=>"pearl", :subject=>'TEST', :body=>'TEST\nTEST\nTEST'}
    assert_difference ['Message.count','pet.reload.outbox.size'], +1, "message should create normally" do
      facebook_post :create, :message => message_params, :fb_sig_user => users(:two).facebook_id
      assert_response :success
      assert assigns(:message)
      assert flash[:success]
    end
  end
  
  def test_destroy
    message = messages(:first)
    pet = message.recipient
    mock_user_facebooking(pet.user.facebook_id)
    facebook_delete :destroy, :id => message.id, :fb_sig_user => pet.user.facebook_id
    assert_equal 'deleted', message.reload.status
    assert flash[:notice]
  end
end