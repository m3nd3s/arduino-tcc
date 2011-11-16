#coding: utf-8
class Sensor < ActiveRecord::Base
    validates_presence_of :description
    has_many :temperatures

    def alert
      read_attribute(:alert) ? "Sim" : "Não"
    end

    def temperature
       Watcher.get_temperature( ip_address, token )
    end

    def is_alert?(temperature)
      temperature.to_f > max_temperature or temperature.to_f < min_temperature
    end

    def is_critical?(temperature)
      ss = SystemConfiguration.first
      if ss
        critical_level = ss.critical_level
      end
      not is_alert?(temperature.to_f) and ( temperature.to_f > ( max_temperature - critical_level.to_f ) or temperature.to_f < ( min_temperature - critical_level ) )
    end

    def is_normal?(temperature)
      not is_critical?(temperature) and not is_alert?(temperature)
    end
end
