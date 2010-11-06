require 'test_helper'

class PaymentOrderTest < ActiveSupport::TestCase
  def setup
    @item = items(:kibble_pack)
    @user = users(:two)
    @po = payment_orders(:user_two_pending_po)
    @new_po = @user.payment_orders.new(:item => @item, :total => 1.00)
  end
  
  def test_price_in_cents
    po = PaymentOrder.new(:item => @item)
    assert_not_equal @item.cost.to_s, po.price_in_cents.to_s
    assert po.price_in_cents.to_s.match /\d+\.\d+$/
  end 
  
  def test_set_total
    po = @user.payment_orders.new(:item => @item)
    po.save
    assert_equal po.price_in_cents, po.total
  end  
  
  def test_find_or_initialize_by_user_token
    mock_merchant
    po = PaymentOrder.find_or_initialize_by_user_token(@user,@po.id)
    assert !po.new_record?
    assert_equal @token_details.params["ack"], po.ack
    assert_equal @token_details.params["first_name"], po.first_name
    assert_equal @token_details.params["middle_name"], po.middle_name
    assert_equal @token_details.params["last_name"], po.last_name
    assert_equal @token_details.params["payer"], po.email
    assert_equal @token_details.params["phone"], po.phone
    assert_equal @token_details.params["country"], po.country
    assert_equal @token_details.params["city"], po.city
    assert_not_nil po.total
    assert_not_nil po.express_token
  end
  
  def test_find_or_initialize_by_bad_token
    mock_merchant
    PaymentOrder.destroy_all
    @new_po.save
    [nil,"badtokencode"].each do |token|
      po = PaymentOrder.find_or_initialize_by_user_token(@user,token)
      assert po.new_record?
    end
  end
end