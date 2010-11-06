class Species < ActiveRecord::Base
  has_many :breeds
  has_many :actions
  
  validates_presence_of :name
  
  def slug
    name.downcase.gsub(/\s/,'-')
  end    
end