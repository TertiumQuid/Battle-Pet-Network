require 'test_helper'

class CombatLoggerTest < ActiveSupport::TestCase
  def setup
    @attacker = pets(:siamese)
    @defender = pets(:persian)
    @sentient = sentients(:leper_rat)
    @new_combat_models = [Hunt.new, Battle.new]
    
    @battle = battles(:persian_burmese_resolved_battle)
    @hunt = hunts(:rat_hunt)
    @combat_models = [@hunt,@battle]
  end
  
  def test_set_logs
     @new_combat_models.each do |m|
       assert_equal Combat::CombatLogger::LOG_STRUCT, m.logs
     end
   end
   
   def test_named
     @new_combat_models.each do |m|
       assert_equal @attacker.name, m.named(@attacker)
       assert_equal "the #{@sentient.name.downcase}", m.named(@sentient)
     end
   end
   
   def test_log_advancement
     @combat_models.each do |m|
       m.logs = Combat::CombatLogger::LOG_STRUCT
       m.combatants.each do |c|  
         next unless c.is_a? Pet
         key = (c == m.attacker) ? :attacker_awards : :defender_awards
         log = m.log_advancement(c)
         assert_equal log, m.logs[key][:experience].last
       end
     end
   end
   
   def test_log_kibble
     award = @hunt.sentient.kibble
     log = @hunt.log_kibble(@hunt.attacker,award)
     assert_equal "#{@hunt.attacker.name} earned #{award} kibble", @hunt.logs[:attacker_awards][:kibble].last
   end
  
  def test_log_outcome
    @combat_models.each do |m|
      m.logs = Combat::CombatLogger::LOG_STRUCT
      m.combatants.each do |c|
        [:current_health,:current_endurance].each do |a|
          c.send("#{a}=",0)
          log = m.log_outcome
          assert_not_nil log
          assert_equal log, m.logs[:outcome]
          c.send("#{a}=",10)
        end
      end
    end
  end
  
  def test_log_gear
    at_least_some_logs = []
    @combat_models.each do |m|
      m.combatants.each do |c|
        log = m.log_gear(c)
        if c.is_a?(Pet) && c.belongings.battle_ready.size > 0
          assert log.include?(c.gear_list)
          assert_equal log, m.logs[:gear].last
          at_least_some_logs << log
        else  
          assert_nil log
        end
      end
    end
    assert !at_least_some_logs.empty?
  end
  
  def test_log_round
    resolutions = 
      [Combat::CombatActions::Resolution::Description::ALL_ATTACK,
      Combat::CombatActions::Resolution::Description::ALL_DEFEND,
      Combat::CombatActions::Resolution::Description::ONE_DEFEND_CUT_TWO_ATTACK,
      Combat::CombatActions::Resolution::Description::ONE_ATTACK_HIT_TWO_DEFEND,
      Combat::CombatActions::Resolution::Description::ONE_ATTACK_CUT_TWO_DEFEND,
      Combat::CombatActions::Resolution::Description::ONE_ATTACK_HIT_TWO_DEFENDED,
      Combat::CombatActions::Resolution::Description::TWO_DEFEND_CUT_TWO_ATTACK,
      Combat::CombatActions::Resolution::Description::TWO_ATTACK_HIT_TWO_DEFEND,
      Combat::CombatActions::Resolution::Description::TWO_ATTACK_CUT_TWO_DEFEND,
      Combat::CombatActions::Resolution::Description::TWO_ATTACK_HIT_TWO_DEFENDED]
    
    first = actions(:claw)  
    second = actions(:scratch)
    @combat_models.each do |m|
      resolutions.each do |r|
        res_mock = flexmock(:description => r, 
                            :first_action => first, 
                            :second_action => second, 
                            :first => m.attacker, 
                            :second => m.defender, 
                            :first_damage => 2, 
                            :second_damage => 2)
        log = m.log_round(res_mock)
        assert_not_nil log[:description]
        assert_equal first.slug, log[:attacker_action]
        assert_equal second.slug, log[:defender_action]
      end
    end
  end
  
  def test_log_combatant_status
    @combat_models.each do |m|
      m.combatants.each do |c|
        ['entered','ended'].each do |s|
          c.current_health = 1
          c.current_endurance = 1
          log = m.log_combatant_status(c,s)
          if c.is_a?(Pet)
            assert_equal "#{c.name} #{s} the battle with 1 health and 1 endurance.", log
          else
            assert_nil log
          end
        end
      end
    end
  end
end