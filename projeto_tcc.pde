#include "SPI.h"
#include "Ethernet.h"

// Network configuration
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 100, 200 };

// Server instance on port 80
Server server(80);

// Arduino Setup
void setup(){
  Ethernet.begin(mac, ip);
  server.begin();
}

void loop(){

  // listen for incoming clients
  Client client = server.available();
  if ( client ) {
      boolean blank = true;

      while( client.connected() ){
        if( client.available() ){
          char c = client.read();

          if( c == '\n' && blank ){
            client.println("HTTP/1.1 200 OK");
            client.println("Content-Type: text/html");
            client.println();

            client.println("<h1>ARDUINO</h1>");
            break;
          }

          if( c == '\n' )
            blank = true;
          else
            if( c != '\r' )
              blank = false;
        }
      }
      delay(1);
      client.stop();
  }

}
