/**
* Variáveis globais
*/

//
// SD  Card
//
Sd2Card card;
SdVolume volume;
SdFile root;
SdFile file;

#define NAMELEN 32
#define VALUELEN 32
#define error(s) error_P(PSTR(s))

//
// Ethernet
//
static uint8_t mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
static uint8_t ip[4] = { 192, 168, 42, 51 };

//
// Pino de conexao do sensor de temperatura
//
#define ONE_WIRE_BUS 2
// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);
// Pass our oneWire reference to Dallas Temperature. 
DallasTemperature sensors(&oneWire);

// RTC

/* Set the appropriate digital I/O pin connections */
uint8_t CE_PIN   = 5;
uint8_t IO_PIN   = 6;
uint8_t SCLK_PIN = 7;

/* LED */
uint8_t LED_PIN = 8;
bool LED_ON = false;
float TEMP;

/* Timer */
Time t;

/* Create buffers */
char buf[60];
char day[10];

/* Create a DS1302 object */
DS1302 rtc(CE_PIN, IO_PIN, SCLK_PIN);

