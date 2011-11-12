/********************************************************************************
 *                    WEBSERVER CONFIGURATION
 ********************************************************************************/
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 1, 200 };
Server server(80);
#define HTTP_HEADER_SIZE 200

prog_char html_mime_type[] PROGMEM = "Content-Type: text/html";
prog_char text_mime_type[] PROGMEM = "Content-Type: text";
prog_char head_file_not_found[] PROGMEM = "HTTP/1.1 404 Not Found\nContent-Type: text/html\n\n<h2>File Not Found!</h2>";

PROGMEM const char *string_table[] = {
  html_mime_type,
  text_mime_type,
  head_file_not_found
};

/********************************************************************************
 *                    RTC DS1302 CONFIGURATION
 ********************************************************************************/
uint8_t CE_PIN = 5;
uint8_t IO_PIN = 6;
uint8_t SCLK_PIN = 7;
Time t;
DS1302 rtc(CE_PIN, IO_PIN, SCLK_PIN);


/********************************************************************************
 *                  TERMOMETER DS18S20 CONFIGURATION
 ********************************************************************************/
#define ONE_WIRE_BUS 2
#define TEMPERATURE_PRECISION 9
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);
DeviceAddress thermometer;

// Temperaturas máximas e mínimas padrão
#define MAX_TEMPERATURE 31
#define MIN_TEMPERATURE 19


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
char log_filename[8] = "log.ard";

// função para disparar erro de leitura com o SD Card
void error_P(const char* str) {
    PgmPrint("error: ");
    SerialPrintln_P(str);
    if (sd_card.errorCode()) {
        PgmPrint("SD error: ");
        Serial.print(sd_card.errorCode(), HEX);
        Serial.print(',');
        Serial.println(sd_card.errorData(), HEX);
    }
    while(1);
}
