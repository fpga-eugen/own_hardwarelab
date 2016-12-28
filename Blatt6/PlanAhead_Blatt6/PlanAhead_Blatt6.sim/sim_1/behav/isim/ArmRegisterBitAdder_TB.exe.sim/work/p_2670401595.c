/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "Function booltosl ended without a return statement";



unsigned char work_p_2670401595_sub_4286129246_222227238(char *t1, unsigned char t2)
{
    char t4[8];
    unsigned char t0;
    char *t5;
    unsigned char t6;

LAB0:    t5 = (t4 + 4U);
    *((unsigned char *)t5) = t2;
    t6 = (t2 == (unsigned char)0);
    if (t6 != 0)
        goto LAB2;

LAB4:    t0 = (unsigned char)3;

LAB1:    return t0;
LAB2:    t0 = (unsigned char)2;
    goto LAB1;

LAB3:    xsi_error(ng0);
    t0 = 0;
    goto LAB1;

LAB5:    goto LAB3;

LAB6:    goto LAB3;

}


void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

void ieee_p_2592010699_sub_3130575329_503743352();

extern void work_p_2670401595_init()
{
	static char *se[] = {(void *)work_p_2670401595_sub_4286129246_222227238};
	xsi_register_didat("work_p_2670401595", "isim/ArmRegisterBitAdder_TB.exe.sim/work/p_2670401595.didat");
	xsi_register_subprogram_executes(se);
	xsi_register_resolution_function(1, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(2, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(3, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(4, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(5, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(6, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(7, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(8, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(9, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(17, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(20, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(23, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(24, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(25, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(60, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
	xsi_register_resolution_function(61, 2, (void *)ieee_p_2592010699_sub_3130575329_503743352, 3);
}
