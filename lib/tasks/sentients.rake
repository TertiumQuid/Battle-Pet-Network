namespace :bpn do
  namespace :sentients do
    desc "Repopulate sentients"
    task(:populate => :environment) do
      Sentient.populate
    end
  end
end