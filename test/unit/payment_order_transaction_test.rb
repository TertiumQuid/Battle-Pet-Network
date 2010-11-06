require 'test_helper'

class PaymentOrderTransactionTest < ActiveSupport::TestCase
  def setup
    @po = payment_orders(:user_two_pending_po)
  end
  
  def test_response
    mock_merchant
    transaction = @po.transactions.build(:response => @gateway_response)
    assert_equal true, transaction.success
    assert_equal true, transaction.authorization
    assert_not_nil transaction.message
    assert_not_nil transaction.params
  end
end