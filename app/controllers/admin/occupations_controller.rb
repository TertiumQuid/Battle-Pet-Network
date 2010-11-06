class Admin::OccupationsController < Admin::AdminController
  def index
    @occupations = Occupation.all
  end
end