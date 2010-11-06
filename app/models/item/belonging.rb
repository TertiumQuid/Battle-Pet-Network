class Belonging < ActiveRecord::Base
  belongs_to :pet
  belongs_to :item
  
  validates_presence_of :item_id, :pet_id, :source, :status
  validates_inclusion_of :status, :in => %w(active holding expended)
  validates_inclusion_of :source, :in => %w(scavenged purchased gift award inventory)
  
  validate :validates_exclusivity
  after_validation :deactivate_other_gear
  after_create :apply
  
  named_scope :active, :conditions => "status = 'active'"
  named_scope :holding, :conditions => "status = 'holding'"  
  named_scope :battle_ready, :conditions => ["belongings.status = 'active' AND items.item_type IN (?) ", Item::BATTLE_TYPES], 
                             :include => [:item]
  named_scope :sellable, :conditions => ["belongings.status = 'holding'"], 
                          :order => "items.cost DESC"
  named_scope :standards, :conditions => ["items.item_type = 'Standard'"], 
                          :order => "items.cost DESC"
  named_scope :type_is, lambda { |item_type| 
    { :conditions => ["items.item_type = ?", item_type], :include => [:item] }
  }      
                          
  def after_initialize(*args)
    self.status ||= 'holding'
  end
  
  def validates_exclusivity
    return true unless new_record? && item_id && item.exclusive
    errors.add(:item_id, "exclusive item already possessed") if pet.owns_item?(item_id)
  end
  
  def use_item
    success = false
    if item.gear?
      success = update_attribute :status, (active? ? "holding" : "active")
    elsif item.food?
      success = item.eat!(pet)
      success = update_attribute :status, "expended" if success
    elsif item.practice?
      success = item.practice!(pet)
      success = update_attribute :status, "expended" if success
    end
    return success
  end
  
  def apply
    if item.currency?
      pet.update_attribute(:kibble, pet.kibble + item.power)
      update_attribute(:status, "expended")
    end
  end
  
  def deactivate_other_gear
    if item.gear? && errors.empty? && active?
      other = pet.belongings.active.type_is(item.item_type).first
      if other
        other.update_attribute(:status, "holding") 
        other.update_bonus_count_column(-1)
      end
    end
  end
  
  def name
    item ? item.name : ""
  end
  
  def expended?
    status == "expended"
  end
  
  def holding?
    status == "holding"
  end
  
  def active?
    status == "active"
  end

  def update_bonus_count_column(multiply=1)
    bonus = item.power * multiply
    case item.item_type.downcase
      when 'weapon'
        pet.update_power_bonus_count(bonus)
      when 'sensor'
        pet.update_intelligence_bonus_count(bonus)
      when 'mantle'
        pet.update_health_bonus_count(bonus)
      when 'collar'
        pet.update_defense_bonus_count(bonus)
    end
  end
end