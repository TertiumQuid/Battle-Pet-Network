require 'test_helper'

class AwardTest < ActiveSupport::TestCase
  def setup
    @pet = pets(:siamese)
    @award = awards(:strongest_1)
    @leaderboard = leaderboards(:strongest)
  end
  
  def make_rank
    ranking = @leaderboard.rankings.create
    return ranking.ranks.create(:rankable => @pet, :rank => 1)
  end
  
  def test_award_prize
    assert_difference '@pet.kibble', +@award.prize.to_i do
      flexmock(Award).new_instances.should_receive(:award_rankable).and_return(true)
      make_rank
    end
  end
  
  def test_log_ranked
    assert_difference 'ActivityStream.count', +1 do
      make_rank
    end
  end
end