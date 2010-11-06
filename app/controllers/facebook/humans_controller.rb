class Facebook::HumansController < Facebook::FacebookController
  def index
    @humans = Human.paginate :page => params[:page], :order => 'human_type, required_rank ASC'
    @occupation = Occupation.taming.first
  end
  
  def show
    @human = Human.find(params[:id])
  end
end