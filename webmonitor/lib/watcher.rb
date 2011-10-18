class Watcher
  # Constates de configuração
  DEFAULT_URL = "http://192.168.1.200/getTemperature"
  TOKEN = "1qaz2wsx"

  # Método fácil de implementar os métodos de classe (self.abc)
  class << self

    def get_temperature
      Rails.logger.info "Realizando leitura de temperatura"
      response = HTTParty.get("#{DEFAULT_URL}?token=#{TOKEN}")
      response.body
    end
  end

end
