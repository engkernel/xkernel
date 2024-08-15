#include "vga.h"
#include "string/string.h"

uint16_t* scrn_mem = 0;
uint16_t scrn_col = 0;
uint16_t scrn_row = 0;

uint16_t scrn_make_char(char c, char colour)
{
	return ((colour << 8) | c);
}

void scrn_putchar(int x, int y, char c, char colour)
{
	scrn_mem[(y * SCRN_WIDTH) + x] = scrn_make_char(c, colour);
}

void scrn_writechar(char c, char colour)
{
	scrn_putchar(scrn_col, scrn_row, c, colour);
	scrn_col += 1;
	if (scrn_col >= SCRN_WIDTH)
	{
		scrn_col = 0;
		scrn_row += 1;
	}
}

void cls()
{
	uint16_t blank = scrn_make_char(' ', 0);
	for (int y = 0; y < SCRN_HEIGHT; y++)
	{
		for (int x = 0; x < SCRN_WIDTH; x++)
		{
			scrn_mem[(y * SCRN_WIDTH) + x] = blank;
		}
	}
}

void print(const char* str)
{
	size_t len = strlen(str);
	for (int i = 0; i < len; i++)
	{
		scrn_writechar(str[i], 15);
	}
}

void init_scrn()
{
	scrn_mem = (uint16_t*)(SCRN_ADDR);
	cls();
	print("Hello World from kernel!!");
}
