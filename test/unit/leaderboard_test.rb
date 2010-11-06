require 'test_helper'

class LeaderboardTest < ActiveSupport::TestCase
  def setup
    @rank = 0
  end
  
  def test_rankables_for_relentless
    rankables = Leaderboard.rankables_for_relentless
    rankables.each do |pet|
      sql = "#{pet.id} IN (attacker_id, defender_id) AND challenges.#{Leaderboard::SQL_RECENT}"
      cnt = Challenge.count(:conditions => sql)
      assert_operator cnt, "<=", @rank unless @rank == 0
      @rank = cnt
    end
  end
  
  def test_rankables_for_ambassadors
    rankables = Leaderboard.rankables_for_ambassadors
    rankables.each do |pet|
      messages = pet.outbox(:conditions => Leaderboard::SQL_RECENT).count * AppConfig.leaderboards.ambassadors.messages
      signs = pet.signings(:conditions => Leaderboard::SQL_RECENT).count * AppConfig.leaderboards.ambassadors.signs
      posts = pet.user.forum_posts(:conditions => Leaderboard::SQL_RECENT).count * AppConfig.leaderboards.ambassadors.forum_posts
      points = messages + signs + posts
      assert_operator points, "<=", @rank unless @rank == 0
      @rank = points
    end
  end
  
  def test_rankables_for_hordes
    rankables = Leaderboard.rankables_for_hordes
    rankables.each do |pack|
      members = pack.pack_members.count * AppConfig.leaderboards.hordes.members
      spoils = pack.spoils.count * AppConfig.leaderboards.hordes.spoils
      kibble = pack.kibble.to_f * AppConfig.leaderboards.hordes.treasury
      standard = pack.standard.power * AppConfig.leaderboards.hordes.standard_power
      points = members + spoils + kibble + standard
      assert_operator points, "<=", @rank unless @rank == 0
      @rank = points      
    end
  end  
  
  def test_rankables_for_forerunners
    rankables = Leaderboard.rankables_for_forerunners
    rankables.each do |pet|
      assert_operator pet.experience, "<=", @rank unless @rank == 0
      @rank = pet.experience
    end
  end
  
  def test_rankables_for_manlords
    rankables = Leaderboard.rankables_for_manlords
    rankables.each do |pet|
      kennels = pet.tames.kenneled.map(&:human).map(&:power).inject(0){|sum,power| sum + power}
      slaves = pet.tames.enslaved.count
      points = slaves + kennels
      assert_operator points, "<=", @rank unless @rank == 0
      @rank = points
    end
  end
  
  def test_rankables_for_franchises
    rankables = Leaderboard.rankables_for_franchises
    rankables.each do |shop|
      sales = shop.sales.count("created_at >= DATE_ADD(NOW(), INTERVAL -#{Leaderboard::RANKING_PERIOD_DAYS} DAY)")
      assert_operator sales, "<=", @rank unless @rank == 0
      @rank = sales
    end
  end
  
  def test_rankables_for_strongest
    rankables = Leaderboard.rankables_for_strongest
    last_wins = 0
    rankables.each do |pet|
      count = Battle.count(:conditions => "winner_id = #{pet.id}")
      assert_operator count, ">=", last_wins
    end
  end
  
  def test_rank_leaderboards
    Leaderboard.all.each do |leaderboard|
      assert_difference ['leaderboard.rankings.count','Ranking.count'], +1 do    
        method = leaderboard.rankable_method_from_name.to_sym
        rankables = Leaderboard.send(method)
        assert_difference ['Rank.count'], +rankables.size do
          Leaderboard.rank_leaderboard(leaderboard)
        end
      end
    end
  end
end