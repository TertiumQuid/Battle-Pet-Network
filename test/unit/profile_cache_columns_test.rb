require 'test_helper'

class ProfileCacheColumnsTest < ActiveSupport::TestCase
  def setup
    @cached_attributes = ['health','endurance','fortitude','power','affection','defense','intelligence']
    @pet = pets(:siamese)
    @pet.update_attribute(:level_rank_count,10) # ensure rank for all humans / items
  end
  
  def clear_associations
    Tame.destroy_all
    Belonging.destroy_all
  end
  
  def test_column_attributes
    @cached_attributes.each do |col|
      assert @pet.respond_to?("#{col}_bonus_count".to_sym)
    end
  end
  
  def test_column_update_methods
    @cached_attributes.each do |col|
      assert @pet.respond_to?("update_#{col}_bonus_count".to_sym)
      assert_difference ["@pet.#{col}_bonus_count"], +1 do
        @pet.send("update_#{col}_bonus_count", 1)
      end
    end
  end

  def test_recalculate_health_bonus
    clear_associations
    @pet.recalculate_health_bonus
    assert_equal 0, @pet.health_bonus_count
    item = items(:calico_cloak)
    human = humans(:oscar)
    @pet.belongings.create(:item => item, :source => "award", :status => "active")
    @pet.tames.create(:human => human, :status => 'kenneled')
    @pet.recalculate_health_bonus
    assert_equal item.power + human.power, @pet.health_bonus_count
  end

  def test_recalculate_intelligence_bonus
    clear_associations
    @pet.recalculate_intelligence_bonus
    assert_equal 0, @pet.intelligence_bonus_count
    item = items(:silver_whiskers)
    human = humans(:ichabod)
    @pet.belongings.create(:item => item, :source => "award", :status => "active")
    @pet.tames.create(:human => human, :status => 'kenneled')
    @pet.recalculate_intelligence_bonus
    assert_equal item.power + human.power, @pet.intelligence_bonus_count
  end
  
  def test_recalculate_power_bonus
    clear_associations
    @pet.recalculate_power_bonus
    assert_equal 0, @pet.defense_bonus_count
    item = items(:hunting_claws)
    @pet.belongings.create(:item => item, :source => "award", :status => "active")
    @pet.recalculate_power_bonus
    assert_equal item.power, @pet.power_bonus_count
  end
  
  def test_recalculate_affection_bonus
    clear_associations
    @pet.recalculate_affection_bonus
    assert_equal 0, @pet.defense_bonus_count
    item = items(:bell_collar)
    human = humans(:sarah)
    @pet.belongings.create(:item => item, :source => "award", :status => "active")
    @pet.tames.create(:human => human, :status => 'kenneled')
    @pet.recalculate_affection_bonus
    assert_equal item.power + human.power, @pet.affection_bonus_count
  end
  
  def test_recalculate_defense_bonus
    clear_associations
    @pet.recalculate_defense_bonus
    assert_equal 0, @pet.defense_bonus_count
    item = items(:cordura_collar)
    human = humans(:oscar)
    @pet.belongings.create(:item => item, :source => "award", :status => "active")
    @pet.tames.create(:human => human, :status => 'kenneled')
    @pet.recalculate_defense_bonus
    assert_equal item.power + human.power, @pet.defense_bonus_count
  end
end