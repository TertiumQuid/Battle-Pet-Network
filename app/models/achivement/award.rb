class Award < ActiveRecord::Base
  belongs_to :leaderboard
  
  AWARD_TYPES = %w(kibble item)
  
  validates_inclusion_of :award_type, :in => AWARD_TYPES
    
  def award_rankable(rankable)
    if award_type == 'kibble'
      award_kibble(rankable)
    elsif award_type == 'item'
      award_item(rankable)
    end
  end
  
  def description
    case award_type
    when 'kibble'
      "+#{prize} kibble"
    end
  end
  
protected  
  
  def award_kibble(rankable)
    rankable.reload if rankable.readonly?
    if rankable.respond_to?(:kibble)
      rankable.update_attribute(:kibble, [rankable.kibble + prize.to_i, 0].max)
    elsif rankable.respond_to?(:pet)
      rankable.pet.update_attribute(:kibble, [rankable.pet.kibble + prize.to_i, 0].max)
    end
  end
  
  def award_item(rankable)
    true
  end
end