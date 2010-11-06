class Action < ActiveRecord::Base
  belongs_to :species
  has_and_belongs_to_many :pets
  has_many :maneuvers
  has_many :breeds, :as => :favorite_action
  has_many :pets, :as => :favorite_action
  
  validates_presence_of :species_id, :action_type, :verb, :power
  validates_numericality_of :power, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 8
  validates_inclusion_of :action_type, :in => %w(offensive defensive)
  
  def slug
    name.downcase.gsub(/\s/,'-')
  end
  
  def endurance_cost
    defensive? ? power : power * 2
  end
  
  def offensive?
    action_type.downcase == "offensive"
  end

  def defensive?
    action_type.downcase == "defensive"
  end
end