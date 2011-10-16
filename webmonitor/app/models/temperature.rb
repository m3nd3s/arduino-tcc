class Temperature < ActiveRecord::Base
    belongs_to :sensor

    validates_presence_of :sensor_id
    validates_associated :sensor
end
