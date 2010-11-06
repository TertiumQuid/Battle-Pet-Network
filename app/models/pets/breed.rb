class Breed < ActiveRecord::Base
  belongs_to :species
  belongs_to :favorite_action, :class_name => "Action"
  
  has_many :pets
  has_many :levels, :order => "rank ASC"
  
  validates_presence_of :species_id, :favorite_action_id, :name, :health, :endurance, 
                        :power, :intelligence, :fortitude, :affection
                        
  def slug
    name.downcase.gsub(/\s/,'-')
  end
end