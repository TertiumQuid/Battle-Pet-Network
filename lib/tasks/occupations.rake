namespace :bpn do
  namespace :occupations do
    desc "Determine and apply outcomes for pet occupations"
    task(:occupy => :environment) do
      Occupation.scavenge!
      Occupation.tame_humans!
    end
  end
end