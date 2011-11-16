// Método que imprime para o cliente o erro de página
// não encontrada
void file_not_found(Client client) {
  char buffer[65];
  strcpy_P( buffer, (char*) pgm_read_word( &(string_table[2]) ) );
  client.print( buffer );
}

// Rederiza corretamente a requisção do cliente.
// Lê o arquivo correspondente no cartão SD
boolean render_html(Client client, const char *filename, boolean isGET){
  byte action = 0;

  // Get temperature and time
  float current_temp = sensors.getTempCByIndex(0) - atof( error_c );
  char buffer[30];
  char _c;
  bool del = false;
  
  // Identifica se foi passado algum arquivo, caso contrário
  // carregue o index.htm
  //
  // Caso algum path tenha sido passado, é checado se a requisição está
  // sendo realizada pelo servidor linux e valida a requisição por 
  // meio do token
  if ( strlen(filename) == 0 ){
    filename = "index.htm";
  } else if (strstr(filename, "log.htm")) {
    action = 3;
    del = false;
  } else {
    if( strstr(filename, token/*"?token=1qaz2wsx"*/) != NULL ) {
      if ( strstr(filename, "get_temp") != NULL ) {
        action = 1;
      } else if ( strstr(filename, "get_conf") != NULL ) {
        action = 2;
      } 
    }
  }

  // Requisição de arquivo normal
  if ( action == 0) {
    // Tenta abrir o arquivo para leitura
    if ( !sd_file.open(&sd_root, filename, O_READ ) ) {
      file_not_found(client);
      //delay(1); // aguarda um tempo
      return false;
    }

    strcpy_P( buffer, (char*) pgm_read_word( &(string_table[3]) ) );
    client.println(buffer);

    if ( strstr( filename, ".htm" ) ) {
      strcpy_P( buffer, (char*) pgm_read_word( &(string_table[0]) ) );
      client.println(buffer);
    } else {
      strcpy_P( buffer, (char*) pgm_read_word( &(string_table[1]) ) );
      client.println(buffer);
    }

    client.println();

    // Leitura do arquivo no cartão SD
    char keyword[8] = "";
    bool capture = false;
    byte i = 0;

    // Time
    Time t = rtc.time();

    // Read file from SD Card
    while( ( _c = sd_file.read() ) > 0 ) {

      if (_c == '{' ) capture = true;

      // Somente se estiver capturando
      if ( capture ) {

        // Captura o caracter e incrementa o contador
        keyword[i++] = _c;
        
        // Já atingiu o máximo para uma palavra-chave
        if ( i == 7 ) {
          keyword[i] = 0;
          client.print(keyword);
          i = 0;
          capture = false;
          memset(keyword, 0, 8);
        } else {
          // Checa se é fechamento de palavra-chave
          if ( _c == '}' ) {
            capture = false;
            // Se existe a chave {temp}, então substitua pela temperatura
            // corrente
            if ( strstr(keyword, "{temp}") != NULL ) {
              byte dec = abs(current_temp - ((int)current_temp)) * 100;
              sprintf(buffer, "%02d,%02d", (int)current_temp, dec);
              client.print(buffer);
            } else if(strstr(keyword, "{date}") != NULL ) { // Caso ache {date}, substitua pela data/hora atual
              sprintf(buffer, "%02d-%02d-%04d %02d:%02d", t.date, t.mon, t.yr, t.hr, t.min);
              client.print(buffer);
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

    strcpy_P( buffer, (char*) pgm_read_word( &(string_table[3]) ) );
    client.println(buffer);
    client.println();

    byte dec = (current_temp - ((byte)current_temp)) * 100;
    sprintf(buffer, "%02d.%02d", (byte)current_temp, dec);
    client.println(buffer);
    // Apaga o LED
    digitalWrite(LED_PIN, LOW);
  } else if ( action == 2 ) {
    // Acende o LED
    digitalWrite(LED_PIN, HIGH);
  
    strcpy_P( buffer, (char*) pgm_read_word( &(string_table[3]) ) );
    client.println(buffer);
    client.println();

    if ( sd_file.open(&sd_root, tem_file, O_READ ) ) {
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
  } else if ( action == 3 ){
    strcpy_P( buffer, (char*) pgm_read_word( &(string_table[3]) ) );
    client.println(buffer);
    client.println();

    // Exibe o arquivo de logs
    if ( sd_file.open(&sd_root, log_file, O_READ ) ) {
      while( ( _c = sd_file.read() ) > 0 )
          client.print(_c);
      sd_file.close();
      if( del ) {
        sd_file.open(&sd_root, log_file, O_WRITE);
        sd_file.remove();
        sd_file.close();
      }
    }
  }

  return true;
}

/*
 * Função para processar as ações de POST
 */
void processing_action(char *post_data, char *filename) {

  char *config_file;
  bool file = true;

  if ( strstr(filename, "sec.htm") != NULL ){
    config_file = sec_file;
  } else if ( strstr(filename, "temp.htm" ) ) {
    config_file = tem_file;
  } else if ( strstr(filename, "time.htm" ) ) {
    file = false;
  }

  // Processando os dados enviados e salvando no arquivo
  if( file ) { 
    if ( sd_file.open(&sd_root, config_file, O_CREAT | O_WRITE ) ) {

      for ( byte i=0; i < strlen(post_data); i++ ) {
        if ( post_data[i] != '&' ) {
          // Converte caracteres ASCII provenientes do protocolo HTTP
          if( post_data[i] == '%' ) {
            char hex[3] = { post_data[i+1], post_data[i+2], 0 };
            sd_file.print((char)strtoul(hex, NULL, 16));
            i += 2; // Avança duas casas
          } else if ( post_data[i] == '+' ) {
            sd_file.print(' ');
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

 }

/* 
 * Método responsável por processar a requisição do cliente
 * retornando a página solicitada e/ou erro correspondente
 */
void processing_request( Client client ) {

    // Controle do array de chars header
    byte index = 0; // Controla o número de caracteres
    char buffer[HTTP_HEADER_SIZE];
    bool isGET = true;
    const char *filename;
    char html_file[30];
    bool authenticated = false;

    // Cliente conectado?
    if ( client.connected() ){

      // Leia os dados enviados e depois execute o processamento
      // da requisição
      while ( client.available() ) {
        char c = client.read();

        // Monta a string com os dados da requisição
        if ( c != '\n' && c != '\r' ) {

          if( index < HTTP_HEADER_SIZE )
            buffer[index] = c;
            index++;

        } else {

          buffer[index] = 0;

          if( c == '\r' ) {

            // Checa se é GET ou POST, isto só acontece na primeira linha do cabeçalho
            if( strstr( buffer, "GET" ) || strstr(buffer, "POST") ) {
              // é GET?
              isGET = ( strstr( buffer, "GET" ) != NULL );

              // Isto é um truque para facilitar a leitura e identificação do arquivo
              // retirado das instruções do Arduino.cc
              filename = (isGET) ? ( buffer+ 5 ) : ( buffer + 6 );

              (strstr(buffer, " HTTP/1."))[0] = 0;
              strcpy(html_file, filename);
            } else if (strstr( buffer, "Basic " )) {
              char *pos = strrchr( buffer, ' ' );
              authenticated = ( strcmp(pos+1, basic_auth) == 0 );
            }

          }

          // Zera o contador e limpa o array utilizado para ler o cabeçalho
          // HTTP
          index = 0;
          memset(buffer, 0, HTTP_HEADER_SIZE);
        }
      }

      // Caso a requisição seja do tipo POST deve ser feito o processamento da requisição
      if ( !isGET ) {
        processing_action(buffer, html_file);
      }
      
      if(authenticated || strstr(html_file, "get_temp") != NULL || strstr(html_file, "get_conf") || strstr(html_file, "get_log") ){
        // Renderiza o html
        render_html(client, html_file, isGET);
      } else {
        //char buffer[135];
        strcpy_P( buffer, (char*) pgm_read_word( &(string_table[4]) ) );
        client.println(buffer);
      }

      // Disconnect
      delay(1);
      client.stop();
    }
}

// Função chamada quando um alarme é ativado nos sensores de temperatura
void alarm_handler(uint8_t* device_address) {
  digitalWrite(LED_PIN, HIGH);
  tone(BUZZ_PIN, 10, 5000);
}

void get_ip_address(char *src, byte *dst) {
  char addr[4];
  byte num = 0;
  byte k = 0;
  char *pos = strstr(src, "=");
  for( byte j=1; j < strlen(pos); j++ ){
    if( pos[j] == '.' ) {
      addr[k] = 0; // null no final
      dst[num++] = atoi(addr);
      k = 0;
      memset( &addr, 0, 4 );
    } else {
      addr[k++] = pos[j];
    }
  }
  addr[k] = 0; // null no final
  dst[num] = atoi(addr);
}

void load_configuration() {

  char buff[35];
  char c;
  byte i = 0;
  byte k = 0;
  char *pos;
  char user_and_pass[24];

  // Leitura do arquivo de configuração
  if ( sd_file.open(&sd_root, sec_file, O_READ ) ) {
    while( ( c = sd_file.read() ) > 0 ) {
      if( c != '\r' && c != '\n' ){
        buff[i++] = c;
      } else {
        buff[i] = 0;
        i = 0;

        // Tratamento para Endereço IP
        //
        if( strstr( buff, "ip_addr" ) != NULL )
          get_ip_address(buff, ip);

        // Tratamento para Gateway
        //
        if( strstr( buff, "gateway" ) != NULL )
          get_ip_address(buff, gw);

        // Tratamento para Gateway
        //
        if( strstr( buff, "mask" ) != NULL ) {
          get_ip_address( buff, msk );
        }

        // Tratamento para MacAddr
        //
        if( strstr( buff, "mac_a" ) != NULL ) {
          char hex[3];
          byte num = 0;
          k = 0;
          pos = strstr(buff, "=");
          for( byte j=1; j < strlen(pos); j++ ){
            if( pos[j] == ':' ) {
              hex[k] = 0; // null no final
              mac[num++] = ( (byte) strtoul(hex, NULL, 16) );
              k = 0;
              memset( hex, 0, 4 );
            } else {
              hex[k++] = pos[j];
            }
          }
          hex[k] = 0; // null no final
          mac[num] = ( (byte) strtoul(hex, NULL, 16) );
        }

        // Pega o token
        if( strstr( buff, "token=" ) != NULL ) {
          k = 0;
          pos = strstr(buff, "=");
          for( byte j=1; j < strlen(pos); j++ ){
            token[k++] = pos[j];
          }

        }

        // Pega o login e senha e faz o encrypt ao final
        if( strstr(buff, "username=") != NULL ) {
          k = 0;
          pos = strstr(buff, "=");

          for( byte j=1; j < strlen(pos); j++ ){
            user_and_pass[k++] = pos[j];
          }
          user_and_pass[k++] = ':';
        }

        // Entrando aqui já deveria ter passado pelo username
        if( strstr(buff, "password=") != NULL ) {
          for( byte j=1; j < strlen(pos); j++ ){
            user_and_pass[k++] = pos[j];
          }
          user_and_pass[k] = 0x00;
          int error = EncodeBase64::encode(user_and_pass,strlen(user_and_pass),basic_auth,32);
          if(error) strcpy(basic_auth,"YWRtaW46YWRtaW4="); // "admin:admin"
        }

        memset( buff, 0, 35 );
      }
    }

    sd_file.close();
  }

  // Leitura do arquivo de configuração de temperaturas
  if ( sd_file.open(&sd_root, tem_file, O_READ ) ) {
    memset( buff, 0, 35 );
    i = 0;
    while( ( c = sd_file.read() ) > 0 ) {
      if( c != '\r' && c != '\n' ){
        buff[i++] = c;
      } else {
        buff[i] = 0;
        i = 0;
        byte cmd = 0;
        if( strstr( buff, "max_temp" ) != NULL )
          cmd = 1;
        else if ( strstr( buff, "min_temp" ) != NULL )
          cmd = 2;
        else if ( strstr( buff, "interval" ) != NULL )
          cmd = 3;
        else if ( strstr( buff, "doubt" ) != NULL )
          cmd = 4;
        else if ( strstr( buff, "error" ) != NULL )
          cmd = 5;

        // Pegando temperatura Máxima
        //
        if( c == '\r' && cmd >= 1 ) {
          byte k = 0;
          char *pos = strstr(buff, "=");
          char temp[5];
          for( byte j=1; j < strlen(pos); j++ ){
            temp[k++] = pos[j];
          }
          temp[k] = 0;
          if( cmd == 1 )
            max_temp= atoi(temp);
          else if( cmd == 2 )
            min_temp = atoi(temp);
          else if( cmd == 3 )
            t_intval = atoi(temp);
          else if( cmd == 4 )
            strcpy(doubt, temp);
          else if ( cmd == 5 )
            strcpy( error_c, temp );
        }
      }
    }
    sd_file.close();
  }
}
