module Combat::CombatActions
  require 'action_view/test_case'
  
  class Resolution
    attr_reader :first
    attr_reader :second
    attr_reader :first_action
    attr_reader :second_action
    attr_reader :first_damage
    attr_reader :second_damage
    attr_reader :description
            
    def initialize(first,first_action,second,second_action)
      @first = first
      @first_action = first_action
      @second = second
      @second_action = second_action
      
      @first_damage = 0
      @second_damage = 0
      
      resolve_damage
    end
    
    def resolve_damage
      if both_attacking?
        @first_damage = @first_action.power + @first.total_power
        @second_damage = @second_action.power + @first.total_power
        @description = Description::ALL_ATTACK
      elsif both_defending?  
        @description = Description::ALL_DEFEND
      elsif first_attacking_second?
        if did_undercut?(@first_action, @second_action)
          @first_damage = (@first_action.power * 2) + @second.total_power - @second.total_defense
          @description = Description::ONE_DEFEND_CUT_TWO_ATTACK
        elsif second_action_greater?
          @first_damage = @first_action.power + @first.total_power
          @description = Description::ONE_ATTACK_HIT_TWO_DEFEND
        elsif first_action_greater?
          if did_undercut?(@second_action, @first_action)  
            @second_damage = (@first_action.power * 2) + @second.total_power
            @description = Description::ONE_ATTACK_CUT_TWO_DEFEND
          else
            @first_damage = @first_action.power + @first.total_power - (@second_action.power + @second.total_defense)
            @description = Description::ONE_ATTACK_HIT_TWO_DEFENDED
          end
        end  
      elsif second_attacking_first?
        if did_undercut?(@second_action, @first_action)
          @second_damage = (@second_action.power * 2) + @first.total_power
          @description = Description::TWO_DEFEND_CUT_TWO_ATTACK
        elsif first_action_greater?
          @second_damage = @second_action.power + @second.total_power - @first.total_defense
          @description = Description::TWO_ATTACK_HIT_TWO_DEFEND
        elsif second_action_greater?
          if did_undercut?(@first_action, @second_action)
            @first_damage = (@second_action.power * 2) + @first.total_power
            @description = Description::TWO_ATTACK_CUT_TWO_DEFEND
          else
            @second_damage = @second_action.power + @second.total_power - (@first_action.power + @first.total_defense)
            @description = Description::TWO_ATTACK_HIT_TWO_DEFENDED
          end
        end
      end
    end

    def did_undercut?(given_action,target_action)
      given_action.power == target_action.power - 1
    end
    
    def first_action_greater?
      @first_action.power > @second_action.power
    end

    def second_action_greater?
      @second_action.power > @first_action.power
    end
    
    def both_attacking?
      @first_action.offensive? && @second_action.offensive?
    end
    
    def both_defending?
      @first_action.defensive? && @second_action.defensive?
    end
    
    def first_attacking_second?
      @first_action.offensive? && @second_action.defensive?
    end
    
    def second_attacking_first?
      @first_action.defensive? && @second_action.offensive?
    end
    
    class Description
      ALL_ATTACK = 1
      ALL_DEFEND = 2
      ONE_DEFEND_CUT_TWO_ATTACK = 3
      ONE_ATTACK_HIT_TWO_DEFEND = 4
      ONE_ATTACK_CUT_TWO_DEFEND = 5
      ONE_ATTACK_HIT_TWO_DEFENDED = 6
      TWO_DEFEND_CUT_TWO_ATTACK = 7
      TWO_ATTACK_HIT_TWO_DEFEND = 8
      TWO_ATTACK_CUT_TWO_DEFEND = 9
      TWO_ATTACK_HIT_TWO_DEFENDED = 10
    end    
  end
end