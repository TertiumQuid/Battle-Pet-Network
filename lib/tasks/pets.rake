namespace :bpn do
  namespace :pets do
    desc "Recover pet endurance and health levels"
    task(:recover => :environment) do
      Pet.recover!
    end
  end
end