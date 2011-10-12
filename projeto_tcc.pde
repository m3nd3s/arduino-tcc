#include "SPI.h"
#include "Ethernet.h"

// Network configuration
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 100, 200 };

// Server instance on port 80
Server server(80);

// Definitions
#define BUFFER_SIZE 100
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

            client.println("<h1>ARDUINO</h1> <form><input type='hidden' value='1' name='action' /><input type='submit' value='LIGAR' /></form>");
            break;
          }

          if( c == '\n' )
            blank = true;
          else
            if( c != '\r' )
              blank = false;

          // Check what was passed by URL
          if( strstr(clientline, "/?action=1") != 0 )
            digitalWrite(ledPin, HIGH);
          else
            if( strstr(clientline, "/?action=0") != 0 )
              digitalWrite(ledPin, LOW);

        }
      }
      Serial.print("SAIDA: ");
      Serial.println(clientline);
      Serial.print("Comparacao: ");
      Serial.println(strlen(strstr(clientline, "/?ation=1")));
      delay(1);
      client.stop();
  }

}
