require 'test_helper'

class LevelTest < ActiveSupport::TestCase
  def setup
    @pet = pets(:siamese)
    @advanceables = ['@pet.level_rank_count','@pet.health','@pet.endurance','@pet.fortitude','@pet.intelligence','@pet.power','@pet.affection']
  end
  
  def test_next_level
    Breed.all.each do |b|
      levels = Level.all :conditions => "breed_id = #{b.id}"
      levels.each_with_index do |l,idx|
        assert l.rank + 1, l.next_level.rank unless idx == (levels.size - 1)
      end
    end
  end
  
  def test_advance
    @pet.experience = @pet.level.next_level.experience
    assert_difference '@pet.level_rank_count', +1 do
      assert_difference ["@pet.#{@pet.level.next_level.advancement_type}"], +@pet.level.next_level.advancement_amount do
        @pet.level.next_level.advance(@pet)
      end
    end
  end
  
  def test_wont_advance
    assert_no_difference @advanceables do
      @pet.level.next_level.advance(@pet)
    end
    assert_no_difference @advanceables do
      @pet.level.advance(@pet)
    end
  end
end