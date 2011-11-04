class ReportsController < ApplicationController
  def show
    @temperatures = Temperature.last(20)
    respond_to do |format|
      format.html
    end
  end
end
