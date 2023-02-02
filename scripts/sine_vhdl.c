/*******************************************\
 * VHDL sine/cosine lookup table           *
 * code generating script                  *
 *                                         *
 * Wojciech Kaczmarski, SP5WWP             *
 * M17 Project                             *
 * February 2023                            *
\*******************************************/

#define _USE_MATH_DEFINES
#define AMPLITUDE		0xFFF
#define LUT_SIZE		1024		//a power of 2 is recommended
#define SIN_TABLE
//#define COS_TABLE

#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include <math.h>

int main(void)
{
	#if defined(SIN_TABLE) || defined(COS_TABLE)
	printf("type lut_arr is array (integer range 0 to %d) of std_logic_vector (15 downto 0);\n\n", LUT_SIZE-1);
	
	#ifdef SIN_TABLE
	printf("constant sinlut : lut_arr := (\n");
	
	for(uint32_t i=0; i<LUT_SIZE; i+=4)
	{
		uint16_t v[4];
		
		/*
		v[0]=0x8000+(float)AMPLITUDE*(sin((i+0)/256.0*2.0*M_PI));
		v[1]=0x8000+(float)AMPLITUDE*(sin((i+1)/256.0*2.0*M_PI));
		v[2]=0x8000+(float)AMPLITUDE*(sin((i+2)/256.0*2.0*M_PI));
		v[3]=0x8000+(float)AMPLITUDE*(sin((i+3)/256.0*2.0*M_PI));
		*/
		
		v[0]=(uint16_t)roundf((float)AMPLITUDE*(sin((i+0)/(float)LUT_SIZE*2.0*M_PI)+1.0)/2.0);
		v[1]=(uint16_t)roundf((float)AMPLITUDE*(sin((i+1)/(float)LUT_SIZE*2.0*M_PI)+1.0)/2.0);
		v[2]=(uint16_t)roundf((float)AMPLITUDE*(sin((i+2)/(float)LUT_SIZE*2.0*M_PI)+1.0)/2.0);
		v[3]=(uint16_t)roundf((float)AMPLITUDE*(sin((i+3)/(float)LUT_SIZE*2.0*M_PI)+1.0)/2.0);
		
		if(i<LUT_SIZE-4)
			printf("\tx\"%03X\", x\"%03X\", x\"%03X\", x\"%03X\",\n", v[0], v[1], v[2], v[3]);
		else
		{
			printf("\tx\"%03X\", x\"%03X\", x\"%03X\", x\"%03X\"\n);\n", v[0], v[1], v[2], v[3]);
		}
	}
	
	printf("\n");
	#endif
	
	#ifdef COS_TABLE
	printf("constant coslut : lut_arr := (\n");
	
	for(uint32_t i=0; i<LUT_SIZE; i+=4)
	{
		uint16_t v[4];
		
		/*
		v[0]=0x8000+(float)AMPLITUDE*(cos((i+0)/256.0*2.0*M_PI));
		v[1]=0x8000+(float)AMPLITUDE*(cos((i+1)/256.0*2.0*M_PI));
		v[2]=0x8000+(float)AMPLITUDE*(cos((i+2)/256.0*2.0*M_PI));
		v[3]=0x8000+(float)AMPLITUDE*(cos((i+3)/256.0*2.0*M_PI));
		*/
		
		v[0]=(uint16_t)roundf((float)AMPLITUDE*(cos((i+0)/(float)LUT_SIZE*2.0*M_PI)+1.0)/2.0);
		v[1]=(uint16_t)roundf((float)AMPLITUDE*(cos((i+1)/(float)LUT_SIZE*2.0*M_PI)+1.0)/2.0);
		v[2]=(uint16_t)roundf((float)AMPLITUDE*(cos((i+2)/(float)LUT_SIZE*2.0*M_PI)+1.0)/2.0);
		v[3]=(uint16_t)roundf((float)AMPLITUDE*(cos((i+3)/(float)LUT_SIZE*2.0*M_PI)+1.0)/2.0);
		
		if(i<LUT_SIZE-4)
			printf("\tx\"%03X\", x\"%03X\", x\"%03X\", x\"%03X\",\n", v[0], v[1], v[2], v[3]);
		else
		{
			printf("\tx\"%03X\", x\"%03X\", x\"%03X\", x\"%03X\"\n);", v[0], v[1], v[2], v[3]);
		}
	}
	
	printf("\n");
	#endif
	#endif
	
	return 0;
}
