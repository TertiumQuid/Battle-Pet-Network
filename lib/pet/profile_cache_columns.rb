module Pet::ProfileCacheColumns
  require 'action_view/test_case'
   
  def update_health_bonus_count(val)
    update_attribute(:health_bonus_count, [(health_bonus_count + val), 0].max )
  end
   
  def update_endurance_bonus_count(val)
    update_attribute(:endurance_bonus_count, [(endurance_bonus_count + val), 0].max )
  end

  def update_fortitude_bonus_count(val)
    update_attribute(:fortitude_bonus_count, [(fortitude_bonus_count + val), 0].max )
  end

  def update_power_bonus_count(val)
    update_attribute(:power_bonus_count, [(power_bonus_count + val), 0].max )
  end

  def update_defense_bonus_count(val)
    update_attribute(:defense_bonus_count, [(defense_bonus_count + val), 0].max )
  end

  def update_intelligence_bonus_count(val)
    update_attribute(:intelligence_bonus_count, [(intelligence_bonus_count + val), 0].max )
  end

  def update_affection_bonus_count(val)
    update_attribute(:affection_bonus_count, [(affection_bonus_count + val), 0].max )
  end

  def recalculate_health_bonus
    mantle = belongings.active.type_is('Mantle').first
    fatted = tames.type_is('fatted').kenneled.all
    bonus = 0
    bonus = bonus + mantle.item.power unless mantle.blank?
    bonus = bonus + fatted.map(&:human).map(&:power).inject(0){|sum,power| sum + power} unless fatted.blank?
    update_attribute(:health_bonus_count, bonus)
  end

  def recalculate_intelligence_bonus
    sensors = belongings.active.type_is('Sensor').all
    wise = tames.type_is('wise').kenneled.all
    bonus = 0
    bonus = bonus + sensors.map(&:item).map(&:power).inject(0){|sum,power| sum + power} unless sensors.blank?
    bonus = bonus + wise.map(&:human).map(&:power).inject(0){|sum,power| sum + power} unless wise.blank?
    update_attribute(:intelligence_bonus_count, bonus)
  end

  def recalculate_affection_bonus
    charms = belongings.active.type_is('Charm').all
    friendly = tames.type_is('friendly').kenneled.all
    bonus = 0
    bonus = bonus + charms.map(&:item).map(&:power).inject(0){|sum,power| sum + power} unless charms.blank?
    bonus = bonus + friendly.map(&:human).map(&:power).inject(0){|sum,power| sum + power} unless friendly.blank?
    update_attribute(:affection_bonus_count, bonus)
  end
  
  def recalculate_power_bonus
    weapon = belongings.active.type_is('Weapon').first
    bonus = 0
    bonus = bonus + weapon.item.power unless weapon.blank?
    update_attribute(:power_bonus_count, bonus)
  end
  
  def recalculate_defense_bonus
    collar = belongings.active.type_is('Collar').first
    fatted = tames.type_is('fatted').kenneled.all
    bonus = 0
    bonus = bonus + collar.item.power unless collar.blank?
    bonus = bonus + fatted.map(&:human).map(&:power).inject(0){|sum,power| sum + power} unless fatted.blank?
    update_attribute(:defense_bonus_count, bonus)
  end
end