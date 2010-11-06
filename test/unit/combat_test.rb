require 'test_helper'

class CombatTest < ActiveSupport::TestCase
  def setup
    @battle = battles(:persian_burmese_resolved_battle)
    @hunt = hunts(:rat_hunt)
    @combat_models = [@hunt,@battle]
    
    @attacker = pets(:siamese)
    @defender = pets(:persian)
    @attacker_strategy = @attacker.strategies.first
    @defender_strategy = @defender.strategies.first
    @defender = pets(:burmese)
    @params = {:attacker_id => @attacker.id,
              :defender_id => @defender.id,
              :attacker_strategy_id => @attacker_strategy.id, 
              :defender_strategy_id => @defender_strategy.id,               
              :challenge_type => "1v1"}
  end
  
  def test_attr_accessors
    accessors = [:current_round,:attacker_damage,:defender_damage,:attacker_action,:defender_action]
    @combat_models.each do |m|
      accessors.each do |a|
        assert m.respond_to?(a), "#{m.class.name} didn't respond to #{a}"
      end
    end
  end
  
  def test_attacker
    @combat_models.each do |m|
      assert m.respond_to?(:attacker)
      assert_not_nil m.attacker
    end
  end
  
  def test_defender
    @combat_models.each do |m|
      assert m.respond_to?(:defender)
      assert_not_nil m.defender, @hunt.sentient.inspect
    end
  end
  
  def test_combatants
    @combat_models.each do |m|
      assert m.combatants.is_a? Array
      assert_equal 2, m.combatants.size
    end
  end
  
  def test_combat_needs_to_occur_on_battle
    Challenge.destroy_all
    challenge = Challenge.new(@params)
    challenge.build_battle()
    assert challenge.battle.combat_needs_to_occur?
    challenge.save(false)
    assert !challenge.battle.combat_needs_to_occur?
  end
  
  def test_combat_needs_to_occur_on_hunt
    hunt = Hunt.new(:sentient_id => sentients(:leper_rat).id)
    hunt.hunters.build(:pet_id => @attacker.id, :strategy_id => @attacker_strategy.id)
    assert hunt.combat_needs_to_occur?
    hunt.status = "ended"
    hunt.save(false)
    assert !hunt.combat_needs_to_occur?
  end
  
  def test_combat_in_progress?
    attributes = [:current_health,:current_endurance]
    @combat_models.each do |m|
      assert m.combat_in_progress?
      m.combatants.each do |c|
        attributes.each do |a|
          c.update_attribute(a,0)
          assert !m.combat_in_progress?
        end
      end
    end
  end
  
  def test_losers_end_result
    attributes = [:current_health,:current_endurance]
    results = []
    expected_results = [3,4]
    @combat_models.each do |m|
      m.combatants.each do |c|
        attributes.each do |a|
          c.update_attribute(a,0)
          assert_not_nil m.end_result
          results << m.end_result.to_i unless results.include?(m.end_result.to_i)
          c.update_attribute(a,1)
        end
      end
    end
    
    assert_equal expected_results.size, results.size
    expected_results.each do |r|
      assert results.include?(r)
    end
  end
  
  def test_winners_end_result
    attributes = [:current_health,:current_endurance]
    results = []
    expected_results = [1,2]
    @combat_models.each do |m|
      attributes.each do |a|
        m.combatants.each { |c| c.update_attribute(a,0) }
        assert_not_nil m.end_result
        results << m.end_result.to_i unless results.include?(m.end_result.to_i)
      end
    end
    
    assert_equal expected_results.size, results.size
    expected_results.each do |r|
      assert results.include?(r)
    end
  end
  
  def test_strategy_for
    @combat_models.each do |m|
      m.combatants.each do |c|
        m.current_round = 0
        assert_equal c, m.strategy_for(c).combatant
      end
    end
  end
  
  def test_reset_actions
    @combat_models.each do |m|
      m.defender_action = m.attacker_action = actions(:claw)
      m.reset_actions
      assert_nil m.attacker_action
      assert_nil m.defender_action
    end
  end
  
  def test_exhaust_combatants
    action = actions(:claw)
    @combat_models.each do |m|
      m.initialize_combat
      action_mock = flexmock(m)
      action_mock.should_receive(:action_for).and_return(action)
      assert_difference ['m.defender.current_endurance','m.attacker.current_endurance'], -action.endurance_cost do      
        m.exhaust_combatants
      end
    end
  end
  
  def test_restore_combatants_condition
    @combat_models.each do |m|
      m.combatants.each do |c|
        c.current_health = (c == m.attacker) ? 1 : 0
      end
      m.restore_combatants_condition
      m.combatants.each do |c|
        next unless c.is_a? Pet
        if (c == m.attacker)
          assert_equal c.health, c.current_health
        else
          assert_equal c.health / 2, c.current_health
        end
      end
    end
  end
  
  def test_award_combatants
    @combat_models.each do |m|
      next if m.respond_to?(:award!)
      
      assert_no_difference ['m.attacker.experience','m.defender.experience'] do
        m.attacker.current_endurance = 0
        m.defender.current_endurance = 0
        m.award_combatants
      end
      m.attacker.current_endurance = 10
      m.attacker.experience = 0
      m.defender.experience = 0
      m.award_combatants
      assert_operator m.attacker.experience, ">", 0
      assert_operator m.defender.experience, ">", 0
      assert_operator m.attacker.experience, ">", m.defender.experience
    end
  end
  
  def test_experience_for_combatant
    base = 5
    flexmock(Combat).should_receive(:calculate_experience).and_return(base)
    @combat_models.each do |m|
      m.combatants.each do |c|
        next unless c.is_a?(Pet)
        assert_equal base, m.experience_for_combatant(c)
      end
    end
  end
  
  def test_strategy_bonus_experience_for_combatant
    base = 5
    flexmock(Combat).should_receive(:calculate_experience).and_return(base) 
    @combat_models.each do |m|
      m.defender.current_health = 0
      m.strategy_for(m.attacker).maneuvers.create(:action => m.attacker.breed.favorite_action)
      
      assert_equal base + 1, m.experience_for_combatant(m.attacker) if m.attacker.is_a?(Pet)
      assert_equal base, m.experience_for_combatant(m.defender) if m.defender.is_a?(Pet)
    end
  end
  
  def test_calculate_experience
    winner = Combat.calculate_experience(12, 5, 5, true)
    loser = Combat.calculate_experience(12, 5, 5, false)
    assert_operator winner, ">", loser
    handicaped = Combat.calculate_experience(12, 5, 10, false)
    assert_operator handicaped, ">", loser
    overpowered = Combat.calculate_experience(12, 10, 5, true)
    assert_operator overpowered, "<", winner
  end
  
  def test_save_combatants
    @combat_models.each do |m|
      m.combatants.each do |c|
        next unless c.is_a?(Pet)
        
        timestamp = c.updated_at
        c.touch unless timestamp.blank?
        sleep 0.3
        c.experience = c.experience + 1
        m.save_combatants
        assert_operator c.updated_at, ">", timestamp
      end
    end
  end
  
  def test_action_for_cache
    expected = actions(:scratch)
    @combat_models.each do |m|
      m.combatants.each do |c|
        if c == m.attacker
          m.attacker_action = expected
        else
          m.defender_action = expected
        end
        assert_equal expected, m.action_for(c)
      end
    end
  end
  
  def test_action_for
    expected = actions(:scratch)
    strategy_mock = flexmock(:maneuvers => [flexmock(:action=>expected),flexmock(:action=>expected)] )
    
    @combat_models.each do |m|
      flexmock(m).should_receive(:strategy_for).and_return( strategy_mock )
      m.current_round = 1
      m.combatants.each do |c|
        if c.is_a?(Sentient)
          assert c.strategy.maneuvers.map(&:action).include?( m.action_for(c) )
        else
          assert_equal expected, m.action_for(c)
        end
      end
    end
  end
end