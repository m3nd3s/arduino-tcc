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

