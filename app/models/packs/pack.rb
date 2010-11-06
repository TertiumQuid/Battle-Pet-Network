class Pack < ActiveRecord::Base
  KIBBLE_CONTRIBUTIONS = [25,50,100,200,300,400,500,1000]

  belongs_to :founder, :class_name => "Pet"
  belongs_to :leader, :class_name => "Pet"
  belongs_to :standard, :class_name => "Item", :select => 'id, name, description, power, required_rank, item_type'
  
  has_many :pack_members, :order => 'pack_members.position, pack_members.created_at', :include => {:pet => [:breed]}
  has_many :pets, :through => :pack_members
  has_many :spoils, :include => [:item], :order => 'items.cost DESC'

  before_validation_on_create :set_leader
  before_update :contribute_kibble
  after_create :update_founder, :log_founding
  
  validates_presence_of :founder_id, :standard_id, :name, :kibble, :status
  validates_length_of :name, :within => 3..64
  validates_numericality_of :kibble, :greater_than_or_equal_to => 0
  validates_inclusion_of :status, :in => %w(active disbanded insolvent)
  validate :validates_founder, :validates_founding_fee, :validates_standard
  
  named_scope :include_pack_members, :include => {:pack_members => :pet}
  named_scope :active, :conditions => "packs.status = 'active' AND leader_id IS NOT NULL"
  named_scope :credited, :conditions => "packs.status <> 'disbanded'"

  attr_accessor :kibble_contribution
  
  class << self
    def recover!
      Pack.active.include_pack_members.all.each do |pack|
        bonus = pack.membership_bonus
        connection.execute "UPDATE pets " +
          "SET current_endurance = CASE " +
          "  WHEN current_endurance + #{bonus} <= endurance " +
          "  THEN current_endurance + #{bonus} " +
          "  ELSE endurance END " +
          " WHERE pack_id = #{pack.id} " +
          " AND current_endurance < #{bonus}; "
      end
    end
    
    def pay_dues!
      Pack.credited.include_pack_members.all.each do |pack|
        dues = pack.membership_dues
        if pack.kibble < dues
          pack.update_attribute(:status, 'insolvent')
          ActivityStream.log! 'packs', 'unpaid-dues', pack
        else
          pack.update_attributes(:status => 'active', :kibble => (pack.kibble - dues))
          ActivityStream.log! 'packs', 'paid-dues', pack
        end
      end  
    end
  end  
  
  def after_initialize(*args)
    self.status ||= 'active'
    self.kibble ||= 0
  end
  
  def validates_founder
    errors.add(:founder_id, "already pack member") if founder && founder.pack_id
  end
  
  def validates_standard
    errors.add(:standard_id, "not in founders possession") if standard_id && founder_id && !founder.belongings.map(&:item_id).include?(standard.id)
  end
  
  def validates_founding_fee
    errors.add(:kibble, "cannot pay founding fee") if founder && founder.kibble < AppConfig.packs.founding_fee
  end
  
  def is_leader?(pet)
    position_for(pet) == "leader"
  end

  def set_leader
    self.leader_id = self.founder_id
  end
  
  def contribute_kibble
    self.kibble = kibble + kibble_contribution unless kibble_contribution.blank?
  end
  
  def update_founder
    founder.update_attribute(:pack_id, self.id)
  end
  
  def battle_record
    wins = pets.sum(:wins_count)
    loses = pets.sum(:loses_count)
    draws = pets.sum(:draws_count)
    return "#{wins}/#{loses}/#{draws}"
  end

  def membership_bonus
    return 0 if pack_members.size < 2 
    
    total_levels = pets.sum(:level_rank_count)
    return AppConfig.packs.member_bonus_modifier * total_levels
  end
  
  def membership_dues
    pack_members.size * AppConfig.packs.member_dues
  end
  
  def position_for(pet)
    return "leader" if pet.id == self.leader_id
    
    pack_members.each do |m|
      return m.position if m.pet_id == pet.id
    end
    return nil
  end
  
  def disbanded?
    status == "disbanded"
  end
  
  def invite_membership(sender,invitee)
    body = "#{sender.name} has invited you to join their pack #{name}."
    message = sender.outbox.new(:subject => "Pack Member Invite", :body => body, :recipient => invitee)
    if sender.pack_id != id
      message.errors.add(:sender_id, "can only invite to own pack")
      return message
    elsif !invitee.pack_id.blank?
      message.errors.add(:recipient_id, "pet already a pack member")
      return message
    else
      message.save
    end
    return message
  end
  
  def disband!
    leader.update_attribute(:kibble, leader.kibble + kibble) unless leader_id.blank?
    update_attributes(:kibble => 0, :status => 'disbanded')
    pack_members.update_all( "status = 'disbanded'" )
    Pet.update_all( "pack_id = NULL", "pack_id = #{id}" )
    return true
  end
  
  def log_founding
    ActivityStream.log! 'packs', 'founded', founder, self
  end
end