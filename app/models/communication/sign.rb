class Sign < ActiveRecord::Base
  SIGNINGS = ['play', 'hiss', 'purr', 'groom']
  
  belongs_to :sender, :class_name => "Pet", :foreign_key => "sender_id"
  belongs_to :recipient, :class_name => "Pet", :foreign_key => "recipient_id"
  
  validates_presence_of :sign_type, :sender_id, :recipient_id
  validates_inclusion_of :sign_type, :in => SIGNINGS
  
  validate :validates_exchange_cost, :validates_once_per_day
  
  after_create :stat_exchange
  
  class << self
    def signs_with(sender,recipient)
      SIGNINGS
    end
    
    def play!(sender,recipient)
      sender.update_attribute(:current_endurance, [sender.current_endurance - 3, 0].max)
      recipient.update_attribute(:current_endurance, [recipient.current_endurance + 3, recipient.endurance].min)
    end

    def hiss!(sender,recipient)
      sender.update_attribute(:current_endurance, [sender.current_endurance - 5, 0].max)
      recipient.update_attribute(:current_endurance, [recipient.current_endurance - 5, 0].max)
    end

    def purr!(sender,recipient)
      sender.update_attribute(:current_endurance, [sender.current_endurance - 1, 0].max)
      recipient.update_attribute(:current_endurance, [recipient.current_endurance + 1, recipient.endurance].min)
    end

    def groom!(sender,recipient)
      sender.update_attribute(:current_endurance, [sender.current_endurance - 3, 0].max)
      recipient.update_attribute(:current_health, [recipient.current_health + 1, recipient.health].min)
    end
  end
  
  def effects
    return nil unless sender && recipient
    return case sign_type
    when 'play'
      "#{recipient.name} recovered 3 endurance and #{sender.name} spent 3 endurance."
    when 'hiss'
      "#{recipient.name} lost 5 endurance and #{sender.name} spent 5 endurance."
    when 'purr'
      "#{recipient.name} recovered 1 endurance and #{sender.name} spent 1 endurance."
    when 'groom'
      "#{recipient.name} recovered 1 health and #{sender.name} spent 3 endurance."
    end
  end
  
  def verb
    return case sign_type
    when 'play'
      'played with'
    when 'hiss'
      'hissed at'
    when 'purr'
      'purred to'
    when 'groom'
      'groomed'
    end
  end

  def validates_exchange_cost
    cost = case sign_type
    when 'play'
      3
    when 'hiss'
      5
    when 'purr'
      1
    when 'groom'
      3
    end
    errors.add(:sender_id, "not enough endurance") if sender && sign_type && sender.current_endurance < cost
  end

  def validates_once_per_day
    existing = Sign.exists?(["created_at >= (created_at >= DATE_ADD(NOW(), INTERVAL -24 HOUR)) AND sender_id = ? AND recipient_id = ?", 
                            sender_id,
                            recipient_id])
    errors.add(:recipient_id, "already sent a sign today") if existing
  end

  def stat_exchange
    case sign_type
      when 'play'
        Sign.play!(sender,recipient)
      when 'hiss'
        Sign.hiss!(sender,recipient)
      when 'purr'
        Sign.purr!(sender,recipient)
      when 'groom'
        Sign.groom!(sender,recipient)
    end
  end
end