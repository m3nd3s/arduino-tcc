#include "Ethernet.h"
#include "WebServerAuth.h"
#include <EEPROM.h>
#include <SdFat.h>
#include <SdFatUtil.h>
// Biblioteca util
#include "util.h"

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
WebServerAuth webserver("admin", "123456", PREFIX, 80);

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
