require 'test_helper'

class Facebook::PaymentOrdersControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    mock_merchant
    @item = items(:kibble_pack)
    @user = users(:two)
    @params = {:item_id => @item.id}
  end
  
  def test_create
    mock_user_facebooking(@user.facebook_id)
    assert_difference ['PaymentOrder.count','@user.payment_orders.count'], +1 do
      facebook_post :create, :payment_order => @params, :fb_sig_user => @user.facebook_id
      assert_response :success
    end
  end
  
  def test_fail_create
    assert_no_difference ['PaymentOrder.count','@user.payment_orders.count'] do
      @params = {}
      facebook_post :create, :payment_order => @params, :fb_sig_user => @user.facebook_id
      assert_response :success
    end    
    assert flash[:error]
    assert flash[:error_message]
  end  
end