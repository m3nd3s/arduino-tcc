// Incluindo bibliotecas
#include <SPI.h>
#include <Ethernet.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <DS1302.h>
#include <SD.h>
#include <EEPROM.h>
#include <avr/pgmspace.h>

// Configurações
#include "config.h"

// Incluindo funções de uso
#include "func.h"

// Arduino Setup
void setup(){

  // Beginning the services
  sensors.begin();
  Serial.begin(9600);

  // Set led mode
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZ_PIN, OUTPUT);

  /********************************************
  * Inicializa o SD e carrega as configurações
  *********************************************/
  if (!sd_card.init(SPI_HALF_SPEED, SD_SS_PIN)) error("card.init failed!");
  if (!sd_volume.init(&sd_card)) error("vol.init failed!");
  if (!sd_root.openRoot(&sd_volume)) error("openRoot failed");

  // Load Configurations
  load_configuration();

  /*********************************************
  *         DS18S20 - Thermometer
  **********************************************/
  // Thermometer address
  sensors.getAddress(thermometer, 0);
  // alarm when temp is high
  sensors.setHighAlarmTemp(thermometer, max_temperature);
  // alarm when temp is low
  sensors.setLowAlarmTemp(thermometer, min_temperature); 
  // set alarm handle
  sensors.setAlarmHandler(&alarm_handler);

  /*********************************************
  *         DS1302 - RTC
  *********************************************/
  /* Initialize a new chip by turning off write protection and clearing the
  clock halt flag. These methods needn't always be called. See the DS1302
  datasheet for details. */
  rtc.write_protect(false);
  rtc.halt(false);

  /* Make a new time object to set the date and time */
  /* Tuesday, May 19, 2009 at 21:16:37. */
  //Time t(2011, 11, 12, 15, 47, 40, 0);

  /* Set the time and date on the chip */
  //rtc.time(t);

  /*********************************************
  *       SD CARD
  **********************************************/
  pinMode(W5100_PIN, OUTPUT);
  digitalWrite(W5100_PIN, HIGH);
  
  // Inicializa o server
  Ethernet.begin(mac, ip, gw, msk);
  server.begin();
}

void loop(){

  sensors.requestTemperatures();
  sensors.processAlarms(); // Alarm

  t = rtc.time();

  // Minuto a minuto
  if ( ( t.min % 5 ) == 0 && t.sec == 0 ) {
    Serial.println("Loggin Temperature... ");
    //logger();
    delay(10);
  }

  // If no sensor alarm, turn of LED and BUZZER
  if ( !sensors.hasAlarm() ) {
    digitalWrite(LED_PIN, LOW);
    noTone(BUZZ_PIN);
  }

  // listen for incoming clients
  Client client = server.available();

  if ( client ) {
      processing_request(client);
  }
}
