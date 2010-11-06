class Shop < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  
  SPECIALTIES = ['Food', 'Kibble', 'Toy', 'Collar', 'Claws', 'Sensors', 'Ornament', 'Mantle', 'Charm', 'Standard']
    
  belongs_to :pet, :include => [:breed]
  has_many :inventories, :validate => true
  
  has_many :sales, :class_name => "ActivityStream", 
                   :as => :indirect_object, 
                   :conditions => "category = 'shopping' AND namespace = 'purchase'",
                   :order => "activity_streams.created_at DESC"
  
  accepts_nested_attributes_for :inventories, :allow_destroy => false
  
  validates_presence_of :pet_id, :name, :status, :specialty, :inventories_count
  validates_length_of :name, :in => 3..128
  validates_inclusion_of :specialty, :in => SPECIALTIES
  
  after_create :set_shopkeeper, :log_opening
      
  named_scope :include_pet, :include => [:pet]
  named_scope :specialists, lambda { |specialty|  { :conditions => ["specialty LIKE ? ", specialty], :limit => 10, :order => 'inventories_count DESC' } }
  named_scope :has_item_named, lambda { |name|
    {
      :conditions => ["items.name LIKE ?", "%#{name}%"],
      :joins => ["INNER JOIN inventories ON inventories.shop_id = shops.id \
                  INNER JOIN items ON items.id = inventories.item_id"]
    }
  }
  named_scope :has_type_in_stock, lambda { |item_type| 
    { 
      :conditions => ["items.item_type = ?", item_type],
      :joins => ["INNER JOIN inventories ON inventories.shop_id = shops.id \
                  INNER JOIN items ON items.id = inventories.item_id" ]
    }
  }
  
  cattr_reader :per_page
  @@per_page = 20
  
  validate :validates_max_inventory  
  
  def after_initialize(*args)
    self.status ||= 'active'
    self.inventories_count ||= 0
  end
  
  def validates_max_inventory
    errors.add_to_base("inventory limit reachedry") if inventories.size > max_inventory
  end
  
  def max_inventory
    pet ? pet.total_intelligence : 0
  end
  
  def last_restock
    last_restock_at ? "#{time_ago_in_words(last_restock_at)} ago" : "unstocked"
  end
  
  def set_shopkeeper
    pet.update_attribute(:shop_id,id) if pet.shop_id.blank?
  end
  
  def log_opening
    ActivityStream.log! 'shopping', 'opened', pet, self
  end
end