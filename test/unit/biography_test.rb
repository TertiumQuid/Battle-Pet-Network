require 'test_helper'

class BiographyTest < ActiveSupport::TestCase
  def setup
    @params = {:temperament => 'Aloof', :lifestyle => 'Indoor', :gender => 'Tom', :favorite_color => 'Blue',
               :favorite_food => 'Treats', :favorite_pastime => 'Playing', :favorite_season => 'Spring',
               :favorite_philosopher => 'Descartes', :favorite_composer => 'J.S. Bach',
               :pedigree => 'Purebred', :circadian => 'Nocturnal', :voice => 'Smooth', :zodiac => 'Mouser',
               :birthday => '2010-1-1', :siblings => 2, :description => 'Test pet. Test pet. Test pet. Test pet. Test pet. Test pet. Test pet.'}    
  end
  
  def test_reward_pet
    pet = pets(:siamese)
    assert_difference 'pet.reload.kibble', +AppConfig.awards.biography do
      pet.build_biography(@params)
      pet.biography.reward_pet
    end
  end
end