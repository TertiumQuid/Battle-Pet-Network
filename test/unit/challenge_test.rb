require 'test_helper'

class ChallengeTest < ActiveSupport::TestCase
  def setup
    @attacker = pets(:siamese)
    @attacker_strategy = @attacker.strategies.first
    @defender = pets(:burmese)
    @params = {:attacker_id => @attacker.id,
              :defender_id => @defender.id,
              :attacker_strategy_id => @attacker_strategy.id, 
              :challenge_type => "1v1"}
    @prowling = occupations(:prowling)
    @taming = occupations(:taming)
  end
  
  def test_validates_different_combatants
    invalid_challenge = Challenge.create(@params.merge!(:attacker_id => @defender.id))
    assert invalid_challenge.errors.on_base.include?("cannot challenge self")
  end
  
  def test_validates_no_existing_challenge
    invalid_challenge = Challenge.create(@params)
    assert invalid_challenge.errors.on_base.include?("An outstanding challenge already exists for those pets.")
  end
  
  def test_validates_prowling
    @attacker.update_attribute(:occupation_id,@prowling.id)
    @defender.update_attribute(:occupation_id,@prowling.id)
    challenge = Challenge.create(@params)
    assert_nil challenge.errors.on(:defender_id)
    assert_nil challenge.errors.on(:attacker_id)
  end
  
  def test_validates_attacker_prowling
    Challenge.destroy_all
    @attacker.update_attribute(:occupation_id,@taming.id)
    challenge = Challenge.new(@params)
    challenge.save
    assert_equal "must be prowling to issue challenge", challenge.errors.on(:attacker_id)
  end
  
  def test_validates_defender_prowling
    Challenge.destroy_all
    challenge = Challenge.create(@params)
    @defender.update_attribute(:occupation_id,@taming.id)
    challenge.update_attribute(:defender_strategy_id,@defender.strategies.first.id)
    challenge.save
    assert_equal "must be prowling to accept challenge", challenge.errors.on(:defender_id)
  end
  
  def test_battle
    mock_combat
    challenge = challenges(:siamese_persian_issued)
    assert_no_difference ['Battle.count'] do
      challenge.battle!
    end  
    challenge.defender_strategy_id = challenge.defender.strategies.first.id 
    assert_difference ['Battle.count'], +1 do
      challenge.battle!
    end
  end
  
  def test_description
    challenge = challenges(:siamese_burmese_resolved)
    [challenge.attacker_id,challenge.defender_id,nil].each do |winner|
      challenge.battle.update_attribute(:winner_id, winner)
      assert_not_nil challenge.description
    end
  end
  
  def test_set_challenge_type
    one_on_one = Challenge.new(:attacker => pets(:siamese), :defender => pets(:persian))
    one_on_one.set_challenge_type
    assert_equal "1v1", one_on_one.challenge_type
    
    open = Challenge.new(:attacker => pets(:siamese))
    open.set_challenge_type
    assert_equal "1v0", open.challenge_type
  end
  
  def test_log_challenge
    Challenge.destroy_all
    challenge = Challenge.new(@params)
    assert_difference ['ActivityStream.count'], +1 do
      assert challenge.save
    end
  end
  
  def test_log_refusal
    challenge = challenges(:siamese_persian_issued)
    assert_difference ['ActivityStream.count'], +1 do
      challenge.update_attributes(:status => 'refused')
    end
    assert_no_difference ['ActivityStream.count'] do
      challenge.update_attributes(:status => 'refused')
    end
  end
  
  def test_validates_status_update
    new_challenge = Challenge.new
    assert new_challenge.validates_status_update
    refused_challenge = challenges(:siamese_persian_issued)
    assert new_challenge.validates_status_update
    challenge = challenges(:siamese_persian_issued)
    assert !challenge.save
    assert challenge.errors.on(:defender_strategy_id).include?("maneuvers cannot be empty")
  end
  
  def test_find_issued_for_defender
    assert_nil Challenge.find_issued_for_defender(0, 0)
    challenge = Challenge.find_issued_for_defender(challenges(:burmese_open).id, pets(:siamese).id)
    assert_equal pets(:siamese).id, challenge.defender_id
    assert Challenge.find_issued_for_defender(challenges(:siamese_persian_issued).id, pets(:persian).id)
    assert_nil Challenge.find_issued_for_defender(challenges(:siamese_persian_issued).id, pets(:siamese).id)
  end
end