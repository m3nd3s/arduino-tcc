/**
* Biblioteca para inclusão de funções personalizadas
*/

// função para disparar erro de leitura com o SD Card
void error_P(const char* str) {
    PgmPrint("error: ");
    SerialPrintln_P(str);
    if (card.errorCode()) {
        PgmPrint("SD error: ");
        Serial.print(card.errorCode(), HEX);
        Serial.print(',');
        Serial.println(card.errorData(), HEX);
    }
    while(1);
}

/**
* Gravar dados na EEPROM
*/
void eepromWriteString( int position, char string[8] ) {
    int i = 0;
    char c;

    for ( i=0; i < 8; i++ ) {
        c = string[i];
        EEPROM.write(position++, c);
    }
    EEPROM.write(position, '\0');
}

/**
* Ler dados na EEPROM
*/
void eepromReadString( int position, char string[8] ) {
    int count = 8;
    int i = 0;

    for ( i=0; i < count; i++ ) {
        string[i] = EEPROM.read(position++);
    }
}

String getTemperatureAndTime()
{
  sensors.requestTemperatures(); // Send the command to get temperatures
  
  //Serial.println(temp);
  
  /* Get the current time and date from the chip */
  t = rtc.time();

  /* Name the day of the week */
  memset(day, 0, sizeof(day));  /* clear day buffer */
  switch (t.day) {
    case 1:
      strcpy(day, "Sunday");
      break;
    case 2:
      strcpy(day, "Monday");
      break;
    case 3:
      strcpy(day, "Tuesday");
      break;
    case 4:
      strcpy(day, "Wednesday");
      break;
    case 5:
      strcpy(day, "Thursday");
      break;
    case 6:
      strcpy(day, "Friday");
      break;
    case 7:
      strcpy(day, "Saturday");
      break;
  }

  TEMP = sensors.getTempCByIndex(0);
  int dec = (TEMP - ((int)TEMP)) * 100;
  Serial.println(dec);
  /* Format the time and date and insert into the temporary buffer */
  snprintf(buf, sizeof(buf), "%s %04d-%02d-%02d %02d:%02d:%02d %02d.%d",
           day,
           t.yr, t.mon, t.date,
           t.hr, t.min, t.sec, (int) TEMP, dec);

  /* Print the formatted string to serial so we can see the time */
  return buf;
}

void indexHTML(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete) {
    server.httpSuccess();
    const char *filename;
    
    if ( strlen(server.requestURI) == 0 )
        filename = "index.htm";
     else
         filename = server.requestURI;

    // Lendo o arquivo index.html disco
    if (! file.open(&root, filename, O_READ)) {
        server.println("HTTP/1.1 404 Not Found");
        server.println("Content-Type: text/html");
        server.println();
        server.println("<h2>File Not Found!</h2>");
    }

    String marker = "";
    boolean key = false;
    char c;
    while ((c = file.read()) > 0) {
      if ( c == '{' ) key = true;
      if (key) 
        marker += String(c);
      else
        server.print(c);
      if ( c == '}' || marker.length() >= 10 ) {
        key = false;
        
        if ( marker.equals("{temp}") )
          server.print(getTemperatureAndTime());
        else
          server.print(marker);
        
        marker = "";
      }
      
      //server.print(c);
    }
    file.close();
    //server.print(getTemperatureAndTime());
    //String novo_html = html.replace("{temp}", getTemperatureAndTime());
    //server.print(, temp_and_time));  
    //server.print(html);
    //Serial.print(html);
}

void configHTML(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete) {
    server.httpSuccess();

    // Se POST configura a senha
    if( type == WebServer::POST ) {
        char value[16], name[16];
        server.readPOSTparam(name, 16, value, 16);
        int valor = strtoul(value, NULL, 10);

        eepromWriteString(0, value);
        //server.setAuthentication("admin", value);
    }

    // Lendo o arquivo index.html disco
    if (! file.open(&root, "config.htm", O_READ)) {
        server.println("HTTP/1.1 404 Not Found");
        server.println("Content-Type: text/html");
        server.println();
        server.println("<h2>File Not Found!</h2>");
    }

    char c;
    while ((c = file.read()) > 0) {
        server.print(c);
    }
    file.close();
}



/*void logout(WebServerAuth &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete) {
    server.httpSuccess();
    server.httpAuthFail();
}*/

//void loadHTMLPage(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
//{
//    URLPARAM_RESULT rc;
//    char name[NAMELEN];
//    int  name_len;
//    char value[VALUELEN];
//    int value_len;
//    server.httpSuccess();
//
//    if ( type == WebServer::GET ) {
//        if( strlen(url_tail) ) {
//            while (strlen(url_tail)) {
//                rc = server.nextURLparam(&url_tail, name, NAMELEN, value, VALUELEN);
//                if (rc == URLPARAM_EOS)
//                    server.println("<hr />");
//                else {
//                    server.print(name);
//                    server.println(" = ");
//                    server.print(value);
//                }
//            }
//        }
//
//
//        if (! file.open(&root, "index.htm", O_READ)) {
//            server.println("HTTP/1.1 404 Not Found");
//            server.println("Content-Type: text/html");
//            server.println();
//            server.println("<h2>File Not Found!</h2>");
//        }
//
//        int16_t c;
//        while ((c = file.read()) > 0) {
//            // uncomment the serial to debug (slow!)
//            //Serial.print((char)c);
//            server.print((char)c);
//        }
//        file.close();
//
//        server.print("<h1>FILENAME");
//        server.print(url_tail);
//        server.println("</h1>");
//
//        // Salvando string
//        //eepromWriteString(2, "almir");
//        char nome[8] = {};
//        eepromReadString(2, nome);
//        server.println("<h1>");
//        server.println(nome);
//        server.println("</h1>");
//    }
//}
//
//void ListFiles(WebServer &client, uint8_t flags) {
//    // This code is just copied from SdFile.cpp in the SDFat library
//    // and tweaked to print to the client output in html!
//    dir_t p;
//
//    root.rewind();
//    client.println("<ul>");
//    while (root.readDir(p) > 0) {
//        // done if past last used entry
//        if (p.name[0] == DIR_NAME_FREE) break;
//
//        // skip deleted entry and entries for . and ..
//        if (p.name[0] == DIR_NAME_DELETED || p.name[0] == '.') continue;
//
//        // only list subdirectories and files
//        if (!DIR_IS_FILE_OR_SUBDIR(&p)) continue;
//
//        // print any indent spaces
//        client.print("<li><a href=\"");
//        for (uint8_t i = 0; i < 11; i++) {
//            if (p.name[i] == ' ') continue;
//            if (i == 8) {
//                client.print('.');
//            }
//            client.print(p.name[i]);
//        }
//        client.print("\">");
//
//        // print file name with possible blank fill
//        for (uint8_t i = 0; i < 11; i++) {
//            if (p.name[i] == ' ') continue;
//            if (i == 8) {
//                client.print('.');
//            }
//            client.print(p.name[i]);
//        }
//
//        client.print("</a>");
//
//        if (DIR_IS_SUBDIR(&p)) {
//            client.print('/');
//        }
//
//        // print modify date/time if requested
//        if (flags & LS_DATE) {
//            root.printFatDate(p.lastWriteDate);
//            client.print(' ');
//            root.printFatTime(p.lastWriteTime);
//        }
//        // print size if requested
//        if (!DIR_IS_SUBDIR(&p) && (flags & LS_SIZE)) {
//            client.print(' ');
//            client.print(p.fileSize);
//        }
//        client.println("</li>");
//    }
//    client.println("</ul>");
//}
//
///* commands are functions that get called by the webserver framework
// * they can read any posted data from client, and they output to the
// * server to send data back to the web browser. */
//void helloCmd(WebServer &server, WebServer::ConnectionType type, char *, bool)
//{
//    /* this line sends the standard "we're all OK" headers back to the
//       browser */
//    server.httpSuccess();
//
//    if( type == WebServer::POST ) {
//        char value[16], name[16];
//        server.readPOSTparam(name, 16, value, 16);
//        int valor = strtoul(value, NULL, 10);
//        EEPROM.write(0, valor);
//    }
//
//    /* if we're handling a GET or POST, we can output our data here.
//       For a HEAD request, we just stop after outputting headers. */
//    if (type != WebServer::HEAD)
//    {
//        int valor_r = EEPROM.read(0);
//        /* this defines some HTML text in read-only memory aka PROGMEM.
//         * This is needed to avoid having the string copied to our limited
//         * amount of RAM. */
//        P(helloMsg) = "<h1>Hello, World!</h1>";
//        P(nome) = "<a href='/config'>CONFIG</a>";
//
//        /* this is a special form of print that outputs from PROGMEM */
//        server.printP(helloMsg);
//        server.printP(nome);
//
//        server.print("<form method='post' action='/config'>");
//        server.print("<input type='text' value='' name='campo' />");
//        server.print("<input type='submit' value='OK' />");
//        server.print("</form>");
//
//        server.println("<h4>Meu valor armazenado: ");
//        server.print(valor_r);
//        server.print("</h4>");
//
//
//        ListFiles(server, LS_SIZE);
//
//
//    }
//
//}
