class Tame < ActiveRecord::Base
  belongs_to :pet
  belongs_to :human  
  
  cattr_reader :per_page
  @@per_page = 5
    
  validates_inclusion_of :status, :in => %w(kenneled enslaved)
  validate :validates_exclusivity, :validates_max_tames
  
  after_create :update_bonus_count_column
  
  named_scope :kenneled, :conditions => "tames.status = 'kenneled'" do
    def release(id)
      tame = find(id)
      release_award = tame.human.power * AppConfig.humans.release_multiplier
      tame.pet.update_attribute(:kibble, tame.pet.kibble + release_award)
      ActivityStream.log! 'humans', 'release', tame.pet, tame.human
      tame.update_bonus_count_column(-1)
      Tame.delete(id)
    end
    
    def enslave(id)
      tame = find(id)
      tame.update_attribute(:status, 'enslaved')
      tame.update_bonus_count_column(-1)
    end    
  end
  named_scope :enslaved, :conditions => "tames.status = 'enslaved'"
  named_scope :type_is, lambda { |human_type| 
    { :conditions => ["humans.human_type = ?", human_type], :include => [:human] }
  }  
  
  class << self  
    def pet_tames_human?(pet,human)
      div = AppConfig.occupations.tame_human_chance_divisor.to_f
      change = [(pet.total_affection) - human.difficulty, 1].max
      chance = pet.total_affection.to_f / div
      val = 1 + rand(100)
      return val <= chance
    end

    def coexist!(tames)
      tames.each do |tame|
        if tame.kills_neighbor?(tames.size)
          targets = tames.reject{|t| t.id == tame.id}
          random_target = targets.sort_by{rand}[0]
          random_target.destroy
          ActivityStream.log! 'humans', 'murder', tame.pet, random_target.human, tame.human
          return false
        end
      end
      return true
    end
  end  
  
  def after_initialize(*args)
    self.status ||= 'kenneled'
  end  
  
  def kills_neighbor?(chance)
    val = 1 + rand(100)
    chance = chance.to_f * AppConfig.humans.kills_neighbor_modifier.to_f
    return val <= chance
  end
  
  def validates_max_tames
    errors.add(:human_id, "max number of humans already tamed") unless human && pet.tames.kenneled.size < pet.max_tames
  end
  
  def validates_exclusivity
    errors.add(:human_id, "human already tamed") if human && 
                                                    pet && 
                                                    pet.tames.kenneled.map(&:human_id).include?(human.id)
  end

  def update_bonus_count_column(multiply=1)
    bonus = human.power * multiply
    case human.human_type.downcase
      when 'wise'
        pet.update_intelligence_bonus_count(bonus)
      when 'fatted'
        pet.update_health_bonus_count(bonus)
      when 'friendly'
        pet.update_affection_bonus_count(bonus)
    end
  end
end