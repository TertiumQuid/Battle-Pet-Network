class PaymentOrder < ActiveRecord::Base
  has_many :transactions, :class_name => "PaymentOrderTransaction"
  belongs_to :item
  belongs_to :user
  
  attr_accessor :express_token
  
  validates_presence_of :item_id, :user_id, :total
  validates_numericality_of :total, :greater_than_or_equal_to => 1.0
  
  before_validation_on_create :set_total
  
  class << self
    def find_or_initialize_by_user_token(user,token)
      return user.payment_orders.build if token.blank?
      
      details = EXPRESS_GATEWAY.details_for(token)
      
      payment_order_id = details.params["invoice_id"]
      payment_order = user.payment_orders.find_by_id(payment_order_id) || user.payment_orders.build
      
      payment_order.payer_id = details.payer_id
      payment_order.ack = details.params["ack"]
      payment_order.first_name = details.params["first_name"]
      payment_order.middle_name = details.params["middle_name"]
      payment_order.last_name = details.params["last_name"]
      payment_order.email = details.params["payer"]
      payment_order.phone = details.params["phone"]
      payment_order.country = details.params["country"]
      payment_order.city = details.params["city"]
      payment_order.total = details.params["total"]
      payment_order.express_token = token
      
      return payment_order
    end
  end
  
  def price_in_cents
    return item ? (item.cost * 100).round.to_f : 0.0
  end
  
  def set_total
    self.total = price_in_cents
  end
  
  def save_and_purchase
    save! && purchase
  end
  
  def purchase
    response = process_purchase
    transactions.create(:action => "purchase", :amount => price_in_cents, :response => response)
  end

  def process_purchase
    options = {
      :ip => ip_address,
      :token => express_token,
      :shipping => 0,
      :handling => 0,
      :tax => 0,
      :payer_id => payer_id,
      :notify_url => AppConfig.merchant.paypal.notification_url
    }
    EXPRESS_GATEWAY.purchase(price_in_cents, options)
  end
end