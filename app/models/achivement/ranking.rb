class Ranking < ActiveRecord::Base
  belongs_to :leaderboard
  has_many :ranks, :order => 'rank ASC'  
end