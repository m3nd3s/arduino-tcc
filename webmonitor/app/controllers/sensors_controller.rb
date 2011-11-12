class SensorsController < ApplicationController

  def index
    @sensors = Sensor.all
    respond_to do |format|
      format.html
    end
  end

  def new
    @sensor = Sensor.new
    respond_to do |format|
      format.html
    end
  end

  def edit
    @sensor = Sensor.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def destroy
    @sensor = Sensor.find( params[:id] )
    @sensor.destroy
    flash[:notice] = "Sensor removido com sucesso!"
    respond_to do |format|
      format.html { redirect_to sensors_path }
    end
  end

end
