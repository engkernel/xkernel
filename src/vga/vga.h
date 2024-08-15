#ifndef VGA_H
#define VGA_H

#include <stdint.h>

#define SCRN_ADDR 0xB8000
#define SCRN_HEIGHT 80
#define SCRN_WIDTH 80

void init_scrn();
uint16_t scrn_make_char(char c, char colour);
void cls();

#endif // VGA_H
