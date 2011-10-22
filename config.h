/********************************************************************************
 *                    WEBSERVER CONFIGURATION
 ********************************************************************************/
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 1, 200 };
Server server(80);


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

// Grava o log no SD
void logger() {
    if ( sd_file.open(&sd_root, log_filename, O_CREAT | O_APPEND | O_WRITE ) ) {
       sd_file.println("Oiiiii");
       sd_file.close();
    }
}
