require 'test_helper'
require "#{RAILS_ROOT}/lib/ruby/array"

class StrategyTest < ActiveSupport::TestCase
  def setup
    @pet = pets(:siamese)
    @new_strategy = @pet.strategies.build
    @maneuver = @new_strategy.maneuvers.build(:action => actions(:scratch))
    @favorite_strategy = @pet.strategies.build
    @favorite_strategy.maneuvers.build(:action => @pet.favorite_action)
    @favorite_strategy.maneuvers.build(:action => @pet.breed.favorite_action)
  end
  
  def test_validates_presence_of_maneuvers
    invalid = @pet.strategies.build
    assert !invalid.save
    assert invalid.errors.on(:maneuvers)
  end
  
  def test_set_name_automatically
    assert_nil @new_strategy.name
    @new_strategy.save
    assert_not_nil @new_strategy.name
    assert @new_strategy.name.match /[a-z]{3}(-\d)+?$/
  end
  
  def test_set_name_for_given
    given = "1234testing"
    @new_strategy.name = given
    @new_strategy.save
    assert_equal given, @new_strategy.name
  end
  
  def test_average_power
    strategy = @pet.strategies.build
    average = strategy.average_power
    assert_equal 0, average
    actions = [actions(:scratch),actions(:flank),actions(:claw)]
    actions.each do |a|
      strategy.maneuvers.build(:action => a)
      average = average + a.power
    end
    assert_operator average, ">", 0
    assert_equal (average / strategy.maneuvers.size), strategy.average_power
  end
  
  def test_favorite_action_experience_bonus
    assert_equal 0, strategies(:leper_rat_strategy).favorite_action_experience_bonus
    expected = (AppConfig.experience.favorite_action_bonus * @favorite_strategy.maneuvers.size)
    assert_operator @favorite_strategy.favorite_action_experience_bonus, ">", 0
    assert_equal expected, @favorite_strategy.favorite_action_experience_bonus
  end
  
  def test_random_maneuver
    strategy = @pet.strategies.build
    assert_nil strategy.random_maneuver
    strategy.maneuvers.build(:action => actions(:scratch), :rank => 1)
    strategy.maneuvers.build(:action => actions(:claw), :rank => 2)
    strategy.maneuvers.build(:action => actions(:bite), :rank => 7)
    counts = {}
    counts['1'] = 0
    counts['2'] = 0
    counts['7'] = 0
    
    100.times do
      r = strategy.random_maneuver
      counts[r.rank.to_s] += 1
    end
    a_exp = 10
    b_exp = 20
    c_exp = 70
    assert_in_delta(a_exp, counts['1'], 0.5*a_exp)
    assert_in_delta(b_exp, counts['2'], 0.5*b_exp)
    assert_in_delta(c_exp, counts['7'], 0.5*c_exp)
  end
  
  def test_set_ranks
    strategy = @pet.strategies.build
    3.times do 
      strategy.maneuvers.build(:action => actions(:scratch), :rank => 0)
    end
    strategy.set_ranks
    strategy.maneuvers.each_with_index do |m,idx|
      assert_equal idx, m.rank
    end
  end
end