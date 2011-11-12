/******************************************************
 *                  CONFIGURAÇÃO
 *****************************************************/
#include <Client.h>
#include <Server.h>
#include <SD.h>

#define SD_SS_PIN 4
#define W5100_PIN 10

#define HTTP_REQUEST_SIZE 32

class Webserver {
  public:
    void begin();
    void process_connection();
    Webserver();

  private:
    // WebServer
    Server server;
    Client client;
    char path[12];
    bool is_post;

    // SD
    Sd2Card sd_card;
    SdVolume sd_volume;
    SdFile sd_root;
    SdFile sd_file;

    // Métodos
    void file_not_found();
    bool render();
    void read_post_params( char *params );
    void error_P( const char* str );
};
