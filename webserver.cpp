Webserver::Webserver() {
  server(80);
}

void Webserver::begin(){
  server.begin();
}

void Webserver::process_connection(){
  // Variável de buffer, usada apenas para pegar os dados de request
  char request[HTTP_REQUEST_SIZE];

  // Aguarda por conexões do cliente
  client = server.available(); 

  // Conectado?
  if( client ){
    while( client.available() ){
    //
      // Monta a string com os dados da requisição
      if ( c != '\n' && c != '\r' ) {

        if( index < HTTP_HEADER_SIZE )
          request++ = c;

      } else {

        if( c == '\r' ) {
          // Finaliza a string em request
          request = 0;

          // Checa se é GET ou POST, isto só acontece na primeira linha do cabeçalho
          if( strstr( request, "GET" ) || strstr(request, "POST") ) {
            // é GET?
            is_post = ( strstr( request, "POST" ) != NULL );

            // Captura o path/arquivo
            if ( is_post )
              request + 6
            else
              request + 5;

            (strstr(request, " HTTP/1."))[0] = 0;
            strcpy(path, request);
          }

        }

        // Limpa o array utilizado para ler o cabeçalho
        memset(request, 0, HTTP_REQUEST_SIZE);
      }
 
    }

    // get post data
    if( is_post )
      read_post_params( request );
    
    // Renderiza a requsição
    render();
  }
}

void Webserver::read_post_params( char *request ) {
  Serial.println("Processando POST................");
  Serial.println( request );

  /*
  byte j, k = 0;
  char param[8] = ""; // 0 - 7
  char value[20] = ""; // max 100
  boolean p = true;

  for( byte i=0; strlen(post_data); i++ ) {

    if ( post_data[i] != '&' && post_data[i] != '=' ) {

      if( p )
        param[j++] = post_data[i]; 
      else
        value[k++] = post_data[i];

    } else {

      if( post_data[i] == '&' ) {
        param[j] = 0;
        value[k] = 0;
        p = true;
        j =0; k = 0;

        Serial.println("Colocando dados na EEPROM.............");
        write_data_to_eeprom(param, value);
      } else {
        p = false;
      }
    }
  }
  */

}

void Webserver::file_not_found(){
  client.println("HTTP/1.1 404 Not Found");
  client.println("Content-Type: text/html");
  client.println();
  client.println("<h2>File Not Found!</h2>");
}

bool Webserver::render() {
  bool is_json = false;
  
  // Identifica se foi passado algum arquivo, caso contrário
  // carregue o index.htm
  //
  // Caso algum path tenha sido passado, é checado se a requisição está
  // sendo realizada pelo servidor linux e valida a requisição por 
  // meio do token
  if ( strlen(path) == 0 )
    path = "index.htm";
  else
    is_json = ( strstr(filename, "get_json") != 0 && strstr(filename, "?token=1qaz2wsx") != 0 );

  // Get temperature and time
  //float current_temp = sensors.getTempCByIndex(0);
  
  // Requisição de arquivo normal
  if ( !is_json) {
    // Tenta abrir o arquivo para leitura
    Serial.print("Lendo arquivo: ");
    Serial.println(path);
    if ( !sd_file.open(&sd_root, path, O_READ ) ) {
      file_not_found();
      delay(1); // aguarda um tempo
      return false;
    }

    client.println("HTTP/1.1 200 OK");

    // Define the kind of file
    if ( strstr(filename, ".htm") != 0 )
      client.println("Content-Type: text/html");
    else
      client.println("Content-Type: text");

    client.println();

    // Leitura do arquivo no cartão SD
    char _c;
    char keyword[8] = "";
    bool capture = false;
    byte i = 0;

    // Read file from SD Card
    while( ( _c = sd_file.read() ) > 0 ) {

      capture = _c == '{';

      // Somente se estiver capturando o início de uma keyword
      if ( capture ) {

        // Captura o caracter e incrementa o contador
        keyword++ = _c;
        
        if ( i == 7 ) {
          keyword = 0;
          client.print(keyword);
          i = 0;
          capture = false;
          memset(keyword, 0, 8);
        } else {
          // Checa se é fechamento da keyword
          if ( _c == '}' ) {
            capture = false;
            // Se existe a chave {temp}, então substitua pela temperatura
            // corrente
            if ( strstr(keyword, "{temp}") != NULL )
              client.print("TEMP");
            else if(strstr(keyword, "{date}") != NULL ) // Caso ache {date}, substitua pela data/hora atual
              client.print("DATA/HORA");
            else
              client.print(keyword);
            
            i = 0;
            memset(keyword, 0, 8);
          }
        }
      } else {
        client.print( _c );
      }
    } // Fim de leitura do SD

    sd_file.close(); // fecha o arquivo

  } else {
    client.println("{ temperature: 20, datetime: 2011-11-12 12:00:00 }");
  }

  return true;

}
