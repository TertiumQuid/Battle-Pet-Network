class Sentient < ActiveRecord::Base
  has_many :hunts, :select => 'id,sentient_id,status,created_at', :order => 'created_at DESC'
  has_one :strategy, :as => :combatant, :dependent => :destroy
  
  validates_inclusion_of :sentient_type, :in => %w(threat)
  validates_numericality_of :required_rank, :greater_than_or_equal_to => 1
  
  alias_attribute :current_health, :health
  alias_attribute :current_endurance, :endurance
  alias_attribute :total_power, :power
  
  cattr_reader :per_page
  @@per_page = 12
  
  named_scope :threats, :conditions => "sentient_type = 'threat'"
  
  class << self
    def populate
      connection.execute "UPDATE sentients " +
                         "SET population = population + repopulation_rate " +
                         "WHERE population < population_cap " # (allows for minor overpopulation)
      ActivityStream.log! 'world', 'restock'
    end    
  end  
  
  def total_defense
    0
  end
  
  def slug
    name.downcase.gsub(/\s/,'-')
  end
end