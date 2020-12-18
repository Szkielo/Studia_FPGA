/*************************************************************************
* Copyright (c) 2004 Altera Corporation, San Jose, California, USA.      *
* All rights reserved. All use of this software and documentation is     *
* subject to the License Agreement located at the end of this file below.*
**************************************************************************
* Description:                                                           *
* The following is a simple hello world program running MicroC/OS-II.The * 
* purpose of the design is to be a very simple application that just     *
* demonstrates MicroC/OS-II running on NIOS II.The design doesn't account*
* for issues such as checking system call return codes. etc.             *
*                                                                        *
* Requirements:                                                          *
*   -Supported Example Hardware Platforms                                *
*     Standard                                                           *
*     Full Featured                                                      *
*     Low Cost                                                           *
*   -Supported Development Boards                                        *
*     Nios II Development Board, Stratix II Edition                      *
*     Nios Development Board, Stratix Professional Edition               *
*     Nios Development Board, Stratix Edition                            *
*     Nios Development Board, Cyclone Edition                            *
*   -System Library Settings                                             *
*     RTOS Type - MicroC/OS-II                                           *
*     Periodic System Timer                                              *
*   -Know Issues                                                         *
*     If this design is run on the ISS, terminal output will take several*
*     minutes per iteration.                                             *
**************************************************************************/


#include <stdio.h>
#include "includes.h"
#include "definition.h"
#include <system.h>
#include <io.h>
#include <math.h>

#include "sys/alt_timestamp.h"
#include "alt_types.h"
#include "sys/alt_alarm.h"

#include "altera_up_avalon_ps2.h"
#include "altera_up_ps2_keyboard.h"

struct ProgramData{
	volatile int godz = 0, min = 0, dzien = 1, miesiac = 1, rok = 2000;
	volatile int opcja_data_godzina = 0;
	volatile int kwota_parkowania = 0; // 1 = 10 groszy
	volatile int bezplatne_start = 0, bezplatne_koniec = 0;
	volatile int opcja_bezplatne = 0;
	volatile int wysokosc_znizek = 0; //0-100%
	volatile int err_papier = 0;
	volatile int err_monety = 0;
	volatile int err_inne = 0;

	volatile int sw = 0;
	volatile int pb = 0;
};

struct Time{
	volatile int six = 0;
	volatile int ten = 0;
};

/* Definition of Task Stacks */
#define   TASK_STACKSIZE       2048
OS_STK    task1_stk[TASK_STACKSIZE];
OS_STK    task2_stk[TASK_STACKSIZE];
OS_STK    task3_stk[TASK_STACKSIZE];
OS_STK    task4_stk[TASK_STACKSIZE];
OS_STK    task5_stk[TASK_STACKSIZE];

/* Definition of Task Priorities */

#define TASK1_PRIORITY      1
#define TASK2_PRIORITY      3
#define TASK3_PRIORITY      4
#define TASK4_PRIORITY      2 //reset, obsluga bledu    

OS_EVENT *SWBox1;
OS_EVENT *SWBoxErr;
OS_EVENT *SWBoxTime;

alt_up_ps2_dev* keyboard;

void printOnHex(int number){ // 0 - 999
	//hex2
	int temp;
	temp = number % 10;
	switch(temp){
	  case'0':
		  IOWR(HEX_BASE, 2, ZERO);
		break;
	  case'1':
		  IOWR(HEX_BASE, 2, ONE);
	  	break;
	  case'2':
		  IOWR(HEX_BASE, 2, TWO);
	  	break;
	  case'3':
		  IOWR(HEX_BASE, 2, THREE);
	  	break;
	  case'4':
		  IOWR(HEX_BASE, 2, FOUR);
	  	break;
	  case'5':
		  IOWR(HEX_BASE, 2, FIVE);
	  	break;
	  case'6':
		  IOWR(HEX_BASE, 2, SIX);
	    break;
	  case'7':
		  IOWR(HEX_BASE, 2, SEVEN);
	  	break;
	  case'8':
		  IOWR(HEX_BASE, 2, EIGHT);
	  	break;
	  case'9':
		  IOWR(HEX_BASE, 2, NINE);
	  	break;
	  default:
		break;
	  }
	// hex 1
	number = number / 10;
	temp = number % 10;
		switch(temp){
		  case'0':
			  IOWR(HEX_BASE, 1, ZERO);
			break;
		  case'1':
			  IOWR(HEX_BASE, 1, ONE);
		  	break;
		  case'2':
			  IOWR(HEX_BASE, 1, TWO);
		  	break;
		  case'3':
			  IOWR(HEX_BASE, 1, THREE);
		  	break;
		  case'4':
			  IOWR(HEX_BASE, 1, FOUR);
		  	break;
		  case'5':
			  IOWR(HEX_BASE, 1, FIVE);
		  	break;
		  case'6':
			  IOWR(HEX_BASE, 1, SIX);
		    break;
		  case'7':
			  IOWR(HEX_BASE, 1, SEVEN);
		  	break;
		  case'8':
			  IOWR(HEX_BASE, 1, EIGHT);
		  	break;
		  case'9':
			  IOWR(HEX_BASE, 1, NINE);
		  	break;
		  default:
			break;
		  }
		// hex 0
		number = number / 10;
			temp = number % 10;
				switch(temp){
				  case'0':
					  IOWR(HEX_BASE, 0, ZERO);
					break;
				  case'1':
					  IOWR(HEX_BASE, 0, ONE);
				  	break;
				  case'2':
					  IOWR(HEX_BASE, 0, TWO);
				  	break;
				  case'3':
					  IOWR(HEX_BASE, 0, THREE);
				  	break;
				  case'4':
					  IOWR(HEX_BASE, 0, FOUR);
				  	break;
				  case'5':
					  IOWR(HEX_BASE, 0, FIVE);
				  	break;
				  case'6':
					  IOWR(HEX_BASE, 0, SIX);
				    break;
				  case'7':
					  IOWR(HEX_BASE, 0, SEVEN);
				  	break;
				  case'8':
					  IOWR(HEX_BASE, 0, EIGHT);
				  	break;
				  case'9':
					  IOWR(HEX_BASE, 0, NINE);
				  	break;
				  default:
					break;
				  }
}

/* Prints "Hello World" and sleeps for three seconds */
void task1(void* pdata)
{
	INT8u err1;
	INT8u err2;
	INT8u err3;
	int err_flag1 = 0;
	int err_flag2 = 0;
	int mrugaj = 0;
	int prev_sw = 0;
	int prev_pb = 0;
	int temp_time = 0;
	alt_timestamp.start();
	struct ProgramData* data = OSMboxPend(SWBox1, 200, &err1);
	int* dioda = OSMboxPend(SWBoxErr, 200, &err2);
	struct* Time time = OSMboxPend(SWTime, 0, &err3);
	
	while (1){
		if (err2 == OS_NO_ERR){
			if (data->err_papier != 0){
				dioda = 0;
			}
			if (data->err_monety != 0){
				dioda = 1;
			}
			if (data->err_inne != 0){
				dioda = 2;
			}
			err_flag2 = 0;
			OSMboxPostOpt(SWErr, &dioda, OS_POST_OPT_BROADCAST);
		}
		else if (err2 == OS_TIMEOUT){
			if (err_flag2 == 1){
				mrugaj = 1;
			}
			else {
				err_flag2 == 1;
			}
			printf("\nTimeout at task1 (error handle)");
		}
		else if (err2 == OS_ERR_EVENT_TYPE){
			if (err_flag2 == 1){
				mrugaj = 1;
			}
			else {
				err_flag2 == 1;
			}
			printf("\nEvent type at task1 (error handle)");
		}
		
		
		// odczyt
		if (err1 == OS_NO_ERR){
			data->sw = IORD(SW_SLIDERS_BASE, 0);
			data->pb = IORD(PUSHBUTTON_BASE, 0);
			OSMboxPostOpt(SWBox1, &data, OS_POST_OPT_BROADCAST);
			
			KB_CODE_TYPE decode_mode = 1;
			alt_u8 var;
			char key ;
			int Key_err_flag = 0;
			
			if (decode_scancode(&keyboard, &decode_mode, &var, &key) == 0)
			{
				//Gdy poprawnie zostanie wybrany klawisz to blad sie wylaczy i dioda numer 9 tez zgasnie
			
			if (Key_err_flag = 1 && (key == '1'  key  == '2'  key  == '3' || key  == '4')){
				Key_err_flag = 0;
				IOWR(LEDS_BASE, 9, 0)
			}
			
			//Wybor klawisza, jesli juz jest stan to przechodzi on w stan nieaktwyny
			if(decode_mode == KB_ASCII_MAKE_CODE){
				if (key  == '1' && data->sw != 1){
						data->sw = 1;
				}
				else if (key  == '1' && data->sw == 1){
					data->sw = 0;
				}
				else if (key  == '2' && data->sw != 2){
					data->sw = 2;
				}
				else if (key  == '2' && data->sw == 2){
					data->sw = 0;
				}
				else if (key  == '3' && data->sw != 3){
					data->sw = 3;
					}
				else if (key  == '3' && data->sw == 3){
					data->sw = 0;
				}
				else if (key == '4' && data->sw != 4){
					data->sw = 4;
					}
				else if (key == '4' && data->sw == 4){
					data->sw = 0;
				}
				else {
					//Gdy zostanie wybrany klawisz spoza zakresu zapali sie dioda 9 informujaca o bledzie
					Key_err_flag = 1;
					IOWR(LEDS_BASE, 9, 0xff)
				}
			}

			// pierwsza funkcja
			if (data->sw == 1){
				if (data->pb == 1)
					data->kwota_parkowania--;
				if (data->pb == 2)
					data->kwota_parkowania++;
				printOnHex(data->kwota_parkowania);
			}
			err_flag1 = 0;
		}
		else if (err1 == OS_TIMEOUT){
			if (err_flag1 == 1){
				mrugaj = 1;
			}
			else {
				err_flag1 == 1;
			}
			printf("\nTimeout at task1 (read)");
		}
		else if (err1 == OS_ERR_EVENT_TYPE){
			if (err_flag1 == 1){
				mrugaj = 1;
			}
			else {
				err_flag1 == 1;
			}
			printf("\nEvent type at task1 (read)");
		}
		
		// timer
		if (data->sw != prev_sw){
			prev_sw = data->sw;
			alt_timestamp_stop();
			alt_timestamp_start();
		}
		if (data->pb != prev_pb){
			prev_pb = data->pb;
			temp_time = alt_timestamp() / alt_timestamp_freq();
		}
		if (alt_timestamp() / alt_timestamp_freq() > 6){
			time->six = 1;
		}
		else {
			time->six = 0;
		}
		
		if ((alt_timestamp() / alt_timestamp_freq()) - temp_time > 10){
			time->ten = 1;
		}
		else {
			time->ten = 0;
		}
		OSMboxPostOpt(SWTime, &time, OS_POST_OPT_BROADCAST);
		
		//mruganie
		if (mrugaj == 1){
			IOWR(LEDS_BASE, 9, 0xff);
			OSTimeDlyHMSM(0, 0, 0, 250);
			IOWR(LEDS_BASE, 9, 0);
			OSTimeDlyHMSM(0, 0, 0, 250);
			mrugaj = 0;
		}
		
		OSTimeDlyHMSM(0, 0, 0, 50);
  }
}
/* Prints "Hello World" and sleeps for three seconds */
void task2(void* pdata)
{
  INT8u err;
  int err_flag = 0;
  int mrugaj = 0;
  struct ProgramData* data = OSMboxPend(SWBox1, 200, &err);
  while (1)
  { 
	if (err == OS_NO_ERR){
		if (data->sw == 0){
			if (data->opcja_data_godzina == 0){
				if (data->pb == 1)
					data->godz--;
				if (data->pb == 2)
					data->godz++;
				if (data->pb == 4)
					data->opcja_data_godzina++;
				printOnHex(data->godz);
			}else if(data->opcja_data_godzina == 1){
				if (data->pb == 1)
					data->min--;
				if (data->pb == 2)
					data->min++;
				if (data->pb == 3)
					data->opcja_data_godzina--;
				if (data->pb == 4)
					data->opcja_data_godzina++;
				printOnHex(data->min);
			}else if(data->opcja_data_godzina == 2){
				if (data->pb == 1)
					data->dzien--;
				if (data->pb == 2)
					data->dzien++;
				if (data->pb == 3)
					data->opcja_data_godzina--;
				if (data->pb == 4)
					data->opcja_data_godzina++;
				printOnHex(data->dzien);
			}else if(data->opcja_data_godzina == 3){
				if (data->pb == 1)
					data->miesiac--;
				if (data->pb == 2)
					data->miesiac++;
				if (data->pb == 3)
					data->opcja_data_godzina--;
				if (data->pb == 4)
					data->opcja_data_godzina++;
				printOnHex(data->miesiac);
			}else if(data->opcja_data_godzina == 4){
				if (data->pb == 1)
					data->rok--;
				if (data->pb == 2)
					data->rok++;
				if (data->pb == 3)
					data->opcja_data_godzina--;
				printOnHex(data->rok);
			}
		}
		err_flag = 0;
	}
	else if (err == OS_TIMEOUT){
		if (err_flag == 1){
			mrugaj = 1;
		}
		else {
			err_flag == 1;
		}
		printf("\nTimeout at task2");
	}
	else if (err == OS_ERR_EVENT_TYPE){
		if (err_flag == 1){
			mrugaj = 1;
		}
		else {
			err_flag == 1;
		}
		printf("\nEvent type at task2");
	}
	//mruganie
	if (mrugaj == 1){
			IOWR(LEDS_BASE, 9, 0xff);
			OSTimeDlyHMSM(0, 0, 0, 250);
			IOWR(LEDS_BASE, 9, 0);
			OSTimeDlyHMSM(0, 0, 0, 250);
			mrugaj = 0;
	}
    OSTimeDlyHMSM(0, 0, 0, 50);
  }
}

void encode(ProgramData* data, int* code){ //utworzenie liczby dziesiętnej, która zostanie rozkodowana w module
	code = 0;
	int temp = 0;
	code +=  data->wysokosc_znizek;
	code += (data->bezplatne_koniec) * pow(2, 6);
	code += (data->bezplatne_start) * pow(2, 11);
	code += (data->pb) * pow(2, 16);
	code += (data->sw) * pow(2, 19);
	code += (data->err_inne) * pow(2, 21);
}

void decode(ProgramData* data, int* code){ 
	int temp = code;
	data->wysokosc_znizek = temp % pow (2, 6);
	temp = temp / pow (2, 6);
	data->bezplatne_koniec = temp % pow(2, 5);
	temp = temp / pow (2, 5);
	data->bezplatne_start = temp % pow(2, 5);
	temp = temp / pow (2, 5);
	data->pb = temp % pow(2, 3);
	temp = temp / pow (2, 3);
	data->sw = temp % pow(2, 2);
	temp = temp / pow (2, 2);
	data->err_inne = temp;
}

// teaching sand to think was a mistake

void task3(void* pdata)
{
	INT8u err;
	int err_flag = 0;
	int mrugaj = 0;
	struct ProgramData* data = OSMboxPend(SWBox1, 200, &err);
	int code[32];
	while (1){
		if (err == OS_NO_ERR){
			encode(&data, &code);
			IOWR (MODUL_0_BASE, 0, &code);
			IORD (MODUL_0_BASE, &code);
			decode(&data, &code);
			err_flag = 0;
		}
		else if (err == OS_TIMEOUT){
			if (err_flag == 1){
				mrugaj = 1;
			}
			else {
				err_flag == 1;
			}
			printf("\nTimeout at task3");
		}
		else if (err == OS_ERR_EVENT_TYPE){
			if (err_flag == 1){
				mrugaj = 1;
			}
			else {
				err_flag == 1;
			}
			printf("\nEvent type at task3");
		}
		//mruganie
		if (mrugaj == 1){
			IOWR(LEDS_BASE, 9, 0xff);
			OSTimeDlyHMSM(0, 0, 0, 250);
			IOWR(LEDS_BASE, 9, 0);
			OSTimeDlyHMSM(0, 0, 0, 250);
			mrugaj = 0;
		}
		OSTimeDlyHMSM(0, 0, 0, 50);
  }
}


void task4(void* pdata)
{
	INT8u err1;
	INT8u err2;
	INT8u err3;
	int err_flag1 = 0;
	int err_flag2 = 0;
	int mrugaj = 0;
	struct ProgramData* data = OSMboxPend(SWBox1, 200, &err1);
	int* dioda = OSMboxPend(SWBoxErr, 200, &err2);
	struct* Time time = OSMboxPend(SWTime, 0, &err3);
	while (1){
		if (err1 == OS_NO_ERR){
			if (data->sw == 9){
				data->godz = 0;
				data->min = 0;
				data->dzien = 1;
				data->miesiac = 1;
				data->rok = 2020;
				data->opcja_data_godzina = 0;
				data->kwota_parkowania = 0;
				data->bezplatne_start = 0;
				data->bezplatne_koniec = 0;
				data->opcja_bezplatne = 0;
				data->wysokosc_znizek = 0;
				printOnHex(0);
			}
			err_flag1 = 0;
		}
		else if(err1 == OS_TIMEOUT){
			if (err_flag1 == 1){
				mrugaj = 1;
			}
			else {
				err_flag1 == 1;
			}
			printf("\nTimeout at task5 (reset)");
		}
		else if (err1 == OS_ERR_EVENT_TYPE){
			if (err_flag1 == 1){
				mrugaj = 1;
			}
			else {
				err_flag1 == 1;
			}
			printf("\nEvent type at task5 (reset)");
		}
		
	// obsluga bledu
		if (err2 == OS_NO_ERR){
			if (data->dioda == 0){
				wyslijDoCentraliBrakPapieru();
			}
			if (data->dioda == 1){
				wyslijDoCentraliMonetyPelne();
			}
			if (data->dioda == 2){
				wyslijDoCentraliInne();
			}
			IOWR(LEDS_BASE, *dioda, 0xff);
			err_flag2 = 0;
		}
		else if(err2 == OS_TIMEOUT){
			if (err_flag2 == 1){
				mrugaj = 1;
			}
			else {
				err_flag2 == 1;
			}
			printf("\nTimeout at task5 (error handle)");
		}
		else if (err2 == OS_ERR_EVENT_TYPE){
			if (err_flag2 == 1){
				mrugaj = 1;
			}
			else {
				err_flag2 == 1;
			}
			printf("\nEvent type at task5 (error handle)");
		}
		
		//timer
		if (time->six == 1){
			printf("\nFunkcja wykonuje sie ponad 6 sekund!");
		}
		
		if (time->ten == 1){
			IOWR(LEDS_BASE, 6, 0xff);
			IOWR(LEDS_BASE, 7, 0xff);
			IOWR(LEDS_BASE, 8, 0xff);
			IOWR(LEDS_BASE, 9, 0xff);
			OSTimeDlyHMSM(0, 0, 0, 500);
			IOWR(LEDS_BASE, 6, 0);
			IOWR(LEDS_BASE, 7, 0);
			IOWR(LEDS_BASE, 8, 0);
			IOWR(LEDS_BASE, 9, 0);
			OSTimeDlyHMSM(0, 0, 0, 500);
		}
		
		//mruganie
		if (time->ten == 0 && mrugaj == 1){ // kosmetycznie, zeby poprawnie mrugaly
			IOWR(LEDS_BASE, 9, 0xff);
			OSTimeDlyHMSM(0, 0, 0, 250);
			IOWR(LEDS_BASE, 9, 0);
			OSTimeDlyHMSM(0, 0, 0, 250);
			mrugaj = 0;
		}
		OSTimeDlyHMSM(0, 0, 0, 50);
  }
}


/* The main function creates two task and starts multi-tasking */
int main(void)
{
  SWBox1 = OSMboxCreate((void*)0);
  SWBoxErr = OSMboxCreate((void*)0);
  SWBoxTime = OSMboxCreate((void*)0);
  
  struct ProgramData data;
  OSMboxPostOpt(SWBox1, &data, OS_POST_OPT_BROADCAST);
  
  int* dioda;
  OSMboxPostOpt(SWErr, &dioda, OS_POST_OPT_BROADCAST);
  
  struct Time time;
  OSMboxPostOpt(SWTime, &time, OS_POST_OPT_BROADCAST);

  OSTaskCreateExt(task1,
                  NULL,
                  (void *)&task1_stk[TASK_STACKSIZE-1],
                  TASK1_PRIORITY,
                  TASK1_PRIORITY,
                  task1_stk,
                  TASK_STACKSIZE,
                  NULL,
                  0);
              
               
  OSTaskCreateExt(task2,
                  NULL,
                  (void *)&task2_stk[TASK_STACKSIZE-1],
                  TASK2_PRIORITY,
                  TASK2_PRIORITY,
                  task2_stk,
                  TASK_STACKSIZE,
                  NULL,
                  0);

  OSTaskCreateExt(task3,
                  NULL,
                  (void *)&task3_stk[TASK_STACKSIZE-1],
                  TASK3_PRIORITY,
                  TASK3_PRIORITY,
                  task3_stk,
                  TASK_STACKSIZE,
                  NULL,
                  0);

  OSTaskCreateExt(task4,
                  NULL,
                  (void *)&task4_stk[TASK_STACKSIZE-1],
                  TASK4_PRIORITY,
                  TASK4_PRIORITY,
                  task4_stk,
                  TASK_STACKSIZE,
                  NULL,
                  0);


  OSStart();
  return 0;
}

/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2004 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/
