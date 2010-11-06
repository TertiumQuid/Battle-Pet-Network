require 'test_helper'

class InventoryTest < ActiveSupport::TestCase
  def setup
    @shop = shops(:first)
    @belonging = belongings(:four_grass)
    @inventory = @shop.inventories.first
  end
  
  def test_intialize_from_belonging
    inventory = Inventory.new(:belonging_id => @belonging.id, :shop_id => @shop.id)
    assert_equal @belonging.item_id, inventory.item_id
  end
  
  def test_validates_belonging
    @belonging = belongings(:three_grass)
    inventory = Inventory.new(:belonging_id => @belonging.id, :shop_id => @shop.id)
    inventory.save
    assert_equal "shop owner isn't holding belonging", inventory.errors.on(:item_id)
  end
  
  def test_requires_belonging_on_create
    @belonging = belongings(:three_grass)
    inventory = Inventory.create(:item_id => @belonging.item.id, :shop_id => @shop.id)
    assert_equal "can't be blank", inventory.errors.on(:belonging_id)
  end
  
  def test_remove_belonging
    pet = @shop.pet
    assert_difference 'ActivityStream.count', +1 do
      assert_difference ['Belonging.count','@shop.pet.belongings.count'], -1 do
        inventory = Inventory.create!(:belonging_id => @belonging.id, :shop_id => @shop.id, :cost => 10)
      end
    end
  end
  
  def test_unstock
    pet = @shop.pet
    assert_difference ['pet.belongings.count'], +1 do
      assert_difference ['@shop.inventories.count'], -1 do
        @inventory.unstock!
      end
    end
  end
  
  def test_log_stock
    assert_difference 'ActivityStream.count', +1 do
      assert Inventory.create(:belonging_id => @belonging.id, :shop_id => @shop.id, :cost => 10)
    end
  end  
  
  def test_purchase_for
    pet = pets(:siamese)
    pet.update_attribute(:kibble, @inventory.cost + 1)
    pet.update_attribute(:level_rank_count, @inventory.item.required_rank + 1)
    
    assert_difference ['ActivityStream.count','pet.belongings.count'], +1 do
      assert_difference ['Inventory.count'], -1 do
        assert_difference ['pet.kibble'], -@inventory.cost do
          assert_difference ['@shop.pet.reload.kibble'], +@inventory.cost do
            belonging = @inventory.purchase_for!(pet)
            assert_equal 'holding', belonging.status
          end
        end
      end
    end
  end
  
  def test_purchase_fail
    pet = pets(:siamese)
    pet.update_attribute(:kibble, 0)
    pet.update_attribute(:level_rank_count, @inventory.item.required_rank - 1)
    belonging = nil
    
    assert_no_difference ['ActivityStream.count','Inventory.count','pet.belongings.count'] do
      belonging = @inventory.purchase_for!(pet)
    end
    assert belonging.new_record?
    assert !belonging.errors.empty?
    assert belonging.errors.full_messages.include?("too expensive")
    assert belonging.errors.full_messages.include?("too high level for pet")
  end
end