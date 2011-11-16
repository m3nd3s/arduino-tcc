class ReportsController < ApplicationController
  def show
    sensor_id = params[:sensor_id] || Sensor.first.id
    if params[:start_at].nil? || params[:start_at].empty?
      start_at =  Time.now - 12.hours
    else
      start_at = params[:start_at]
    end
    
    if params[:end_at].nil? || params[:end_at].empty?
      end_at = Time.now
    else
      end_at = params[:end_at]
    end 

    @temperatures = Temperature.where("sensor_id = ? AND checked_at BETWEEN ? AND ?", sensor_id, start_at, end_at).paginate(:page => params[:page], :per_page => 20).order("checked_at DESC")

    respond_to do |format|
      format.html
    end
  end

  def export
    sensor_id = params[:sensor_id] || Sensor.first.id
    if params[:start_at].nil? || params[:start_at].empty?
      start_at =  Time.now - 12.hours
    else
      start_at = params[:start_at]
    end
    
    if params[:end_at].nil? || params[:end_at].empty?
      end_at = Time.now
    else
      end_at = params[:end_at]
    end 

    @temperatures = Temperature.where("sensor_id = ? AND checked_at BETWEEN ? AND ?", sensor_id, start_at, end_at).order("checked_at DESC")

    csv = []
    @temperatures.each { |t| csv << "#{t.sensor_id}, #{ t.checked_at.to_s(:db) }, #{t.value}" }

    respond_to do |format|
      format.html { render :inline => csv.join("\r\n") }
    end
   
  end
end
