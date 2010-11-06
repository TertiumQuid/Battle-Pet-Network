require 'test_helper'

class Facebook::ItemsControllerTest < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    @user = users(:three)
    @fbid = @user.facebook_id
    @item = items(:cat_grass)
  end
  
  def test_index
    mock_user_facebooking
    facebook_get :index, :fb_sig_user => nil
    assert_response :success
    assert_template 'index'
    assert_tag :tag => "table", :attributes => { :class => "item-store" }
    assert_tag :tag => "span", :attributes => { :class => "shopping-button" }
  end
  
  def test_store
    mock_user_facebooking
    facebook_get :store, :fb_sig_user => nil, :id => 'Food'
    assert_response :success
    assert_template 'store'
    assert !assigns(:items).blank?
    assert !assigns(:shops).blank?
    assert_tag :tag => "h3", :attributes => { :id => "food-store-title" }
    assert_tag :tag => "table", :attributes => { :id => "shops" }
    assert_no_tag :tag => "span", :attributes => { :class => "shopping-button" }
  end
  
  def test_store_with_pet
    fbid = users(:three).facebook_id
    mock_user_facebooking(fbid)
    facebook_get :store, :fb_sig_user => fbid, :id => 'Food'
    assert_response :success
    assert_template 'store'
    assert !assigns(:items).blank?
    assert_tag :tag => "h3", :attributes => { :id => "food-store-title" }
    assert_tag :tag => "span", :attributes => { :class => "shopping-button" }
  end
  
  def test_purchase
    assert_difference '@user.pet.belongings.count', +1 do    
      mock_user_facebooking(@fbid)
      facebook_post :purchase, :fb_sig_user => @fbid, :id => @item.id
      assert_response :success
      assert assigns(:purchase_errors).blank?
    end
    assert flash[:success]
  end
  
  def test_fail_purchase
    @user.pet.update_attribute(:kibble, @item.cost - 1)
    
    assert_no_difference '@user.pet.belongings.count' do    
      mock_user_facebooking(@fbid)
      facebook_post :purchase, :fb_sig_user => @fbid, :id => @item.id
      assert_response :success
      assert assigns(:purchase_errors)
    end
    assert flash[:error]
    assert flash[:error_message]
  end
  
  def test_premium
    mock_user_facebooking(@user.facebook_id)
    facebook_get :premium, :fb_sig_user => @user.facebook_id
    assert_response :success
    assert_template 'premium'
    assert !assigns(:items).blank?
    assert !assigns(:payment_order).blank?
    assert_tag :tag => "table", :attributes => { :class => "item" }
    assert_tag :tag => "form", :attributes => { :class => "premium-form" }, :descendant => {
      :tag => "input", :attributes => { :type => "image" }
    }
  end
end