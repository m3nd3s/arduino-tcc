class SystemConfigurationsController < ApplicationController

  def edit
    @configuration = SystemConfiguration.first
    @configuration ||= SystemConfiguration.new()

     respond_to do |format|
       format.html
     end
  end

end
