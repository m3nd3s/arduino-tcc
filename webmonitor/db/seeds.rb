# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.find_or_create_by_email({:email => "admin@arduino.cc", :password => "arduino", :password_confirmation => "arduino"})

unless SystemConfiguration.first
  SystemConfiguration.create({ :interval => 2, :refresh_interval => 1, :critical_level => 1 })
end
