#include "Ethernet.h"
#include "WebServerAuth.h"
#include <EEPROM.h>
#include <SdFat.h>
#include <SdFatUtil.h>

#include "config.h" // Configurações e variáveis globais
#include "lib.h" // Funções



// Servidor Web (Webduino)
// Usuário e senhas default
#define PREFIX ""
WebServerAuth webserver("admin", "admin", PREFIX, 80);

void setup() {
    Ethernet.begin(mac, ip);

    char nome[8] = {};
    eepromReadString(0, nome);
    webserver.setAuthentication("admin", nome);

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
    webserver.addCommand("logout", &logout);

    // Inicializando o servidor Web
    webserver.begin();
}

void loop(){
    char buff[64];
    int len = 64;

    /* process incoming connections one at a time forever */
    webserver.processConnection(buff, &len);
}
