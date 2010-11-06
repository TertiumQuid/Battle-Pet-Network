ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.with_options :controller => 'main' do |m|
      m.dashboard 'dashboard', :action => 'dashboard'
      m.data 'data', :action => 'data'
      m.logs 'logs', :action => 'logs'
    end
    admin.resources :sentients, :only => [:index,:edit,:update]
    admin.resources :humans, :only => [:index,:edit,:update]
    admin.resources :breeds, :only => [:index,:edit,:update]
    admin.resources :levels, :only => [:index,:edit,:update]
    admin.resources :items, :only => [:index,:edit,:update]
    admin.resources :occupations, :only => [:index,:edit,:update]
    
    admin.resources :activity_streams, :only => [:index], :collection => {:toggle => :put}
    admin.root :controller => 'main', :action => 'dashboard'
  end
  
  map.namespace :facebook do |f|
    f.with_options :controller => 'lobby' do |lobby| 
      lobby.index 'index', :action => 'index'
      lobby.about 'about', :action => 'about'
      lobby.guide 'guide', :action => 'guide'
      lobby.staff 'staff', :action => 'staff'
      lobby.tos 'tos', :action => 'tos'
      lobby.contact 'contact', :action => 'contact'
      lobby.invite 'invite', :action => 'invite'
    end
    
    f.resources :forums, :only => [:index,:show] do |m|
      m.resources :forum_topics, :only => [:index,:show,:new,:create] do |t|
        t.resources :forum_posts, :only => [:edit,:update,:create]
      end
    end
    
    f.resources :humans, :only => [:index,:show] do |h|
    end
    
    f.resources :pets, :only => [:index,:show,:new,:create], :collection => {:home => :get} do |p|
      p.resources :challenges, :only => [:new,:create]
      p.resources :signs, :only => [:create]
    end
    
    f.resources :packs, :only => [:index,:new,:create,:show] do |p|
      p.resources :challenges, :only => [:create], :collection => {:pack => :get}
    end
    
    f.resources :sentients, :only => [:index,:show] do |s|
      s.resources :hunts, :only => [:new,:create]
    end
    
    f.resources :items, :only => [:index], :member => {:store => :get, :purchase => :post}, :collection => {:premium => :get} do |i|
    end
    
    f.resources :shops, :only => [:index, :show] do |s|
      s.resources :inventories, :as => :inventory, :only => [], :member => {:purchase => :post}
    end
    
    f.resources :leaderboards, :only => [:index]
    
    f.resources :occupations, :only => [:index,:update], :member => {:attempt => :put}
    
    f.with_options :path_prefix => '/facebook/pets/home' do |home|
      home.resource :biography, :only => [:new,:create]
      home.resources :messages, :only => [:show,:new,:create,:destroy], :collection => {:inbox => :get, :outbox => :get} 
      home.resources :kennel, :only => [:index], :member => {:enslave => :put, :release => :put}, :controller => 'tames'
      home.resources :challenges, :only => [:index,:edit,:show,:create,:update], :member => {:refuse => :put, :cancel => :put}, :collection => {:open => :get}
      home.resources :hunts, :only => [:show]
      home.resources :battles, :only => [:show]
      home.resource :shop, :only => [:new,:create,:edit,:update] do |shop|
        shop.resources :inventories, :only => [:create,:destroy,:update]
      end
      home.resource :pack, :only => [:edit,:update], :member => {:invite => :post} do |pack|
        pack.resources :spoils, :only => [:create,:update]
      end
      home.resources :strategies, :only => [:destroy]
      home.resources :belongings, :only => [:index,:update]
      home.resource :pet, :as => 'pet', :controller => 'pets', :only => [:update], :member => {:profile => :get, :combat => :get, :retire => :delete}
    end
    
    f.resources :payment_orders, :only => [:create] do |po|
      po.resources :payment_order_transactions, :only => [:new]
    end
    
    f.root :controller => 'lobby'
  end

  map.namespace :web do |f|
    f.with_options :controller => 'main' do |main|
      main.index 'index', :action => 'index'
    end
  end
  map.root :controller => 'web/main'  

  map.namespace :iphone do |f|
  end
end
