#include "SPI.h"
#include "Ethernet.h"

// Network configuration
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 1, 200 };

// Server instance on port 80
Server server(80);

// Definitions
#define BUFFER_SIZE 128
//char line_header[BUFFER_SIZE];
String line_header;
char content_length[64];
int index = 0;
int ledPin = 5;

// Arduino Setup
void setup(){
  line_header = "";
  Ethernet.begin(mac, ip);
  server.begin();
  pinMode(ledPin, OUTPUT);
  Serial.begin(9600);
}

void loop(){

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
              digitalWrite(ledPin, HIGH);
            else
              if( line_header.indexOf("led=0") >0 )
                digitalWrite(ledPin, LOW);
            
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
