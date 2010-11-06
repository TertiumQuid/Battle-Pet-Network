class Admin::BreedsController < Admin::AdminController
  def index
    @breeds = Breed.all
  end
  
  def edit
    @breed = Breed.find(params[:id])
  end
  
  def update
    @breed = Breed.find(params[:id])
    
    if @breed.update_attributes(params[:breed])
      flash[:notice] = "Breed updated."
      redirect_to edit_admin_breed(@breed)
    else
      flash[:error] = "Couldn't update breed!"
      flash[:error_message] = @breed.errors.full_messages.join(', ')
      render :action => :edit
    end
  end
end