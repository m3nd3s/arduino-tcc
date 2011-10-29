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

// Alarm handler, should turn on the LED pin if some alarm is handled
void alarm_handler(uint8_t* device_address) {
  Serial.println("ALARM!!!!");
  float t = sensors.getTempCByIndex(0);
  digitalWrite(LED_PIN, HIGH);
  tone(BUZZ_PIN, 10, 5000);
}

/*
void render_html(Client client) {
  char *filename;
  boolean returnCSV = false;

  filename = line_header + 5;
  (strstr(line_header, " HTTP"))[0] = 0; // Force the end of line
  //Serial.print("ARQUIVO: ");
  //Serial.println(filename);

  if ( strlen(filename) == 0 ) {
    filename = "index.htm";
  } else {
    if ( strstr(filename, "getTemperature") != 0 && strstr(filename, "?token=1qaz2wsx") != 0 )
      returnCSV = true;
  }

  // Get temperature and time
  current_temp = sensors.getTempCByIndex(0);
  t = rtc.time();

  char date[10];
  char time[8];
  int d1 = current_temp;
  float f = current_temp - d1;
  int d2 = f * 100;
  sprintf(date, "%02d-%02d-%04d", t.date, t.mon, t.yr);
  sprintf(time, "%02d:%02d:%02d", t.hr, t.min, t.sec);

  if ( !returnCSV ) {
    // File not found 
    if ( !sd_file.open(&sd_root, filename, O_READ ) ) {
      client.println("HTTP/1.1 404 Not Found");
      client.println("Content-Type: text/html");
      client.println();
      client.println("<h2>File Not Found!</h2>");
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

      if ( _c == '}' || keyword.length() >= 16 ) {

        key = false;
        if ( keyword.equals( "{temp}" ) )
          client.print(current_temp);
        else if(keyword.equals( "{date}" ))
          client.print(date);
        else
          client.print(keyword);
        
        keyword = "";
      }

    }

    sd_file.close();

  } else {
    char csv[22];
    sprintf(csv, "%04d-%02d-%02d %02d:%02d:%02d,%d.%02d", t.yr, t.mon, t.date, t.hr, t.min, t.sec, d1, d2);
    client.println(csv);

  }
}
*/

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
  sensors.setHighAlarmTemp(thermometer, 28);
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
  sd_root.ls(LS_DATE | LS_SIZE);
  sd_root.ls(LS_R);
}

void loop(){

  //Serial.println("Requesting Temperatures");
  sensors.requestTemperatures();
  sensors.processAlarms(); // Alarm

  t = rtc.time();

  if ( t.sec == 0 ) {
    Serial.println("Granvando log...");
    logger();
  }

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
      
      /*
      while( client.connected() ){
        if( client.available() ){
          char c = client.read();

          // Read line
          if ( c != '\n' && c != '\r' ) {
            line_header[index++] = c;
            continue;
          }

          line_header[index] = 0;

          //Serial.print("HEADER:");
          //Serial.println(line_header);

          if( strstr(line_header, "GET /") != NULL ){
            render_html(client);
          } else {
            // 404
            client.println("HTTP/1.1 404 Not Found");
            client.println("Content-Type: text/html");
            client.println();
            client.println("<h2>File Not Found!</h2>");
          }
          break;

//          if( c == '\n' ) {
//            blank = true;
//            Serial.println(line_header);
//
//            if ( line_header.indexOf("Content-Length:") >= 0 ) {
//              line_header.substring(16).toCharArray(content_length, 64); 
//              Serial.print("Tamanho: ");
//              Serial.println(atoi(content_length));
//            }
//
//            // Check what was passed by URL
//            if( line_header.indexOf("led=1") > 0 )
//              digitalWrite(LED_PIN, HIGH);
//
//            if( line_header.indexOf("led=0") >0 )
//              digitalWrite(LED_PIN, LOW);
//
//            if ( line_header.indexOf("?token=1qaz2wsx") > 0 && line_header.indexOf("GET /getTemperature") > 0 )
//              returnJson = true;
//
//            line_header = "";
//
//          } else {
//              if( c != '\r' ) {
//                blank = false;
//              } 
//          }
        }
      }
      */
      delay(1);
      client.stop();
  }
}
