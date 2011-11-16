#coding: utf-8
class Messenger < ActionMailer::Base
  default :from => "desenv@almirmendes.com"

  def notify_temperature(sensors)
    puts "Enviando e-mails de notifição"
    @sensors = sensors

    # Notifica via E-mail
    notifieds = Notification.where( :by => "email" ) 
    dests = []
    notifieds.each { |n| dests << n.using }
    mail(:subject => "Notificação de Alerta", :to => dests.join(",")).deliver

    # Notifica via SMS
    notifieds = Notification.where( :by => "sms" )
    # Agrupando os alertas em um único SMS
    mensagem = ""
    sensors.each { |s| mensagem += "#{s[:sensor]}: #{s[:temperature]}\n" }
    notifieds.each do |n|
      Watcher.send_sms(n.using, "Alerta de Temperatura\n #{mensagem}")
    end
  end
end
