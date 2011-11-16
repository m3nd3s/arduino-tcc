# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Webmonitor::Application.initialize!

Date::DATE_FORMATS[:default] = "%d/%m/%Y"
Date::DATE_FORMATS[:br_date] = "%d/%m/%Y"
Date::DATE_FORMATS[:br_date2] = "%d-%m-%Y"
Date::DATE_FORMATS[:month] = "%B"
Time::DATE_FORMATS[:default] = "%d/%m/%Y %H:%M"
Time::DATE_FORMATS[:br_datetime] = "%d/%m/%Y %H:%M"
Time::DATE_FORMATS[:br_date] = "%d/%m/%Y"
