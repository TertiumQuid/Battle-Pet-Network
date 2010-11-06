require 'test_helper'

class BelongingTest < ActiveSupport::TestCase
  def setup
    @pet = pets(:siamese)
    @belonging = belongings(:two_catamount_claws)
  end
  
  def test_name
    assert_equal @belonging.item.name, @belonging.name
  end
  
  def test_apply
    currency = items(:kibble_pack)
    assert_difference '@pet.reload.kibble', +currency.power do
      belonging = @pet.belongings.create(:item => currency, :source => "award")
      assert_equal "expended", belonging.status
    end
  end
  
  def test_validates_exclusivity
    @belonging.item.update_attribute(:exclusive, true)
    invalid_belonging = @pet.belongings.create(:item => @belonging.item)
    assert invalid_belonging.errors.on(:item_id)
    assert_equal "exclusive item already possessed", invalid_belonging.errors.on(:item_id)
  end
  
  def test_deactivate_other_gear
    other_gear = items(:hunting_claws)
    gear = @pet.belongings.type_is('Weapon').active.first
    belonging = @pet.belongings.create(:item => other_gear, :source => "award", :status => "active")
    new_gear = @pet.belongings.type_is('Weapon').active.first.item
    assert_equal other_gear, new_gear
    assert_equal "holding", gear.reload.status
  end

  def test_update_bonus_count_column
    Belonging.destroy_all
    Item.equipable.all.each do |i|
      b = @pet.belongings.build(:item => i)
      col = case i.item_type.downcase
        when 'weapon'
          'power'
        when 'mantle'
          'health'
        when 'collar'
          'defense'
        when 'sensor'
          'intelligence'
      end
      next unless col
      assert_difference "b.pet.#{col}_bonus_count", +i.power do
        b.update_bonus_count_column
      end 
      assert_difference "b.pet.#{col}_bonus_count", -i.power do
        b.update_bonus_count_column(-1)
      end
    end
  end
end