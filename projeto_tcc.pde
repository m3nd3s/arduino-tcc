// Incluindo bibliotecas
#include <SPI.h>
#include <Ethernet.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <DS1302.h>
#include <SD.h>

// Configurações
#include "config.h"

// Incluindo funções de uso
#include "func.h"

// Arduino Setup
void setup(){
  // Beginning the services
  Ethernet.begin(mac, ip);
  server.begin();
  sensors.begin();
  Serial.begin(9600);

  // Set led mode
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZ_PIN, OUTPUT);

  /*********************************************
  *         DS18S20 - Thermometer
  **********************************************/
  // Thermometer address
  sensors.getAddress(thermometer, 0);
  // alarm when temp is higher than 28C
  sensors.setHighAlarmTemp(thermometer, 29);
  // alarm when temp is lower than 19C
  sensors.setLowAlarmTemp(thermometer, 19); 
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
  Time t(2011, 10, 22, 0, 0, 0, 0);

  /* Set the time and date on the chip */
  rtc.time(t);

  /*********************************************
  *       SD CARD
  **********************************************/
  pinMode(W5100_PIN, OUTPUT);
  digitalWrite(W5100_PIN, HIGH);
  
  if (!sd_card.init(SPI_HALF_SPEED, SD_SS_PIN)) error("card.init failed!");
  if (!sd_volume.init(&sd_card)) error("vol.init failed!");
  if (!sd_root.openRoot(&sd_volume)) error("openRoot failed");
  //sd_root.ls(LS_DATE | LS_SIZE);
  //sd_root.ls(LS_R);
}

void loop(){

  sensors.requestTemperatures();
  sensors.processAlarms(); // Alarm

  t = rtc.time();

  // Minuto a minuto
/*  if ( ( t.min % 10 ) == 0 ) {
    Serial.print("LOGGER: ");
    Serial.println(t.sec);
    logger();
  }
*/

  // If no sensor alarm, turn of LED and BUZZER
  if ( !sensors.hasAlarm() ) {
    digitalWrite(LED_PIN, LOW);
    noTone(BUZZ_PIN);
  }

  // listen for incoming clients
  Client client = server.available();

  if ( client ) {
      //memset(line_header, 0, 100);
      processing_request(client);
      delay(1);
      client.stop();
  }
}
