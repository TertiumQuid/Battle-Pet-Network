class Facebook::SentientsController < Facebook::FacebookController
  def index
    @sentients = Sentient.threats.paginate(:page => params[:page], :order => :power)
    @hunts = current_user_pet.hunters.all(:limit => 12).map(&:hunt) if has_pet?
  end
  
  def show
    @sentient = Sentient.threats.find(params[:id])
    @hunts = @sentient.hunts.all(:limit => 12)
    @tactics = @sentient.strategy.maneuvers.sort! { |a,b| a.rank <=> b.rank }
  end
end