class Hunter < ActiveRecord::Base
  belongs_to :hunt
  belongs_to :pet
  belongs_to :strategy
  
  accepts_nested_attributes_for :strategy, :allow_destroy => false
  
  validates_presence_of :pet_id, :outcome, :strategy
  validates_inclusion_of :outcome, :in => %w(undecided won lost deadlocked)
  validates_associated :strategy
  
  before_validation_on_create :set_outcome  
  validate :validates_pet_strategy

  def after_initialize(*args)
    self.outcome ||= 'undecided'
  end
        
  def validates_pet_strategy
    errors.add(:strategy_id, "unknown strategy") if strategy && pet_id != strategy.combatant_id
  end
  
  def name
    pet.blank? ? nil : pet.name
  end
  
  def set_outcome
    self.outcome = "won"
  end
end