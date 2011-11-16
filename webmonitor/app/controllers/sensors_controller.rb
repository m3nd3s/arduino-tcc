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

  def create
    @sensor = Sensor.new( params[:sensor] )
    respond_to do |format|
      if @sensor.save
        format.html { redirect_to sensors_path, :notice => "Sensor cadastrado com sucesso" }
      else
        format.html { render :new }
      end
    end
  end

  def update
    @sensor = Sensor.find(params[:id])
    respond_to do |format|
      if @sensor.update_attributes(params[:sensor])
        format.html { redirect_to sensors_path, :notice => "Sensor atualizado com sucesso" }
      else
        format.html { render :new }
      end
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

  def info
    respond_to do |format|
      format.json { render :json => Watcher.get_info( params[:ip], params[:token] ) }
    end
  end

end
