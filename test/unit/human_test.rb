require 'test_helper'

class HumanTest < ActiveSupport::TestCase
  def setup
    @pet = pets(:siamese)
  end
  
  def test_finds_human
    chance = @pet.total_affection.to_f
    AppConfig.occupations.find_human_chance_divisor = chance / 1000
    assert Human.finds_human?(@pet)
    AppConfig.occupations.find_human_chance_divisor = chance * 1000
    assert !Human.finds_human?(@pet)
  end
  
  def test_find_random_human
    assert_not_nil Human.find_random_human
    assert_not_nil Human.find_random_human(@pet)
  end
end