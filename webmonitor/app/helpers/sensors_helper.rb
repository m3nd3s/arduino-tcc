module SensorsHelper
  def image_tag_sensor(sensor, temperature)
    if sensor.is_normal?(temperature)
      image_tag "arduino_green.jpg", :class => "thumbnail"
    else
      if sensor.is_critical?(temperature)
        image_tag "arduino_yellow.jpg", :class => "thumbnail"
      else
        image_tag "arduino_red.jpg", :class => "thumbnail"
      end
    end
  end
end
