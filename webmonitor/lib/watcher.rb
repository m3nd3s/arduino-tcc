#coding: utf-8
class Watcher
  # Constates de configuração
  DEFAULT_URL = "http://192.168.1.200/getTemperature"
  TOKEN = "1qaz2wsx"

  def self.get_temperature(ip, token)
    Rails.logger.info "Realizando leitura de temperatura"
    url = "http://#{ip}/get_temp"
    url += "?token=#{token}" if token
    response = HTTParty.get(url)
    response
  end

  def self.get_info(ip, token=nil)
    Rails.logger.info "Realizando leitura de informações de dispositivo"
    url = "http://#{ip}/get_config"
    url += "?token=#{token}" if token
    response = HTTParty.get(url)

    # Fazendo o parseamento e retornando um hash
    config = response.strip.split("\n")
    json = {}
    config.each do |c|
      attribute = c.split('=')
      json.store( attribute[0].to_sym, attribute[1].strip )
    end
    json
  end

  def self.get_temperatures(ip, token=nil)
    Rails.logger.info "Realizando leitura de temperaturas para registro"
    url = "http://#{ip}/get_log"
    url += "?token=#{token}" if token
    response = HTTParty.get(url)
    response
  end

  def self.send_sms(destination, message)
    puts "Enviando SMS para #{destination}"
    puts HTTParty.post("http://sms.tecnoteam.com.br:3000/sms.php", :body => { :key => 'A8S83D74%#@39()7736452AJD', :phone => destination, :message => message })
  end

end
