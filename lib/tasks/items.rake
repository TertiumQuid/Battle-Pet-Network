namespace :bpn do
  namespace :items do
    desc "Restock items"
    task(:stock => :environment) do
      Item.restock
    end
  end
end