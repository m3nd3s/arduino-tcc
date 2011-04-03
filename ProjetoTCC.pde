#include "Ethernet.h"
#include "WebServer.h"
#include <EEPROM.h>
#include <SdFat.h>
#include <SdFatUtil.h>

/************ SDCARD STUFF ************/
Sd2Card card;
SdVolume volume;
SdFile root;
SdFile file;

#define NAMELEN 32
#define VALUELEN 32

#define error(s) error_P(PSTR(s))

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

void ListFiles(WebServer &client, uint8_t flags) {
    // This code is just copied from SdFile.cpp in the SDFat library
    // and tweaked to print to the client output in html!
    dir_t p;

    root.rewind();
    client.println("<ul>");
    while (root.readDir(p) > 0) {
        // done if past last used entry
        if (p.name[0] == DIR_NAME_FREE) break;

        // skip deleted entry and entries for . and ..
        if (p.name[0] == DIR_NAME_DELETED || p.name[0] == '.') continue;

        // only list subdirectories and files
        if (!DIR_IS_FILE_OR_SUBDIR(&p)) continue;

        // print any indent spaces
        client.print("<li><a href=\"");
        for (uint8_t i = 0; i < 11; i++) {
            if (p.name[i] == ' ') continue;
            if (i == 8) {
                client.print('.');
            }
            client.print(p.name[i]);
        }
        client.print("\">");

        // print file name with possible blank fill
        for (uint8_t i = 0; i < 11; i++) {
            if (p.name[i] == ' ') continue;
            if (i == 8) {
                client.print('.');
            }
            client.print(p.name[i]);
        }

        client.print("</a>");

        if (DIR_IS_SUBDIR(&p)) {
            client.print('/');
        }

        // print modify date/time if requested
        if (flags & LS_DATE) {
            root.printFatDate(p.lastWriteDate);
            client.print(' ');
            root.printFatTime(p.lastWriteTime);
        }
        // print size if requested
        if (!DIR_IS_SUBDIR(&p) && (flags & LS_SIZE)) {
            client.print(' ');
            client.print(p.fileSize);
        }
        client.println("</li>");
    }
    client.println("</ul>");
}

/* CHANGE THIS TO YOUR OWN UNIQUE VALUE.  The MAC number should be
 * different from any other devices on your network or you'll have
 * problems receiving packets. */
static uint8_t mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };


/* CHANGE THIS TO MATCH YOUR HOST NETWORK.  Most home networks are in
 * the 192.168.0.XXX or 192.168.1.XXX subrange.  Pick an address
 * that's not in use and isn't going to be automatically allocated by
 * DHCP from your router. */
static uint8_t ip[4] = { 192, 168, 42, 51 };

/* This creates an instance of the webserver.  By specifying a prefix
 * of "/", all pages will be at the root of the server. */
#define PREFIX ""
WebServer webserver(PREFIX, 80);

void stylesCss(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
    URLPARAM_RESULT rc;
    char name[NAMELEN];
    int  name_len;
    char value[VALUELEN];
    int value_len;
    server.httpSuccess();

    if ( type == WebServer::GET ) {
        if( strlen(url_tail) ) {
            while (strlen(url_tail)) {
                rc = server.nextURLparam(&url_tail, name, NAMELEN, value, VALUELEN);
                if (rc == URLPARAM_EOS)
                    server.println("<hr />");
                else {
                    server.print(name);
                    server.println(" = ");
                    server.print(value);
                }
            }
        }


        if (! file.open(&root, "styles.css", O_READ)) {
            server.println("HTTP/1.1 404 Not Found");
            server.println("Content-Type: text/html");
            server.println();
            server.println("<h2>File Not Found!</h2>");
        } else {
            server.println("Content-Type: text/plain");
        }

        int16_t c;
        while ((c = file.read()) > 0) {
            server.print((char)c);
        }
        file.close();

        server.print("<h1>FILENAME");
        server.print(url_tail);
        server.println("</h1>");
    }
}

void loadHTMLPage(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
    URLPARAM_RESULT rc;
    char name[NAMELEN];
    int  name_len;
    char value[VALUELEN];
    int value_len;
    server.httpSuccess();

    if ( type == WebServer::GET ) {
        if( strlen(url_tail) ) {
            while (strlen(url_tail)) {
                rc = server.nextURLparam(&url_tail, name, NAMELEN, value, VALUELEN);
                if (rc == URLPARAM_EOS)
                    server.println("<hr />");
                else {
                    server.print(name);
                    server.println(" = ");
                    server.print(value);
                }
            }
        }


        if (! file.open(&root, "index.htm", O_READ)) {
            server.println("HTTP/1.1 404 Not Found");
            server.println("Content-Type: text/html");
            server.println();
            server.println("<h2>File Not Found!</h2>");
        }

        int16_t c;
        while ((c = file.read()) > 0) {
            // uncomment the serial to debug (slow!)
            //Serial.print((char)c);
            server.print((char)c);
        }
        file.close();

        server.print("<h1>FILENAME");
        server.print(url_tail);
        server.println("</h1>");
    }
}


/* commands are functions that get called by the webserver framework
 * they can read any posted data from client, and they output to the
 * server to send data back to the web browser. */
void helloCmd(WebServer &server, WebServer::ConnectionType type, char *, bool)
{
    /* this line sends the standard "we're all OK" headers back to the
       browser */
    server.httpSuccess();

    if( type == WebServer::POST ) {
        char value[16], name[16];
        server.readPOSTparam(name, 16, value, 16);
        int valor = strtoul(value, NULL, 10);
        EEPROM.write(0, valor);
    }

    /* if we're handling a GET or POST, we can output our data here.
       For a HEAD request, we just stop after outputting headers. */
    if (type != WebServer::HEAD)
    {
        int valor_r = EEPROM.read(0);
        /* this defines some HTML text in read-only memory aka PROGMEM.
         * This is needed to avoid having the string copied to our limited
         * amount of RAM. */
        P(helloMsg) = "<h1>Hello, World!</h1>";
        P(nome) = "<a href='/config'>CONFIG</a>";

        /* this is a special form of print that outputs from PROGMEM */
        server.printP(helloMsg);
        server.printP(nome);

        server.print("<form method='post' action='/config'>");
        server.print("<input type='text' value='' name='campo' />");
        server.print("<input type='submit' value='OK' />");
        server.print("</form>");

        server.println("<h4>Meu valor armazenado: ");
        server.print(valor_r);
        server.print("</h4>");


        ListFiles(server, LS_SIZE);


    }

}

void setup()
{
    /* initialize the Ethernet adapter */
    Ethernet.begin(mac, ip);

    /* setup our default command that will be run when the user accesses
     * the root page on the server */
    webserver.setDefaultCommand(&loadHTMLPage);

    /* run the same command if you try to load /index.html, a common
     * default page name */
    //webserver.addCommand("index.html", &helloCmd);
    webserver.addCommand("config", &helloCmd);
    webserver.addCommand("stylescss", &stylesCss);

    Serial.begin(9600);

    // initialize the SD card at SPI_HALF_SPEED to avoid bus errors with
    // breadboards. use SPI_FULL_SPEED for better performance.
    pinMode(10, OUTPUT); // set the SS pin as an output (necessary!)
    digitalWrite(10, HIGH); // but turn off the W5100 chip! // initialize the SD card at SPI_HALF_SPEED to avoid bus errors with
    // breadboards. use SPI_FULL_SPEED for better performance.
    pinMode(10, OUTPUT); // set the SS pin as an output (necessary!)
    digitalWrite(10, HIGH); // but turn off the W5100 chip!

    if (!card.init(SPI_HALF_SPEED, 4)) error("card.init failed!");

    // initialize a FAT volume
    if (!volume.init(&card)) error("vol.init failed!");

    if (!root.openRoot(&volume)) error("openRoot failed");

    root.ls(LS_DATE | LS_SIZE);
    root.ls(LS_R);

    /* start the webserver */
    webserver.begin();
}

void loop()
{
    char buff[64];
    int len = 64;

    /* process incoming connections one at a time forever */
    webserver.processConnection(buff, &len);
}
