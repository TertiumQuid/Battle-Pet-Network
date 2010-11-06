class PaymentOrderTransaction < ActiveRecord::Base
  belongs_to :payment_order
  serialize :params
    
  validates_presence_of :payment_order_id, :success
  
  def after_initialize(*args)
    self.success ||= false
  end 
  
  def response=(res)
    self.success = res.success?
    self.authorization = res.authorization
    self.message = res.message
    self.params = res.params
  rescue ActiveMerchant::ActiveMerchantError => e
    self.success = false
    self.authorization = nil
    self.message = e.message
    self.params = {}
  end  
end