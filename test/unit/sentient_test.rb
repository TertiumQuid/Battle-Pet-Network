require 'test_helper'

class SentientTest < ActiveSupport::TestCase
  def setup
    @sentient = sentients(:leper_rat)
  end
  
  def test_attribute_aliases
    assert @sentient.respond_to?(:current_health)
    assert @sentient.respond_to?(:current_endurance)
    assert @sentient.respond_to?(:total_power)
    assert @sentient.respond_to?(:total_defense)
    assert_equal 0, @sentient.total_defense
  end
  
  def test_populate
    Sentient.all.each do |sentient|
      sentient.update_attribute(:population, 0)
      assert_difference 'ActivityStream.count', +1 do
        assert_difference 'sentient.reload.population', +sentient.repopulation_rate do
          Sentient.populate
        end    
      end
    end
  end
end