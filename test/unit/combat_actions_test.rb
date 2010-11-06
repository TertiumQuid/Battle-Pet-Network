require 'test_helper'

class CombatActionsTest < ActiveSupport::TestCase
  def setup
    @attacker = pets(:siamese)
    @defender = pets(:persian)
  end
  
  def test_action_types
    assert Combat::CombatActions::Resolution.new(@attacker,actions(:slash),@defender,actions(:slash)).both_attacking?
    assert Combat::CombatActions::Resolution.new(@attacker,actions(:dodge),@defender,actions(:dodge)).both_defending?
    assert Combat::CombatActions::Resolution.new(@attacker,actions(:slash),@defender,actions(:dodge)).first_attacking_second?
    assert Combat::CombatActions::Resolution.new(@attacker,actions(:dodge),@defender,actions(:slash)).second_attacking_first?
  end
  
  def test_resolve_damage
    Action.all.each do |first_action|
      Action.all.each do |second_action|
        res = Combat::CombatActions::Resolution.new(@attacker,first_action,@defender,second_action)
        if res.both_attacking?
          assert_operator res.first_damage, ">", 0
          assert_operator res.second_damage, ">", 0
        elsif res.both_defending?
          assert_equal 0, res.first_damage + res.second_damage
        elsif res.first_attacking_second?
          if res.did_undercut?(second_action, first_action)
            assert_operator res.second_damage, ">", 0
            assert_equal 0, res.first_damage
          else
            assert_operator res.first_damage, ">", 0
            assert_equal 0, res.second_damage
          end
        elsif res.second_attacking_first?
          if res.did_undercut?(first_action, second_action)
            assert_operator res.first_damage, ">", 0
            assert_equal 0, res.second_damage
          else
            assert_operator res.second_damage, ">", 0
            assert_equal 0, res.first_damage
          end
        end
        assert_not_nil res.description
      end
    end
  end
end