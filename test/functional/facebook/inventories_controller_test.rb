require 'test_helper'

class Facebook::InventoriesControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    @shop = shops(:first)
    @pet = @shop.pet
    @user = @pet.user           
    @belonging = belongings(:four_grass)
    @params = {:belonging_id => @belonging.id, :cost => 15}
  end
  
  def test_create
    mock_user_facebooking(@user.facebook_id)
    assert_difference ['Inventory.count','@shop.inventories.count'], +1 do
      facebook_post :create, :inventory => @params, :fb_sig_user => @user.facebook_id
      assert_response :success
      assert flash[:notice]
      assert !assigns(:inventory).blank?
    end
  end
  
  def test_fail_create
    mock_user_facebooking(@user.facebook_id)
    @params = {:belonging_id => nil}
    assert_no_difference ['Inventory.count','@shop.inventories.count'] do
      facebook_post :create, :inventory => @params, :fb_sig_user => @user.facebook_id
      assert_response :success
      assert flash[:error]
      assert flash[:error_message]
    end
  end
  
  def test_update
    mock_user_facebooking(@user.facebook_id)
    inventory = @shop.inventories.first
    cost = inventory.cost + 10
    assert_difference 'inventory.reload.cost', +10 do
      facebook_put :update, :inventory => {:cost => cost}, :fb_sig_user => @user.facebook_id, :id => inventory.id
      assert_response :success
      assert flash[:notice]
    end
  end

  def test_fail_update
    mock_user_facebooking(@user.facebook_id)
    inventory = @shop.inventories.first
    cost = -1
    assert_no_difference 'inventory.reload.cost' do
      facebook_put :update, :inventory => {:cost => cost}, :fb_sig_user => @user.facebook_id, :id => inventory.id
      assert_response :success
      assert flash[:error]
      assert flash[:error_message]
    end
  end
  
  def test_destroy
    mock_user_facebooking(@user.facebook_id)
    inventory = @shop.inventories.first
    assert_difference ['Inventory.count','@shop.inventories.count'], -1 do
      facebook_delete :destroy, :inventory => @params, :fb_sig_user => @user.facebook_id, :id => inventory.id
      assert_response :success
      assert flash[:notice]
    end
  end

  def test_purchase
    inventory = @shop.inventories.first
    pet = pets(:siamese)
    pet.update_attribute(:kibble, inventory.cost + 1)
    pet.update_attribute(:level_rank_count, inventory.item.required_rank + 1)

    mock_user_facebooking(pet.user.facebook_id)
    assert_difference 'pet.belongings.count', +1 do    
      assert_difference 'Inventory.count', -1 do          
        facebook_post :purchase, :fb_sig_user => pet.user.facebook_id, :shop_id => @shop.id, :id => inventory.id
        assert_response :success
        assert !assigns(:shop).blank?
        assert !assigns(:inventory).blank?
        assert !assigns(:purchase).blank?
        assert assigns(:purchase_errors).blank?
      end
    end
    assert flash[:success]
  end
  
  def test_fail_purchase
    inventory = @shop.inventories.first
    pet = pets(:siamese)
    pet.update_attribute(:kibble, inventory.cost - 1)
    pet.update_attribute(:level_rank_count, inventory.item.required_rank - 1)
    
    mock_user_facebooking(pet.user.facebook_id)
    assert_no_difference 'pet.belongings.count' do    
      assert_no_difference 'Inventory.count' do    
        facebook_post :purchase, :fb_sig_user => pet.user.facebook_id, :shop_id => @shop.id, :id => inventory.id
        assert_response :success
        assert !assigns(:purchase_errors).blank?
      end
    end
    assert flash[:error]
    assert flash[:error_message]
  end
end