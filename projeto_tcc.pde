#include <SPI.h>
#include <Ethernet.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <DS1302.h>

// Network configuration
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 1, 200 };

// Server instance on port 80
Server server(80);

// Definitions
#define BUFFER_SIZE 128
#define ONE_WIRE_BUS 2
#define TEMPERATURE_PRECISION 9
#define LEDPIN 8
#define BUZZPIN 9

/********************************************************************************
*                               RTC DS1302
*               Set the appropriate digital I/O pin connections
*********************************************************************************/
uint8_t CE_PIN = 5;
uint8_t IO_PIN = 6;
uint8_t SCLK_PIN = 7;
Time t;
DS1302 rtc(CE_PIN, IO_PIN, SCLK_PIN);

//char line_header[BUFFER_SIZE];
String line_header;
char content_length[64];
int index = 0;

// Configuring the OneWire bus, to temperature sensors
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);
DeviceAddress thermometer;
float current_temp;

// Alarm handler, should turn on the LED pin if some alarm is handled
void alarm_handler(uint8_t* device_address) {
  Serial.println("ALARM!!!!");
  float t = sensors.getTempCByIndex(0);
  Serial.println(t);
  digitalWrite(LEDPIN, HIGH);
  tone(BUZZPIN, 10, 5000);
}

// Arduino Setup
void setup(){
  line_header = "";

  // Beginning the services
  Ethernet.begin(mac, ip);
  server.begin();
  sensors.begin();
  Serial.begin(9600);

  // Set led mode
  pinMode(LEDPIN, OUTPUT);
  pinMode(BUZZPIN, OUTPUT);

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
}

void loop(){

  Serial.println("Requesting Temperatures");
  sensors.requestTemperatures();
  sensors.processAlarms(); // Alarm


  if ( !sensors.hasAlarm() ) {
    digitalWrite(LEDPIN, LOW);
    noTone(BUZZPIN);
  }

  // listen for incoming clients
  Client client = server.available();

  if ( client ) {
      boolean blank = true;
      boolean returnJson = false;
      index = 0;
      current_temp = 0;

      while( client.connected() ){
        if( client.available() ){
          char c = client.read();

          if( line_header.length() < 100 ) {
            line_header += c;
          }

          if( c == '\n' && blank ){
            client.println("HTTP/1.1 200 OK");
            client.println("Content-Type: text/html");
            client.println();

            current_temp = sensors.getTempCByIndex(0);
            t = rtc.time();

            if( returnJson ) {
              char dtt_json[25];
              int d1 = current_temp;
              float f = current_temp - d1;
              int d2 = f * 100;
              sprintf(dtt_json, "%04d-%02d-%02d %02d:%02d:%02d,%d.%02d", t.yr, t.mon, t.date, t.hr, t.min, t.sec, d1, d2);
              client.println(dtt_json);
            }
            else{
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
            break;
          }

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
              digitalWrite(LEDPIN, HIGH);

            if( line_header.indexOf("led=0") >0 )
              digitalWrite(LEDPIN, LOW);

            if ( line_header.indexOf("?token=1qaz2wsx") > 0 && line_header.indexOf("GET /getTemperature") > 0 )
              returnJson = true;

            line_header = "";

          } else {
              if( c != '\r' ) {
                blank = false;
              } 
          }
        }
      }
      delay(1);
      client.stop();
  }
}
