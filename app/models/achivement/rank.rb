class Rank < ActiveRecord::Base
  belongs_to :ranking
  belongs_to :rankable, :polymorphic => true
  
  after_create :award_prize, :log_ranked
  
  def award_prize
    award = ranking.leaderboard.awards.find_by_rank(rank)
    return unless award
    award.award_rankable(rankable)
  end
  
  def log_ranked
    ActivityStream.log! 'awards', 'ranked', rankable, self, ranking.leaderboard
  end
end