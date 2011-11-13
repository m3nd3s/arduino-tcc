// Método que imprime para o cliente o erro de página
// não encontrada
void file_not_found(Client client) {
  char buffer[128];
  strcpy_P( buffer, (char*) pgm_read_word( &(string_table[2]) ) );
  client.print( buffer );
}

// Determina se a requisição é do tipo GET
boolean isGET(const char* _header){
  return strstr(_header, "GET /") != NULL;
}

// Rederiza corretamente a requisção do cliente.
// Lê o arquivo correspondente no cartão SD
boolean render_html(Client client, const char *filename, boolean isGET){
  byte action = 0;

  // Get temperature and time
  float current_temp = sensors.getTempCByIndex(0);
  char dt[30];
  char _c;
  
  // Identifica se foi passado algum arquivo, caso contrário
  // carregue o index.htm
  //
  // Caso algum path tenha sido passado, é checado se a requisição está
  // sendo realizada pelo servidor linux e valida a requisição por 
  // meio do token
  if ( strlen(filename) == 0 ){
    filename = "index.htm";
  } else {
    if ( strstr(filename, "get_temp") != 0 && strstr(filename, "?token=1qaz2wsx") != 0 )
      action = 1;
    else if ( strstr(filename, "get_conf") != 0 && strstr(filename, "?token=1qaz2wsx") != 0 )
      action = 2;
  }

  // Requisição de arquivo normal
  if ( action == 0) {
    // Tenta abrir o arquivo para leitura
    Serial.print("Lendo arquivo: ");
    Serial.println(filename);
    if ( !sd_file.open(&sd_root, filename, O_READ ) ) {
      file_not_found(client);
      delay(1); // aguarda um tempo
      return false;
    }

    client.println("HTTP/1.1 200 OK");

    // Define the kind of file
    char buffer[24];
    if ( strstr(filename, ".htm") != 0 ){
      strcpy_P( buffer, (char*) pgm_read_word( &(string_table[0]) ) );
      client.println(buffer);
    } else {
      strcpy_P( buffer, (char*) pgm_read_word( &(string_table[1]) ) );
      client.println(buffer);
    }

    client.println();

    // Leitura do arquivo no cartão SD
    char keyword[8] = "";
    boolean capture = false;
    byte i = 0;

    // Read file from SD Card
    while( ( _c = sd_file.read() ) > 0 ) {

      if (_c == '{' ) capture = true;

      // Somente se estiver capturando
      if ( capture ) {

        // Captura o caracter e incrementa o contador
        keyword[i++] = _c;
        
        if ( i == 7 ) {
          keyword[i] = '\0';
          client.print(keyword);
          i = 0;
          capture = false;
          memset(&keyword, '\0', 8);
        } else {
          // Checa se é fechamento de placeholder
          if ( _c == '}' ) {
            capture = false;
            // Se existe a chave {temp}, então substitua pela temperatura
            // corrente
            if ( strstr(keyword, "{temp}") != NULL ) {
              int dec = abs(current_temp - ((int)current_temp)) * 100;
              sprintf(dt, "%02d,%02d", (int)current_temp, dec);
              client.print(dt);
            }
            else if(strstr(keyword, "{date}") != NULL ) { // Caso ache {date}, substitua pela data/hora atual
              sprintf(dt, "%02d-%02d-%04d %02d:%02d:%02d", t.date, t.mon, t.yr, t.hr, t.min, t.sec);
              client.print(dt);
            } else{
              client.print(keyword);
            }
            
            i = 0;
            memset(&keyword, '\0', 8);
          }
        }
      } else {
        client.print( _c );
      }
    } // Fim de leitura do SD

    sd_file.close(); // fecha o arquivo

  } else if ( action == 1 ) {
    // Acende o LED
    digitalWrite(LED_PIN, HIGH);

    int dec = (current_temp - ((int)current_temp)) * 100;
    sprintf(dt, "%02d.%02d", (int)current_temp, dec);
    client.println(dt);
    // Apaga o LED
    digitalWrite(LED_PIN, LOW);
  } else if ( action == 2 ) {
    // Acende o LED
    digitalWrite(LED_PIN, HIGH);
  
    if ( sd_file.open(&sd_root, tem_filename, O_READ ) ) {
      while( ( _c = sd_file.read() ) > 0 ){
        client.print(_c);
      }
      sd_file.close(); // fecha o arquivo
    } else {
      file_not_found(client);
      delay(1);
    }
    // Apaga o LED
    digitalWrite(LED_PIN, LOW);
  }

  return true;
}

void processing_action(const char *post_data, const char *filename) {
  Serial.println("Processando POST................");

  char *config_file;
  bool file = true;

  if ( strstr(filename, "sec.htm") != NULL ){
    config_file = sec_filename;
  } else if ( strstr(filename, "temp.htm" ) ) {
    config_file = tem_filename;
  } else if ( strstr(filename, "time.htm" ) ) {
    file = false;
  }

  // Processando os dados enviados e salvando no arquivo
  if( file ) { 
    if ( sd_file.open(&sd_root, config_file, O_CREAT | O_WRITE ) ) {
      byte t = strlen(post_data);
      for ( byte i=0; i < t; i++ ) {
        if ( post_data[i] != '&' ) {
          // Converte caracteres ASCII provenientes do protocolo HTTP
          if( post_data[i] == '%' ) {
            char hex[3] = { post_data[i+1], post_data[i+2], 0 };
            sd_file.print((char)strtoul(hex, NULL, 16));
            i += 2; // Avança duas casas
          } else {
            sd_file.print(post_data[i]);
          }
        } else {
          sd_file.println();
        }
      }
     sd_file.close();
    }
  } else {
    // Data
    char *pos = strstr( post_data, "date=" );
    char date[3] = { (pos)[5], ( pos )[6], 0 };
    // Mês
    pos = strstr( post_data, "month=");
    char month[3] = { (pos)[6], (pos)[7], 0 };
    // Ano
    pos = strstr( post_data, "year=");
    char year[3] = { (pos)[5], (pos)[6], 0 };
    // Hour
    pos = strstr( post_data, "hour=");
    char hour[3] = { (pos)[5], (pos)[6], 0 };
    // Min
    pos = strstr( post_data, "min=");
    char min[3] = { (pos)[4], (pos)[5], 0 };
    // Min
    pos = strstr( post_data, "sec=");
    char sec[3] = { (pos)[4], (pos)[5], 0 };

    Time t(strtoul(year, NULL, 0)+2000, strtoul(month, NULL, 0), strtoul(date, NULL, 0), strtoul(hour, NULL, 0), strtoul(min, NULL, 0), strtoul(sec, NULL, 0), 0);
    rtc.time(t);
  }

  Serial.println("Acabou o processamento.............");

 }

// Método responsável por processar a requisição do cliente
// retornando a página solicitada e/ou erro correspondente
void processing_request( Client client ) {

    // Controle do array de chars header
    byte index = 0; // Controla o número de caracteres
    char header[HTTP_HEADER_SIZE];
    boolean isGET = true;
    const char *filename;
    char html_filename[30];

    // Cliente conectado?
    if ( client.connected() ){

      // Leia os dados enviados e depois execute o processamento
      // da requisição
      while ( client.available() ) {
        char c = client.read();

        // Monta a string com os dados da requisição
        if ( c != '\n' && c != '\r' ) {

          if( index < HTTP_HEADER_SIZE )
            header[index] = c;
            index++;

        } else {

          header[index] = 0;

          if( c == '\r' ) {

            // Checa se é GET ou POST, isto só acontece na primeira linha do cabeçalho
            if( strstr( header, "GET" ) || strstr(header, "POST") ) {
              // é GET?
              isGET = ( strstr( header, "GET" ) != NULL );

              // Isto é um truque para facilitar a leitura e identificação do arquivo
              // retirado das instruções do Arduino.cc
              filename = (isGET) ? ( header + 5 ) : ( header + 6 );

              (strstr(header, " HTTP/1."))[0] = 0;
              strcpy(html_filename, filename);
            }

          }

          // Zera o contador e limpa o array utilizado para ler o cabeçalho
          // HTTP
          index = 0;
          memset(&header, 0, HTTP_HEADER_SIZE);
        }
      }

      // Caso a requisição seja do tipo POST deve ser feito o processamento da requisição
      if ( !isGET ) {
        // Debug, remover isto
        Serial.print("POST DATA: ");
        Serial.println(header);
        processing_action(header, html_filename);
      }
      
      Serial.print("FILE: ");
      Serial.println(html_filename);

      // Renderiza o html
      render_html(client, html_filename, isGET);

      // Disconnect
      delay(1);
      client.stop();
    }
}

// Grava o log no SD
void logger() {
    // Solicita a temperatura atual
    float current_temp = sensors.getTempCByIndex(0);
    // Solicita a data/hora atual
    char dt[20];
    int dec = abs(current_temp - ((int)current_temp)) * 100;
    sprintf(dt, "%02d-%02d-%04d|%02d:%02d:%02d|%02d.%02d", t.date, t.mon, t.yr, t.hr, t.min, t.sec, (int)current_temp, dec);

    if ( sd_file.open(&sd_root, log_filename, O_CREAT | O_APPEND | O_WRITE ) ) {
       sd_file.println(dt);
       sd_file.close();
    }
}

// Função chamada quando um alarme é ativado nos sensores de temperatura
void alarm_handler(uint8_t* device_address) {
  Serial.println("ALARM!!!!");
  float t = sensors.getTempCByIndex(0);
  digitalWrite(LED_PIN, HIGH);
  tone(BUZZ_PIN, 10, 5000);
}

void load_configuration() {
  Serial.println("Carregando configuracao...");

  // Leitura do arquivo de configuração
  char c;
  if ( sd_file.open(&sd_root, sec_filename, O_READ ) ) {
    char buff[32];
    byte i;
    while( ( c = sd_file.read() ) > 0 ) {
      if( c != '\r' && c != '\n' ){
        buff[i++] = c;
      } else {
        buff[i] = 0;

        // Tratamento para Endereço IP
        if( strstr( buff, "ip_address=" ) != NULL ) {
          char addr[4];
          byte num = 0;
          byte k = 0;
          char *pos = strstr(buff, "=");
          for( byte j=1; j < strlen(pos); j++ ){
            if( pos[j] == '.' ) {
              addr[k] = 0; // null no final
              ip[num++] = atoi(addr);
              k = 0;
              memset( &addr, 0, 4 );
            } else {
              addr[k++] = pos[j];
            }
          }
          addr[k] = 0; // null no final
          ip[num] = atoi(addr);
        }

        memset(&buff, 0, 32);
        i = 0;
      }
    }

    sd_file.close();
  }
}
