// Método que imprime para o cliente o erro de página
// não encontrada
void file_not_found(Client client) {
  client.println((char*) pgm_read_word( &(string_table[1]) ));
}

// Determina se a requisição é do tipo GET
boolean isGET(const char* _header){
  return strstr(_header, "GET /") != NULL;
}

// Rederiza corretamente a requisção do cliente.
// Lê o arquivo correspondente no cartão SD
boolean render_html(Client client, const char *filename, boolean isGET){
  boolean is_json = false;

  // Get temperature and time
  float current_temp = sensors.getTempCByIndex(0);
  char dt[30];
  
  // Identifica se foi passado algum arquivo, caso contrário
  // carregue o index.htm
  //
  // Caso algum path tenha sido passado, é checado se a requisição está
  // sendo realizada pelo servidor linux e valida a requisição por 
  // meio do token
  if ( strlen(filename) == 0 )
    filename = "index.htm";
  else
    is_json = ( strstr(filename, "get_temp") != 0 && strstr(filename, "?token=1qaz2wsx") != 0 );

  // Requisição de arquivo normal
  if ( !is_json) {
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
    if ( strstr(filename, ".htm") != 0 )
      client.println((char*) pgm_read_word( &(string_table[0]) ));
    else
      client.println((char*) pgm_read_word( &(string_table[1]) ));

    client.println();

    // Leitura do arquivo no cartão SD
    char _c;
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
              client.print(current_temp);
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

  } else {
    int dec = (current_temp - ((int)current_temp)) * 100;
    sprintf(dt, "%02d.%02d", (int)current_temp, dec);
    client.println(dt);
  }

  return true;
}

void processing_action(const char *post_data, const char *filename) {
  Serial.println("Processando POST................");

  // Processando os dados enviados e salvando no arquivo
  if ( sd_file.open(&sd_root, sec_filename, O_CREAT | O_WRITE ) ) {
    byte t = strlen(post_data);
    for ( byte i=0; i < t; i++ ) {
      if ( post_data[i] != '&' ) {
        if( post_data[i] == '%' )
        sd_file.print(post_data[i]);
      } else {
        sd_file.println();
      }
    }
   sd_file.close();
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

/*
// Grava o log no SD
void logger() {
    // Solicita a temperatura atual
    float current_temp = sensors.getTempCByIndex(0);
    // Solicita a data/hora atual
    char datetime[19];
    format_datetime(datetime, false);

    if ( sd_file.open(&sd_root, log_filename, O_CREAT | O_APPEND | O_WRITE ) ) {
       sd_file.print(datetime);
       sd_file.print(";");
       sd_file.print(current_temp);
       sd_file.println();
       sd_file.close();
    }
}
*/

// Função chamada quando um alarme é ativado nos sensores de temperatura
void alarm_handler(uint8_t* device_address) {
  Serial.println("ALARM!!!!");
  float t = sensors.getTempCByIndex(0);
  digitalWrite(LED_PIN, HIGH);
  tone(BUZZ_PIN, 10, 5000);
}

/*
void load_configuration() {
  char key[8];
  char c;
  if ( sd_file.open(&sd_root, "config.ard", O_READ ) ) {
    byte i, j = 0;

    while( ( c = sd_file.read() ) > 0 ) {
      if ( c != '=' && c != '\n' && c != '\r' ) {
        key[i++] = c;
      } else {
        strcpy(configuration[j], key);
        // reset
        memset(&key, 0, i); i = 0; j++;
      }
    }
  }
}
*/
