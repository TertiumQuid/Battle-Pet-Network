class Inventory < ActiveRecord::Base
  belongs_to :shop, :validate => true, :counter_cache => true
  belongs_to :item
  
  attr_accessor :belonging_id
  
  validates_presence_of :belonging_id, :if => Proc.new { |i| i.new_record? }
  validates_presence_of :shop_id, :cost
  validates_numericality_of :cost, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 1000000
    
  cattr_reader :per_page
  @@per_page = 12
  
  validate :validates_belonging
  after_create :remove_belonging
  after_create :log_stock
  
  named_scope :top, :limit => 15
  
  def after_initialize(*args)
    if item_id.blank? && !belonging_id.blank?
      self.item_id = Belonging.find(belonging_id).item_id
    end
  end

  def validates_belonging
    return if belonging_id.blank? || shop_id.blank?
    errors.add(:item_id, "shop owner isn't holding belonging") if shop.pet.belongings.holding.find_by_id(belonging_id).blank?
  end
  
  def remove_belonging
    return if belonging_id.blank? || shop_id.blank?
    shop.pet.belongings.destroy(belonging_id)
  end
  
  def unstock!
    pet = shop.pet
    pet.belongings.create(:item => item, :status => "holding", :source => "inventory")
    ActivityStream.log! 'shopping', 'unstocking', pet, item, shop.pet
    self.destroy 
    return true
  end
  
  def purchase_for!(pet)
    belonging = pet.belongings.build(:item => item, :source => 'purchased', :status => 'holding')
    belonging.errors.add_to_base("too expensive") if pet.kibble < cost
    belonging.errors.add_to_base("too high level for pet") if pet.level_rank_count < item.required_rank
    
    if belonging.errors.empty? && belonging.save
      pet.update_attribute(:kibble, pet.kibble - cost)
      shop.pet.update_attribute(:kibble, shop.pet.kibble + cost)
      ActivityStream.log! 'shopping', 'purchase', pet, item, shop
      self.destroy
    end
    return belonging
  end
  
  def log_stock
    ActivityStream.log! 'shopping', 'stocking', shop.pet, item
  end
end