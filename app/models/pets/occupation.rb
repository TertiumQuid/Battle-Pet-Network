class Occupation < ActiveRecord::Base
  has_many :pets
  
  named_scope :scavenging, :conditions => "name LIKE 'Scavenging'", :limit => 1  
  named_scope :taming, :conditions => "name LIKE 'Human Taming'", :limit => 1    
  named_scope :ordered, :order => 'name DESC'
  
  validates_inclusion_of :status, :in => ['Prowling','Scavenging','Human Taming','Shopkeeping']
    
  class << self    
    def scavenge!
      scavenging = Occupation.find_by_name("Scavenging", :limit => 1)
      return unless scavenging
    
      pets = Pet.scavenging.all
      pets.each do |pet|
        scavenging.perform_for_pet(pet)
      end
    end    
    
    def tame_humans!
      taming = Occupation.find_by_name("Human Taming", :limit => 1)
      return unless taming
      
      pets = Pet.taming.all
      pets.each do |pet|
        taming.perform_for_pet(pet)
      end
    end
  end
      
  def slug
    name.downcase.gsub(/\s/,'-')
  end
  
  def pet_doing?(pet)
    pet.occupation_id == self.id
  end

  def pet_can?(pet)
    cost > 0 && pet.current_endurance >= cost
  end
  
  def do_for_pet!(pet,subject=nil)
    return false unless pet_can?(pet)
    success = false
    case name
      when 'Human Taming'
        success = tame_human(pet,subject)
        exhaust pet
      when 'Scavenging'  
        success = scavenge_item(pet,subject)
        exhaust pet
    end
    return success
  end
  
  def perform_for_pet(pet)
    success = false
    case name
      when 'Human Taming'
        success = tame_human(pet)
      when 'Scavenging'
        success = scavenge_item(pet)
    end
    return success
  end
  
  def tame_human(pet,human=nil)
    success = Human.finds_human?(pet)
    human = Human.find_random_human(pet,human) if success
    human = human.first if success && human.is_a?(Array)
    success = Tame.pet_tames_human?(pet,human) if success
    success = pet.tames.create(:human => human, :status => 'kenneled') if success
    return success
  end
  
  def scavenge_item(pet,item=nil)
    success = Item.scavenges?(pet)
    item = Item.scavengeable.find_random_item(pet,item) if success
    item = item.first if success && item.is_a?(Array)
    success = pet.belongings.create(:item => item, :source => 'scavenged') if success
    ActivityStream.log! 'items', 'scavenging', pet, item if success
    return success
  end
  
  def forage_item(pet,item=nil)
    success = Item.forages?(pet)
    item = Item.forageable.find_random_item(pet,item) if success
    item = item.first if success && item.is_a?(Array)
    success = pet.belongings.create(:item => item, :source => 'scavenged') if success
    ActivityStream.log! 'items', 'scavenging', pet, item if success
    return success
  end
  
  def exhaust(pet)
    pet.update_attribute(:current_endurance, [pet.current_endurance - cost, 0].max)
  end
end