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

#include "xsi.h"

struct XSI_INFO xsi_info;

char *IEEE_P_2592010699;
char *STD_STANDARD;
char *IEEE_P_1242562249;
char *WORK_P_2670401595;
char *WORK_P_1315263890;
char *WORK_P_2378204126;
char *STD_TEXTIO;
char *IEEE_P_3564397177;
char *WORK_P_0920013403;


int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    ieee_p_2592010699_init();
    ieee_p_1242562249_init();
    std_textio_init();
    ieee_p_3564397177_init();
    work_p_2670401595_init();
    work_p_1315263890_init();
    work_p_2378204126_init();
    work_p_0920013403_init();
    work_a_2735068677_0632001823_init();
    work_a_0637058416_0632001823_init();
    work_a_3112044328_0632001823_init();
    work_a_3360116787_0632001823_init();
    work_a_4088829756_0632001823_init();
    work_a_4132915518_0632001823_init();
    work_a_1004095208_1949178628_init();


    xsi_register_tops("work_a_1004095208_1949178628");

    IEEE_P_2592010699 = xsi_get_engine_memory("ieee_p_2592010699");
    xsi_register_ieee_std_logic_1164(IEEE_P_2592010699);
    STD_STANDARD = xsi_get_engine_memory("std_standard");
    IEEE_P_1242562249 = xsi_get_engine_memory("ieee_p_1242562249");
    WORK_P_2670401595 = xsi_get_engine_memory("work_p_2670401595");
    WORK_P_1315263890 = xsi_get_engine_memory("work_p_1315263890");
    WORK_P_2378204126 = xsi_get_engine_memory("work_p_2378204126");
    STD_TEXTIO = xsi_get_engine_memory("std_textio");
    IEEE_P_3564397177 = xsi_get_engine_memory("ieee_p_3564397177");
    WORK_P_0920013403 = xsi_get_engine_memory("work_p_0920013403");

    return xsi_run_simulation(argc, argv);

}
