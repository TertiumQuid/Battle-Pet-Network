namespace :bpn do
  namespace :humans do
    desc "Generate income from enslaved humans"
    task(:labor => :environment) do
      pets = Pet.all(:joins=>"INNER JOIN tames ON pets.id = tames.pet_id", :conditions => {:status => 'enslaved'})
      pets.each do |pet|
        pet.update_attribute(:kibble, pet.kibble + pet.slave_earnings)
      end
    end
    
    desc "Evaluate if tamed humans can live together in peace"
    task(:coexist => :environment) do
      pets = Pet.all(:joins=>"INNER JOIN tames ON pets.id = tames.pet_id", :conditions => {:status => 'kenneled'})
      pets.each do |pet|
        Tame.coexist!(pet.tames.kenneled)
      end
    end
  end
end