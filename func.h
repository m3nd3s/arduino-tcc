// Método que imprime para o cliente o erro de página
// não encontrada
void file_not_found(Client client) {
  client.println("HTTP/1.1 404 Not Found");
  client.println("Content-Type: text/html");
  client.println();
  client.println("<h2>File Not Found!</h2>");
}

// Determina se a requisição é do tipo GET
boolean isGET(const char* _header){
  return strstr(_header, "GET /") != NULL;
}

// Recebe um array do tipo char e o altera o seu conteúdo
// colocando a data formada
void format_datetime(char dt[], boolean csv) {
  memset(dt, 0, strlen(dt));
  if(csv)
    sprintf(dt, "%04d-%02d-%02d %02d:%02d:%02d", t.yr, t.mon, t.date, t.hr, t.min, t.sec);
  else
    sprintf(dt, "%02d-%02d-%04d %02d:%02d:%02d", t.date, t.mon, t.yr, t.hr, t.min, t.sec);
}

// Rederiza corretamente a requisção do cliente.
// Lê o arquivo correspondente no cartão SD
boolean render_html(Client client, const char *filename, boolean isGET){
  boolean isCSV = false;
  
  // Identifica se foi passado algum arquivo, caso contrário
  // carregue o index.htm
  //
  // Caso algum path tenha sido passado, é checado se a requisição está
  // sendo realizada pelo servidor linux e valida a requisição por 
  // meio do token
  if ( strlen(filename) == 0 )
    filename = "index.htm";
  else
    isCSV = ( strstr(filename, "getTemperature") != 0 && strstr(filename, "?token=1qaz2wsx") != 0 );

  // Get temperature and time
  float current_temp = sensors.getTempCByIndex(0);
  
  char datetime[19];
  format_datetime(datetime, false);
  //int d1 = current_temp;
  //float f = current_temp - d1;
  //int d2 = f * 100;
  //sprintf(date, "%02d-%02d-%04d", t.date, t.mon, t.yr);
  //sprintf(time, "%02d:%02d:%02d", t.hr, t.min, t.sec);
  
  // Requisição de arquivo normal
  if ( !isCSV) {
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
      client.println("Content-Type: text/html");
    else if ( strstr(filename, ".jpg") != 0 )
      client.println("Content-Type: image/jpeg");
    else if ( strstr(filename, ".gif") != 0 )
      client.println("Content-Type: image/gif");
    else if ( strstr(filename, ".png") != 0 )
      client.println("Content-Type: image/png");
    else
      client.println("Content-Type: text");

    client.println();

    // Leitura do arquivo no cartão SD
    char _c;
    String keyword = "";
    boolean key = false;

    // Read file from SD Card
    while( ( _c = sd_file.read() ) > 0 ) {
      if (_c == '{' ) key = true;
      if ( key )
        keyword += String(_c);
      else
        client.print( _c );

      // Caso ache o fechamento de tag ou o tamanho for
      // maior ou igual 16 (máximo), libera o buffer
      if ( _c == '}' || keyword.length() >= 16 ) {
        key = false;

        // Se existe a chave {temp}, então substitua pela temperatura
        // corrente
        if ( keyword.equals( "{temp}" ) )
          client.print(current_temp);
        else if(keyword.equals( "{date}" )) // Caso ache {date}, substitua pela data/hora atual
          client.print(datetime);
        else
          client.print(keyword);
        
        keyword = "";
      }
    } // Fim de leitura do SD

    sd_file.close(); // fecha o arquivo

  } else {
    // Retorno no formato CSV
    char csv[22];
    format_datetime(csv, true);
    //sprintf(csv, "%04d-%02d-%02d %02d:%02d:%02d,%d.%02d", t.yr, t.mon, t.date, t.hr, t.min, t.sec, d1, d2);
    client.println(csv);
  }

  return true;
}

void processing_action(const char *post_data) {
  // Matriz de dados
  //char params[25][20];
  //byte j, k = 0;

  Serial.println("Processando POST");

  // Processando os dados enviados
  byte t = strlen(post_data);
  for ( byte i=0; i < t; i++ ){

    if ( post_data[i] != '=' && post_data[i] != '&' ) {
      //params[j][k++] = post_data[i];
      Serial.print(post_data[i]);
    } else {
      // Adiciona null ao final
      //params[j][k] = '\0';
      Serial.println();
      //j++; k = 0;
    }

  }
  Serial.println("Acabou o processamento.............");

  // Processamento da configuração de dada e hora
  //if( strstr(filename, "time.htm") != NULL ){
    //uint8_t year = data.substring(data.indexOf("year")+4,  );
    
    // Set the datetime based on parameters
    //Time t(year, month, date, hour, min, sec, 0);

    /* Set the time and date on the chip */
    //rtc.time(t);
  //}
}

// Método responsável por processar a requisição do cliente
// retornando a página solicitada e/ou erro correspondente
void processing_request( Client client ) {

    // Controle do array de chars header
    byte index = 0;
    byte i = 0;
    char header[HTTP_HEADER_SIZE];
    boolean isGET = true;
    const char *filename;
    char html_filename[12];

    // Cliente conectado?
    if ( client.connected() ){

      // Leia os dados enviados e depois execute o processamento
      // da requisição
      while ( client.available() ) {
        char c = client.read();

        // Modificar aqui para ler o header HTTP inteiro

        // Monta a string com os dados da requisição
        if ( c != '\n' && c != '\r' ) {
          if( index < HTTP_HEADER_SIZE )
            header[index++] = c;
        } else {
          header[index] = '\0';
          if( c == '\r' ) {
            // Checa a primeira linha da requisição
            if( i == 0 ) {
              isGET = ( strstr( header, "GET" ) != NULL );

              // Isto é um truque para facilitar a leitura e identificação do arquivo
              // retirado das instruções do Arduino.cc
              filename = (isGET) ? ( header + 5 ) : ( header + 6 );

              (strstr(header, " HTTP/1."))[0] = 0;
              strcpy(html_filename, filename);
            }

            i++;
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
        processing_action(header);
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

// Função chamada quando um alarme é ativado nos sensores de temperatura
void alarm_handler(uint8_t* device_address) {
  Serial.println("ALARM!!!!");
  float t = sensors.getTempCByIndex(0);
  digitalWrite(LED_PIN, HIGH);
  tone(BUZZ_PIN, 10, 5000);
}


