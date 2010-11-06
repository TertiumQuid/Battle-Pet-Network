class Hunt < ActiveRecord::Base
  include Combat
  serialize :logs
  
  belongs_to :sentient
  has_many :hunters
  
  accepts_nested_attributes_for :hunters, :allow_destroy => false
  
  after_create :depopulate
  after_create :log_hunt
  
  validates_presence_of :sentient_id, :status
  validates_presence_of :hunters
  validates_inclusion_of :status, :in => %w(gathering started ended)
  validates_associated :hunters
    
  validate :validates_required_rank, :validates_population
  
  
  def after_initialize(*args)
    self.status ||= 'started'
    self.logs ||= Combat::CombatLogger::LOG_STRUCT
  end
  
  def validates_required_rank
    return if sentient.blank? || hunters.blank?
    hunters.each do |h|
      errors.add(:sentient_id, "required level too high") if h.pet.level_rank_count < sentient.required_rank
    end
  end
  
  def validates_population
    return if sentient.blank? || sentient.population > 0
    errors.add(:sentient_id, 'currently depopulated')
  end
  
  def hunter
    if hunters.size == 1
      return hunters.first
    elsif hunters.size > 1
      return hunters
    end
  end
  
  def set_outcome
    hunters.each do |h|
      if combatant_defeated?(sentient) && !combatant_defeated?(h.pet)
        h.outcome = "won"
      elsif !combatant_defeated?(sentient) && combatant_defeated?(h.pet)
        h.outcome = "lost"
      elsif combatant_defeated?(sentient) && combatant_defeated?(h.pet)        
        h.outcome = "deadlocked"
      end
    end
    self.status = "ended"
  end
  
  def award!
    hunters.each do |h|
      if h.outcome == "won"
        h.pet.update_attribute(:kibble, h.pet.kibble + sentient.kibble) 
        log_kibble(h.pet,sentient.kibble)
      end
    end
  end
  
  def depopulate
    hunters.each do |h|
      if h.outcome == "won"
        Sentient.find(sentient).update_attribute(:population, [sentient.population - 1, 0].max)
        break;
      end
    end
  end
  
  def log_hunt
    ActivityStream.log! 'hunting','hunted', hunter.pet, sentient, self
  end
end