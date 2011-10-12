#include "SPI.h"
#include "Ethernet.h"

// Network configuration
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 100, 200 };

// Server instance on port 80
Server server(80);

// Definitions
#define BUFFER_SIZE 1024
char clientline[BUFFER_SIZE];
int index = 0;
int ledPin = 5;

// Arduino Setup
void setup(){
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

          if( index < BUFFER_SIZE ) {
            clientline[index] = c;
            index++;
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
Serial.println(c);
          if( c == '\n' )
            blank = true;
          else
            if( c != '\r' )
              blank = false;

          // Check what was passed by URL
          if( strstr(clientline, "led=1") != NULL )
            digitalWrite(ledPin, HIGH);
          else
            if( strstr(clientline, "led=0") != NULL )
              digitalWrite(ledPin, LOW);

        }
      }
      Serial.println(clientline);
      delay(1);
      client.stop();
  }

}
