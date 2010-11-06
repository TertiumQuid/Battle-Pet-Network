namespace :bpn do
  namespace :packs do
    desc "Recover pet endurance levels for active pack members"
    task(:recover => :environment) do
      Pack.recover!
    end
    
    desc "Pay pack member dues"
    task(:dues => :environment) do
      Pack.pay_dues!
    end
  end
end