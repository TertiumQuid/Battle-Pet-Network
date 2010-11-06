class Admin::HumansController < Admin::AdminController
  def index
    @humans = Human.all
  end
  
  def edit
    @human = Human.find(params[:id])
  end
  
  def update
    @human = Human.find(params[:id])
    
    if @human.update_attributes(params[:human])
      flash[:notice] = "Human updated."
      redirect_to edit_admin_level(@human)
    else
      flash[:error] = "Couldn't update human!"
      flash[:error_message] = @human.errors.full_messages.join(', ')
      render :action => :edit
    end    
  end
end