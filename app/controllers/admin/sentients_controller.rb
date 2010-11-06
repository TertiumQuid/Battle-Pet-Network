class Admin::SentientsController < Admin::AdminController
  def index
    @sentients = Sentient.all
  end
  
  def edit
    @sentient = Sentient.find(params[:id])
  end
  
  def update
    @sentient = Sentient.find(params[:id])
    
    if @sentient.update_attributes(params[:sentient])
      flash[:notice] = "Sentient updated."
      redirect_to edit_admin_sentient(@sentient)
    else
      flash[:error] = "Couldn't update sentient!"
      flash[:error_message] = @sentient.errors.full_messages.join(', ')
      render :action => :edit
    end
  end
end