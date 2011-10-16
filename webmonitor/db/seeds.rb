# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.find_or_create_by_email({:email => "admin@arduino.cc", :password => "arduino", :password_confirmation => "arduino"})

if Sensor.count.eql?(0)
  Sensor.create([ {:sid => 0, :name => "Sensor 1"}, {:sid => 1, :name => "Sensor 2"} ])
end

if Temperature.count.eql?(0)
  24.times do |i|
    Temperature.create( { :checking => Time.now - i.hour, :value => ( Random.new.rand(90..300) / 10.0 ), :sensor_id => 0 })
  end

  24.times do |i|
    Temperature.create( { :checking => Time.now - 1.day - i.hour, :value => ( Random.new.rand(90..300) / 10.0 ), :sensor_id => 0 })
  end

  24.times do |i|
    Temperature.create( { :checking => Time.now - 2.day - i.hour, :value => ( Random.new.rand(90..300) / 10.0 ), :sensor_id => 0 })
  end
end
