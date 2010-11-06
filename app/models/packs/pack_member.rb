class PackMember < ActiveRecord::Base
  belongs_to :pet
  belongs_to :pack
  
  validates_inclusion_of :status, :in => %w(active expelled renounced disbanded)
end