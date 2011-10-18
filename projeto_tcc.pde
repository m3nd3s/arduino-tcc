#include <SPI.h>
#include <Ethernet.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// Network configuration
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 1, 200 };

// Server instance on port 80
Server server(80);

// Definitions
#define BUFFER_SIZE 128
#define ONE_WIRE_BUS 2
#define TEMPERATURE_PRECISION 9
#define LEDPIN 5

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
  digitalWrite(LEDPIN, HIGH);
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

  // Thermometer address
  sensors.getAddress(thermometer, 0);
  // alarm when temp is higher than 28C
  sensors.setHighAlarmTemp(thermometer, 25);
  // alarm when temp is lower than 19C
  sensors.setLowAlarmTemp(thermometer, 19); 
  // set alarm handle
  sensors.setAlarmHandler(&alarm_handler);
}

void loop(){

  Serial.println("Requesting Temperatures");
  sensors.requestTemperatures();

  if ( !sensors.hasAlarm() ) {
    digitalWrite(LEDPIN, LOW);
  }

  // Alarm
  sensors.processAlarms();

  // listen for incoming clients
  Client client = server.available();

  if ( client ) {

      boolean blank = true;
      index = 0;

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

            client.println("<h1>ARDUINO</h1>");

            current_temp = sensors.getTempCByIndex(0);
            client.print("<h3>Temperatura atual: ");
            client.print(current_temp);
            Serial.println(current_temp);
            client.println("</h3>");


            client.println("<form method='POST' action='/?'>");
            client.println("<input type='radio' value='1' name='led' id='led1' /><label for='led1'>LIGAR</label>");
            client.println("<input type='radio' value='0' name='led' id='led2' /><label for='led2'>DESLIGAR</label>");
            client.println("<input type='submit' value='ENVIAR' /><br />");
            client.println("</form>");
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
            else
              if( line_header.indexOf("led=0") >0 )
                digitalWrite(LEDPIN, LOW);
            
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
