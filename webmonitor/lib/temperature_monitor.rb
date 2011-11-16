#coding: utf-8
class TemperatureMonitor

  def self.check_and_notify

    # Send notify
    sensors = []
    Sensor.all.each do |s|
      temp = s.temperature
      sensors << { :sensor => s.description, :temperature => s.temperature } if s.is_alert?(temp) or s.is_critical?(temp)
    end

    puts "Sensores em alerta ou críticos: #{sensors.inspect}"
    if sensors.any?
      Messenger.notify_temperature(sensors)
    end

  end


  def self.fetch_temperatures

    # For each sensor, capture temperatures
    Sensor.all.each do |s|
      content = Watcher.get_temperatures(s.ip_address, s.token)

      puts content

      content.split("\n").each do |record|
        fields = record.strip.split("|")
        Temperature.create( :checked_at => Date.parse("#{ fields[0] } #{ fields[1] }"), :value => fields[2], :sensor => s )
      end
    end
    
  end
end
