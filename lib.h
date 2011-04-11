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

void indexHTML(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete) {
    server.httpSuccess();

    // Lendo o arquivo index.html disco
    if (! file.open(&root, "index.htm", O_READ)) {
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

void configHTML(WebServerAuth &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete) {
    server.httpSuccess();

    // Se POST configura a senha
    if( type == WebServer::POST ) {
        char value[16], name[16];
        server.readPOSTparam(name, 16, value, 16);
        int valor = strtoul(value, NULL, 10);

        eepromWriteString(0, value);
        server.setAuthentication("admin", value);
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

void logout(WebServerAuth &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete) {
    server.httpSuccess();
    server.httpAuthFail();
}

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
