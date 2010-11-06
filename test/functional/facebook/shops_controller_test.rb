require 'test_helper'

class Facebook::ShopsControllerTest < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    @shop = shops(:first)
    @user = users(:three)
    @pet = @user.pet
    @params = {:pet_id => @pet.id, :name => 'test shop', :specialty => 'Food'}
  end

  def test_index
    mock_user_facebooking
    facebook_get :index, :fb_sig_user => nil
    assert_response :success
    assert_template 'index'
    assert !assigns(:shops).blank?
    assert !assigns(:shop_filter_types).blank?
    assert !assigns(:filters).blank?
    assert_tag :tag => "table", :attributes => { :id => "shops" }, :descendant => { :tag => "label", :attributes => { :class => "shop" }}
    assert_tag :tag => "table", :attributes => { :id => "shops" }, :descendant => { :tag => "label", :attributes => { :class => "shopkeeper" }}
    assert_no_tag :tag => "a", :attributes => { :href => @controller.facebook_nested_url(new_facebook_shop_path) }
  end
  
  def test_with_with_pet
    pet = pets(:siamese)
    user = pet.user
    mock_user_facebooking(user.facebook_id)
    facebook_get :index, :fb_sig_user => user.facebook_id
    assert_response :success
    assert_template 'index'
    assert_tag :tag => "a", :attributes => { :href => @controller.facebook_nested_url(new_facebook_shop_path) }
  end
  
  def test_index_search
    phrase = 'grass'
    mock_user_facebooking
    facebook_get :index, :fb_sig_user => nil, :search => phrase
    assert !assigns(:shops).blank?
    assigns(:shops).each do |shop|
      assert shop.inventories.map(&:item).map(&:name).join(' ').downcase.include?(phrase.downcase)
    end
  end
  
  def test_index_filter
    filter = 'Food'
    mock_user_facebooking
    facebook_get :index, :fb_sig_user => nil, :filter => filter
    assert !assigns(:shops).blank?
    assigns(:shops).each do |shop|
      if shop.inventories.size > 0
        assert shop.inventories.map(&:item).map(&:item_type).join(' ').downcase.include?(filter.downcase)
      end
    end
  end

  def test_get_shop
    fbid = users(:three).facebook_id
    mock_user_facebooking(fbid)
    facebook_get :show, :id => @shop.id, :fb_sig_user => fbid
    assert_response :success
    assert_template 'show'
    assert assigns(:shop)
    assert assigns(:inventory)
    assert_tag :tag => "table", :attributes => { :class => "shopkeeper" }
    assert_tag :tag => "span", :attributes => { :class => "shopping-button" }
  end

  def test_new
    user = users(:three)
    pet = user.pet
    pet.update_attribute(:kibble, AppConfig.shops.opening_fee)

    mock_user_facebooking(user.facebook_id)
    facebook_get :new, :fb_sig_user => user.facebook_id
    assert_response :success
    assert_template 'new'
    assert !assigns(:shop).blank?
    assert !assigns(:shop).pet.blank?
    assert_tag :tag => "form", :attributes => { :method => 'post', :action => @controller.facebook_nested_url(new_facebook_shop_path) }
    assert_tag :tag => "form", :descendant => { :tag => "table", :attributes => { :class => "form" } }
    assert_tag :tag => "form", :descendant => { :tag => "table", :attributes => { :id => "inventory-picker" } }
    assert_tag :tag => "form", :descendant => { :tag => "tr", :attributes => { :class => "inventory-item" } }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => { :name => "shop[specialty]" } }
    assert_tag :tag => "form", :descendant => { :tag => "input", :attributes => { :type => "submit" } }
  end
  
  def test_new_without_kibble_or_items
    user = users(:three)
    pet = user.pet
    Belonging.destroy_all
    mock_user_facebooking(user.facebook_id)
    facebook_get :new, :fb_sig_user => user.facebook_id
    assert_template 'new'
    assert_no_tag :tag => "form", :descendant => { :tag => "input", :attributes => { :type => "submit" } }
    assert_no_tag :tag => "form", :descendant => { :tag => "table", :attributes => { :id => "inventory-picker" } }
  end
  
  def test_create
    mock_user_facebooking(@user.facebook_id)
    assert_difference 'Shop.count', +1 do
      facebook_post :create, :shop => @params, :fb_sig_user => @user.facebook_id
      assert_response :success
      assert !assigns(:shop).blank?
    end  
    assert flash[:success]
  end
  
  def test_fail_create
    @params.delete(:name)
    mock_user_facebooking(@user.facebook_id)
    assert_no_difference 'Shop.count' do
      facebook_post :create, :shop => @params, :fb_sig_user => @user.facebook_id
      assert_response :success
      assert !assigns(:shop).blank?
    end  
    assert flash[:error]
    assert flash[:error_message]
  end
  
  def test_edit
    fbid = @shop.pet.user.facebook_id
    mock_user_facebooking(fbid)
    facebook_get :edit, :fb_sig_user => fbid
    assert_response :success
    assert_template 'edit'
    assert !assigns(:shop).blank?
    assert !assigns(:inventory).blank?
    assert !assigns(:belongings).blank?
    assert_tag :tag => "form", :attributes => { :id => 'shop-form' }
    assert_tag :tag => "form", :attributes => { :id => 'inventory-form' }
    assert_tag :tag => "table", :attributes => { :class => 'item dotbox' }
  end
end