class Admin::ItemsController < Admin::AdminController
  def index
    @items = Item.all
  end
end