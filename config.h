/********************************************************************************
 *                    WEBSERVER CONFIGURATION
 ********************************************************************************/
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 1, 200 };
byte msk[] = { 255, 255, 255, 0 };
byte gw[] = { 192, 168, 1, 1 };
Server server(80);
#define HTTP_HEADER_SIZE 200
char basic_auth[32];

prog_char html_mime_type[] PROGMEM = "Content-Type: text/html";
prog_char text_mime_type[] PROGMEM = "Content-Type: text";
prog_char head_file_not_found[] PROGMEM = "HTTP/1.1 404 Not Found\nContent-Type: text/html\n\nFile Not Found!";
prog_char http_200[] PROGMEM = "HTTP/1.1 200 OK";
prog_char http_401[] PROGMEM = "HTTP/1.0 401 Authorization Required\r\nWWW-Authenticate: Basic realm=\"Arduino\"\r\nContent-Type: text/html\r\n\r\n<h1>401 Unauthorized.</h1>";

PGM_P string_table[] PROGMEM = {
  html_mime_type,
  text_mime_type,
  head_file_not_found,
  http_200,
  http_401
};

// Token utilizado para autenticação
char token[10];

/********************************************************************************
 *                    RTC DS1302 CONFIGURATION
 ********************************************************************************/
#define CE_PIN 5
#define IO_PIN 6
#define SCLK_PIN 7
//Time t;
DS1302 rtc(CE_PIN, IO_PIN, SCLK_PIN);


/********************************************************************************
 *                  TERMOMETER DS18S20 CONFIGURATION
 ********************************************************************************/
#define ONE_WIRE_BUS 2
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);
DeviceAddress thermometer;

// Temperaturas máximas e mínimas padrão
char max_temp = 31;
char min_temp = 19;
char doubt[5];
char error_c[5];

byte t_intval = 1;

/********************************************************************************
 *                  BUZZER AND LEDs CONFIGURATION
 ********************************************************************************/
#define LED_PIN 8
#define BUZZ_PIN 9


/********************************************************************************
 *                  SD CARD CONFIGURATION
 ********************************************************************************/
#define error(s) error_P(PSTR(s))
#define SD_SS_PIN 4
#define W5100_PIN 10
Sd2Card sd_card;
SdVolume sd_volume;
SdFile sd_root;
SdFile sd_file;
char log_file[8] = "log.ard";
char sec_file[8] = "sec.ard";
char tem_file[8] = "tem.ard";
char tim_file[8] = "tim.ard";

// função para disparar erro de leitura com o SD Card
void error_P(const char* str) {
    PgmPrint("ERR: ");
    SerialPrintln_P(str);
    while(1);
}
