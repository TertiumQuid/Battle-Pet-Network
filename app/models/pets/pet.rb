class Pet < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include Pet::ProfileCacheColumns
  
  SELECT_BASICS = "id,status,kibble,experience,level_rank_count,breed_id"
  
  belongs_to :occupation, :foreign_key => "occupation_id", :select => "id,name,cost" 
  belongs_to :breed, :foreign_key => "breed_id", :select => "id,name,favorite_action_id,species_id"
  belongs_to :level
  belongs_to :favorite_action, :class_name => "Action"
  belongs_to :shop  
  belongs_to :pack, 
              :select => "id, name, status, kibble, created_at, standard_id, leader_id", 
              :include => {:standard => {},:pack_members => {:pet => :breed}}
  belongs_to :user, :foreign_key => "user_id"
  has_one :biography

  has_many :tames, :include => [:human]
    
  has_many :belongings, :include => [:item]
  has_many :hunters, :include => [:hunt], :order => 'hunts.created_at DESC'
  has_many :inbox, :class_name => "Message", :foreign_key => "recipient_id", :order => 'created_at DESC'
  has_many :outbox, :class_name => "Message", :foreign_key => "sender_id", :order => 'created_at DESC'
  has_many :signs, :class_name => "Sign", 
                   :foreign_key => "recipient_id", 
                   :conditions => 'created_at >= DATE_ADD(NOW(), INTERVAL -72 HOUR)',
                   :order => 'created_at ASC'
  has_many :signings, :class_name => "Sign", 
                      :foreign_key => "sender_id", 
                      :conditions => 'created_at >= DATE_ADD(NOW(), INTERVAL -24 HOUR)',
                      :order => 'created_at ASC'
  has_many :strategies, :as => :combatant, :dependent => :destroy
  has_and_belongs_to_many :actions, :order => "action_type DESC, power ASC"
  
  has_many :challenges, :finder_sql => '#{id} IN (attacker_id, defender_id) ', :order => "created_at DESC" do
    def attacking
      all :conditions => "#{proxy_owner.id} = attacker_id"
    end
    def defending
      all :conditions => "#{proxy_owner.id} = defender_id"
    end
    def responding_to(id)
      all(:conditions => ["? = id",id],:limit=>1).first
    end
    def recent
      all(:conditions => "created_at >= DATE_ADD(NOW(), INTERVAL -7 DAY)")
    end
    def wins
      all :conditions => "battles.created_at >= DATE_ADD(NOW(), INTERVAL -7 DAY) AND #{proxy_owner.id} = battles.winner_id", :joins => "INNER JOIN battles ON battles.challenge_id = challenges.id"
    end
  end
  
  validates_presence_of :name, :breed_id, :status, :current_health, :current_endurance, :health, :endurance,
                        :power, :intelligence, :fortitude, :affection, :experience, :kibble, :occupation_id,
                        :wins_count, :loses_count, :draws_count, :level_rank_count
  validates_length_of :name, :within => 3..64
  validates_length_of :slug, :within => 3..8, :allow_blank => true
  validates_numericality_of :kibble, :greater_than_or_equal_to => 0
  validates_numericality_of :experience, :greater_than_or_equal_to => 0
  validates_inclusion_of :status, :in => %w(active retired)
  
  before_validation_on_create :populate_from_breed, :set_slug, :set_level
  after_create :set_user
  after_create :set_actions

  named_scope :active, :conditions => "status = 'active'"
  named_scope :scavenging, :conditions => "occupations.name = 'Scavenging'", :include => [:occupation]
  named_scope :taming, :conditions => "occupations.name = 'Human Taming'", :include => [:occupation]  
  named_scope :include_user, :include => [:user]
  named_scope :include_signs, :include => [:signs]
  named_scope :searching, lambda { |term| 
    { :conditions => ["slug LIKE ? OR name LIKE ?", "%#{term}%", "%#{term}%"] }
  }
  named_scope :online, :conditions => "users.current_login_at >= DATE_ADD(NOW(), INTERVAL -15 MINUTE)",  
                       :joins => "INNER JOIN users ON pets.user_id = users.id" ,
                       :order => "users.current_login_at DESC ",
                       :limit => 20
  
  class << self
    def recover!
      connection.execute "UPDATE pets " +
        "SET current_health = health, " +
        "current_endurance = CASE " +
        "  WHEN current_endurance + fortitude <= endurance " +
        "  THEN current_endurance + fortitude " +
        "  ELSE endurance END " +
        "  WHERE current_endurance < endurance; "
    end
  end  
  
  def after_initialize(*args)
    self.status ||= 'active'
    self.kibble ||= 0
    self.experience ||= 0
    self.wins_count ||= 0
    self.loses_count ||= 0
    self.draws_count ||= 0
    self.level_rank_count ||= 1
    set_occupation
  end  
  
  def populate_from_breed
    return if breed_id.blank?
    inheritable = Breed.find_by_id(breed_id)
    
    self.current_health = self.health = inheritable.health
    self.current_endurance = self.endurance = inheritable.endurance
    self.power = inheritable.power
    self.intelligence = inheritable.intelligence
    self.fortitude = inheritable.fortitude
    self.affection = inheritable.affection
  end
  
  def breed_name
    breed_id ? breed.name : ''
  end
  
  def max_actions
    total_intelligence
  end
  
  def max_tames
    total_affection
  end
  
  def total_affection
    affection + affection_bonus_count
  end
  
  def total_power
    power + power_bonus_count
  end
  
  def total_health
    health + health_bonus_count
  end
  
  def total_endurance
    endurance + endurance_bonus_count
  end
  
  def total_fortitude
    forititude + fortitude_bonus_count
  end
  
  def total_intelligence
    intelligence + intelligence_bonus_count
  end
  
  def total_defense
    defense_bonus_count
  end
  
  def battles_count
    wins_count + loses_count + draws_count
  end
  
  def battle_record
    return "#{wins_count}/#{loses_count}/#{draws_count}"
  end
  
  def gear_list
    return belongings.battle_ready.map(&:name).join(", ")
  end
  
  def favorite_actions
    if breed.favorite_action_id == favorite_action_id
      text = "constantly #{favorite_action.name}"
    else
      text = "#{breed.favorite_action.name}"
      text = "#{text} and #{favorite_action.name}" unless favorite_action_id.blank?
    end
    return text
  end
  
  def last_seen
    return nil unless user
    
    seen_at = user.current_login_at || user.last_login_at
    return seen_at
  end  
  
  def slave_earnings
    earnings = 0
    tames.enslaved.each do |slave|
      earnings = earnings + slave.human.power
    end
    return earnings * AppConfig.humans.slavery_earnings_multiplier
  end
  
  def prowling?
    occupation_id && occupation.name.downcase == "prowling"
  end
  
  def owns_item?(item_id)
    return belongings.collect(&:item_id).include?(item_id)
  end
  
  def update_occupation!(occupation_id)
    update_attribute(:occupation_id, occupation_id)
  end
  
  def update_favorite_action!(action_id)
    if favorite_action_id.blank?
      return update_attribute(:favorite_action_id, action_id)
    else
      errors.add(:favorite_action_id, "favorite action has already been chosen")
      return false
    end
  end

  def award_experience!(exp)
    self.experience = experience + exp
    next_level = level.next_level
    advance_level(next_level) if experience >= next_level.experience
    save
  end
  
  def advance_level(lvl)
    lvl.advance(self)
  end
  
  def retire!
    return update_attribute(:status, "retired") && User.find(user_id).update_attribute(:pet_id, nil)
  end

  def set_occupation
    self.occupation_id ||= Occupation.find_by_name("Prowling").id
  end
  
  def set_slug
    self.slug ||= truncate(name, :length => 8).parameterize unless name.blank?
  end
  
  def set_level
    return if breed_id.blank?
    self.level_id = breed.levels.first.id
  end
  
  def set_user
    User.find(user).update_attribute(:pet_id, self.id) unless user.blank?
  end
  
  def set_actions
    breed.species.actions.each do |action|
      self.actions << action
    end
  end
end