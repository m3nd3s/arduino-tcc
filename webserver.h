/******************************************************
 *                  CONFIGURAÇÃO
 *****************************************************/
#define HTTP_REQUEST_SIZE 32

class Webserver {
  public:

  private:
    // Variáveis
    Server server;
    Client client;
    char path[12];
    bool is_post;

    // Métodos
    void file_not_found();
    bool render( const char *filename )
    void begin();
    void process_connection();
    void read_post_params( char *params );
}
