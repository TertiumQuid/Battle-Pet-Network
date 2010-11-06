class Admin::LevelsController < Admin::AdminController
  def index
    @levels = Level.all(:order => 'breed_id, rank ASC')
  end
  
  def edit
    @level = Level.find(params[:id])
  end
  
  def update
    @level = Level.find(params[:id])
    
    if @level.update_attributes(params[:level])
      flash[:notice] = "Level updated."
      redirect_to edit_admin_level(@level)
    else
      flash[:error] = "Couldn't update level!"
      flash[:error_message] = @level.errors.full_messages.join(', ')
      render :action => :edit
    end    
  end
end