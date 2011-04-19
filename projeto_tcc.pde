#include "Ethernet.h"
#include "SPI.h"
#include "WebServerAuth.h"
#include <EEPROM.h>
#include <SD.h>
#include <string.h>

#include <stdio.h>
#include <DS1302.h>
#include <OneWire.h>
#include <DallasTemperature.h>

#include "config.h" // Configurações e variáveis globais
#include "lib.h" // Funções



// Servidor Web (Webduino)
// Usuário e senhas default
#define PREFIX ""
WebServerAuth webserver("admin", "admin", PREFIX, 80);

void setup() {
    Serial.begin(9600);
    Ethernet.begin(mac, ip);
    sensors.begin();

    char nome[8] = {};
    eepromReadString(0, nome);
    //webserver.setAuthentication("admin", nome);

    // Configuração necessária para leitura do microSD card
    pinMode(10, OUTPUT);
    digitalWrite(10, HIGH);
    
    // Inicializando o SD Card
    if (!card.init(SPI_HALF_SPEED, 4)) error("card.init failed!");
    if (!volume.init(&card)) error("vol.init failed!");
    if (!root.openRoot(&volume)) error("openRoot failed");
    root.ls(LS_DATE | LS_SIZE);
    root.ls(LS_R);

    // Configurando comandos
    webserver.setDefaultCommand(&indexHTML);
    webserver.addCommand("config", &configHTML);
    //webserver.addCommand("logout", &logout);

    // Inicializando o servidor Web
    webserver.begin();
    
    /* Initialize a new chip by turning off write protection and clearing the
     clock halt flag. These methods needn't always be called. See the DS1302
     datasheet for details. */
    rtc.write_protect(false);
    rtc.halt(false);
  
    /* Make a new time object to set the date and time */
    /*   Tuesday, May 19, 2009 at 21:16:37.            */
    Time t(2011, 4, 15, 20, 17, 17, 6);
  
    /* Set the time and date on the chip */
    rtc.time(t);
}

void loop(){
    char buff[64];
    int len = 64;

    /* process incoming connections one at a time forever */
    webserver.processConnection(buff, &len);
}
