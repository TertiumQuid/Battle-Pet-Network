class Admin::MainController < Admin::AdminController
  include ApplicationHelper
  
  def dashboard
  end
  
  def data
  end
  
  def logs
    Dir.glob("log/*.log")
    @log_file = ''

    @filename = params[:log] || "#{Rails.env}.log"
    @filepath = "#{RAILS_ROOT}/log/#{@filename}"

    if FileTest.exists?(@filepath)
      @log_file = File.new(@filepath).read
    end    
  end
end