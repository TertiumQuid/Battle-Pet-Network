require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  def setup
    @item = items(:cat_grass)
    @treat = items(:cheezburger)
    @toy = items(:spiked_yarn_ball)
    @pet = pets(:persian)
  end
  
  def test_purchase_for
    assert_difference '@item.stock', -1 do
      assert_difference '@pet.kibble', -@item.cost do
        assert_difference ['@pet.belongings.count','ActivityStream.count'], +1 do
          belonging = @item.purchase_for!(@pet)
          assert_equal 'purchased', belonging.source
        end    
      end
    end
    @pet.update_attribute(:kibble, 0)
    purchase = @item.purchase_for!(@pet)
    assert purchase.errors.on_base.include?("too expensive")
    @item.update_attribute(:stock, 0)
    purchase = @item.purchase_for!(@pet)
    assert purchase.errors.on_base.include?("out of stock")
  end
  
  def test_eat_food
    @pet.update_attributes(:current_health => 1, :current_endurance => 1)
    assert @item.eat!(@pet)
    assert_equal @pet.health, @pet.current_health
    assert_equal @item.power + 1, @pet.current_endurance
    @pet.update_attributes(:current_health => @pet.health - 1, :current_endurance => @pet.endurance - 1)
    assert @item.eat!(@pet)
    assert_equal @pet.health, @pet.current_health
    assert_equal @pet.endurance, @pet.current_endurance
  end
  
  def test_eat_treat
    @pet.update_attributes(:current_health => 1)
    assert @treat.eat!(@pet)
    assert_equal @pet.health + @treat.power, @pet.current_health
    @pet.update_attributes(:current_health => @pet.health + 1)
    assert @treat.eat!(@pet)
    assert_equal @pet.health + 1 + @treat.power, @pet.current_health
  end
  
  def test_practice
    pet_mock = flexmock(@pet)
    pet_mock.should_receive(:advance_level)
    assert_difference '@pet.experience', +@toy.power do
      assert @toy.practice!(@pet)
    end    
  end

  def test_find_random_item
    assert_not_nil Item.find_random_item
    assert_not_nil Item.find_random_item(@pet)
  end

  def test_scavenges
    chance = @pet.total_intelligence.to_f
    AppConfig.occupations.scavenge_chance_divisor = chance / 1000
    assert Item.scavenges?(@pet)
    AppConfig.occupations.scavenge_chance_divisor = chance * 1000
    assert !Item.scavenges?(@pet)
  end

  def test_forages
    chance = @pet.total_intelligence.to_f
    AppConfig.occupations.forage_chance_divisor = chance / 1000
    assert Item.forages?(@pet)
    AppConfig.occupations.forage_chance_divisor = chance * 1000
    assert !Item.forages?(@pet)
  end

  def test_restock
    Item.all.each do |item|
      next if item.stock_cap < 1
      item.update_attribute(:stock, 0)
      assert_difference 'ActivityStream.count', +1 do
        assert_difference 'item.reload.stock', +item.restock_rate do
          Item.restock
        end    
      end
    end
  end  
end