class ChartsController < ApplicationController

  def show
    sensor_id = params[:sensor_id] || Sensor.first.id
    sensor_id = sensor_id.first if sensor_id.kind_of? Array
    @sensor = Sensor.find(sensor_id)

    if params[:start_at].nil? || params[:start_at].empty?
      start_at =  Time.now - 2.hours
    else
      start_at = Time.parse params[:start_at]
    end
    
    if params[:end_at].nil? || params[:end_at].empty?
      end_at = Time.now
    else
      end_at = Time.parse params[:end_at]
    end 
    @temperatures = Temperature.where("sensor_id = ? AND checked_at BETWEEN ? AND ?", sensor_id, start_at, end_at)
    @temperatures_to_chart = @temperatures.collect { |t| t.value }

    @temperatures_to_chart = [0] unless @temperatures_to_chart


    respond_to do |format|
      format.html
    end
  end

end
