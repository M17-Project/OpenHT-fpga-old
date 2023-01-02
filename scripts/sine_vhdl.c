/*******************************************\
 * VHDL sine/cosine lookup table           *
 * code generating script                  *
 *                                         *
 * Wojciech Kaczmarski, SP5WWP             *
 * M17 Project                             *
 * January 2023                            *
\*******************************************/

#define _USE_MATH_DEFINES
#define AMPLITUDE		0x7F90

#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include <math.h>

int main(void)
{
	printf("type lut_arr is array (integer range 0 to 255) of std_logic_vector (15 downto 0);\n\n");
	printf("constant sinlut : lut_arr := (\n");
	
	for(uint16_t i=0; i<256; i+=4)
	{
		uint16_t v[4];
		
		v[0]=0x8000+(float)AMPLITUDE*(sin((i+0)/256.0*2.0*M_PI));
		v[1]=0x8000+(float)AMPLITUDE*(sin((i+1)/256.0*2.0*M_PI));
		v[2]=0x8000+(float)AMPLITUDE*(sin((i+2)/256.0*2.0*M_PI));
		v[3]=0x8000+(float)AMPLITUDE*(sin((i+3)/256.0*2.0*M_PI));
		
		if(i<252)
			printf("\tx\"%04X\", x\"%04X\", x\"%04X\", x\"%04X\",\n", v[0], v[1], v[2], v[3]);
		else
		{
			printf("\tx\"%04X\", x\"%04X\", x\"%04X\", x\"%04X\"\n);\n", v[0], v[1], v[2], v[3]);
		}
	}
	
	printf("\nconstant coslut : lut_arr := (\n");
	
	for(uint16_t i=0; i<256; i+=4)
	{
		uint16_t v[4];
		
		v[0]=0x8000+(float)AMPLITUDE*(cos((i+0)/256.0*2.0*M_PI));
		v[1]=0x8000+(float)AMPLITUDE*(cos((i+1)/256.0*2.0*M_PI));
		v[2]=0x8000+(float)AMPLITUDE*(cos((i+2)/256.0*2.0*M_PI));
		v[3]=0x8000+(float)AMPLITUDE*(cos((i+3)/256.0*2.0*M_PI));
		
		if(i<252)
			printf("\tx\"%04X\", x\"%04X\", x\"%04X\", x\"%04X\",\n", v[0], v[1], v[2], v[3]);
		else
		{
			printf("\tx\"%04X\", x\"%04X\", x\"%04X\", x\"%04X\"\n);\n", v[0], v[1], v[2], v[3]);
		}
	}	

	return 0;
}

