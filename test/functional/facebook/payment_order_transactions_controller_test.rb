require 'test_helper'

class Facebook::PaymentOrderTransactionsControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    @po = payment_orders(:user_two_pending_po)
    @user = @po.user
  end
  
  def test_new
    mock_merchant
    mock_user_facebooking(@user.facebook_id)
    assert_difference ['PaymentOrderTransaction.count','@po.transactions.count'], +1 do
      facebook_get :new, :token => @po.id, :fb_sig_user => @user.facebook_id, :payment_order_id => @po.id
      assert_response :success
      assert_template 'new'
      assert !assigns(:po).blank?
      assert flash[:success]
    end
  end
end