class Level < ActiveRecord::Base
  belongs_to :breed
  has_many :pets
  
  validates_inclusion_of :advancement_type, :in => %w(health endurance fortitude intelligence power affection)
  
  named_scope :ranked, lambda { |rank|
    {:conditions=> ["rank = ?", rank ], :limit => 1}
  }
  
  def next_level
    Level.all(:conditions => ['rank = ? AND breed_id = ?', rank + 1, breed_id], :limit => 1).first
  end
  
  def advance(pet)
    return false if (pet.level_rank_count != rank-1) || (pet.experience < experience)
    
    set_method = "#{advancement_type}=".to_sym
    stat_val = pet.send(advancement_type.to_sym)
    pet.send(set_method, stat_val + advancement_amount)
    
    pet.level_rank_count = rank
    pet.current_health = pet.health
    pet.current_endurance = pet.endurance
    pet.save
  end
end