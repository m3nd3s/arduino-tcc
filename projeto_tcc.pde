/********************************************************************************
 *                    INCLUDING LIBRARIES
 ********************************************************************************/
#include <SPI.h>
#include <Ethernet.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <DS1302.h>
#include <SD.h>
// Include the file configuration
#include "config.h"

// Some variables
char line_header[100];
char content_length[64];
int index = 0;
float current_temp;

// Alarm handler, should turn on the LED pin if some alarm is handled
void alarm_handler(uint8_t* device_address) {
  Serial.println("ALARM!!!!");
  float t = sensors.getTempCByIndex(0);
  Serial.println(t);
  digitalWrite(LED_PIN, HIGH);
  tone(BUZZ_PIN, 10, 5000);
}

void render_html(Client client) {
  char *filename;
  filename = line_header + 5;
  (strstr(line_header, " HTTP"))[0] = 0; // Force the end of line
  Serial.print("ARQUIVO: ");
  Serial.println(filename);

  if ( strlen(filename) == 0 ) {
    filename = "index.htm";
  }

  // File not found 
  if ( !sd_file.open(&sd_root, filename, O_READ ) ) {
    client.println("HTTP/1.1 404 Not Found");
    client.println("Content-Type: text/html");
    client.println();
    client.println("<h2>File Not Found!</h2>");
  }

  client.println("HTTP/1.1 200 OK");
  client.println("Content-Type: text/html");
  client.println();

  char _c;
  // Read file from SD Card
  while( ( _c = sd_file.read() ) > 0 ) {
    client.print(_c);
  }
  sd_file.close();
}

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
  sensors.setHighAlarmTemp(thermometer, 25);
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


  if ( !sensors.hasAlarm() ) {
    digitalWrite(LED_PIN, LOW);
    noTone(BUZZ_PIN);
  }

  // listen for incoming clients
  Client client = server.available();

  if ( client ) {
      boolean blank = true;
      boolean returnJson = false;
      index = 0;
      current_temp = 0;
      memset(line_header, 0, 100);

      while( client.connected() ){
        if( client.available() ){
          char c = client.read();

          // Read line
          if ( c != '\n' && c != '\r' ) {
            line_header[index++] = c;
            continue;
          }

          line_header[index] = 0;

          Serial.print("HEADER:");
          Serial.println(line_header);

          if( strstr(line_header, "GET /") != NULL ){
            //client.println("HTTP/1.1 200 OK");
            //client.println("Content-Type: text/html");
            //client.println();
            render_html(client);
/*
            current_temp = sensors.getTempCByIndex(0);
            t = rtc.time();

            if( returnJson ) {
              char dtt_json[25];
              int d1 = current_temp;
              float f = current_temp - d1;
              int d2 = f * 100;
              sprintf(dtt_json, "%04d-%02d-%02d %02d:%02d:%02d,%d.%02d", t.yr, t.mon, t.date, t.hr, t.min, t.sec, d1, d2);
              client.println(dtt_json);
            } else {
              client.println("<h1>ARDUINO</h1>");

              client.print("<h3>Temperatura atual: ");
              client.print(current_temp);
              Serial.println(current_temp);
              client.println("</h3>");

              client.print("<h3>Data/Hora atual: ");
              char datetime[19];
              sprintf(datetime, "%02d/%02d/%04d %02d:%02d:%02d", t.date, t.mon, t.yr, t.hr, t.min, t.sec);
              client.print(datetime);
              client.println("</h3>");

              client.println("<form method='POST' action='/?'>");
              client.println("<input type='radio' value='1' name='led' id='led1' /><label for='led1'>LIGAR</label>");
              client.println("<input type='radio' value='0' name='led' id='led2' /><label for='led2'>DESLIGAR</label>");
              client.println("<input type='submit' value='ENVIAR' /><br />");
              client.println("</form>");
            }
*/
          } else {
            // 404
            client.println("HTTP/1.1 404 Not Found");
            client.println("Content-Type: text/html");
            client.println();
            client.println("<h2>File Not Found!</h2>");
          }
          break;

/*
          if( c == '\n' ) {
            blank = true;
            Serial.println(line_header);

            if ( line_header.indexOf("Content-Length:") >= 0 ) {
              line_header.substring(16).toCharArray(content_length, 64); 
              Serial.print("Tamanho: ");
              Serial.println(atoi(content_length));
            }

            // Check what was passed by URL
            if( line_header.indexOf("led=1") > 0 )
              digitalWrite(LED_PIN, HIGH);

            if( line_header.indexOf("led=0") >0 )
              digitalWrite(LED_PIN, LOW);

            if ( line_header.indexOf("?token=1qaz2wsx") > 0 && line_header.indexOf("GET /getTemperature") > 0 )
              returnJson = true;

            line_header = "";

          } else {
              if( c != '\r' ) {
                blank = false;
              } 
          }
*/
        }
      }
      delay(1);
      client.stop();
  }
}
