require 'test_helper'

class HunterTest < ActiveSupport::TestCase
  def setup
    @pet = pets(:siamese)
    Hunter.destroy_all
  end
  
  def test_validates_pet_strategy
    valid_strategy = Strategy.new(:combatant => @pet, :name => "Test")
    invalid_strategy = Strategy.new(:combatant => pets(:persian), :name => "Test")
    hunter = Hunter.new(:pet_id => @pet.id, :hunt => hunts(:rat_hunt), :strategy => valid_strategy)
    hunter.save
    assert_nil hunter.errors.on(:strategy_id)
    hunter = Hunter.new(:pet_id => @pet.id, :hunt => hunts(:rat_hunt), :strategy => invalid_strategy)
    hunter.save
    assert hunter.errors.on(:strategy_id).include?("unknown strategy")
  end
end