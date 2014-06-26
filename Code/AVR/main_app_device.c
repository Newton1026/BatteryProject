/*
 * main_app.c
 *
 * Created: 13/05/2014 15:29:25
 *  Author: leomr85
 */ 

/* === INCLUDES ============================================================ */

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <inttypes.h>

#include "pal.h"
#include "tfa.h"
#include "network.h"

/* === TYPES =============================================================== */

/* === MACROS ============================================================== */

/* === GLOBALS ============================================================= */
static uint8_t		nwk_beacon_data[128];
static uint8_t		nwk_data[128];
static double		battery;
static double		temp;
static uint32_t		coord_state;

static uint16_t		aux;
static uint32_t		time_a;
static uint32_t		time_b;
static uint32_t		us2ms = 1000;

/* === PROTOTYPES ========================================================== */
static void deserialize_beacon_payload(void);



/* === IMPLEMENTATION ====================================================== */

/**
 * @brief Main function of the device application
 */
int main(void){
	
	nwk_init();

	printf("\nExperiment: Device\n\n");

	coord_state	= 0;

	while(1){
		
		if(nwk_state_get() == NWK_STATE_ACTIVE){
			printf("\n########## App Turn ##########\n");

			if(nwk_beacon_read(nwk_beacon_data, 128)){
				if(nwk_beacon_data[0] != coord_state){
					deserialize_beacon_payload();

					printf("... Capturing data... ");
						
					// Capturing the battery voltage.
					aux	= tfa_get_batmon_voltage();
					battery = ((double) aux) / 1000.0 ;

					// Capturing the board temperature.
					temp = pal_read_temperature();

					// Printing information on serial.
					printf("Ok!\n... BatV = %.2f V\n... Temp = %.2f *C", battery, temp);

					// Copying the memory local content to send over network.
					// Usage: void * memcpy (void *destination, const void *source, size_t num);
					memcpy(nwk_data, &battery, sizeof(battery));
					uint8_t	size = sizeof(battery);
					memcpy(nwk_data + size, &temp, sizeof(temp));
					size += sizeof(temp);

					printf("\n... Sending data... ");
					printf("\n... Capturing data... ");
					if(nwk_send(nwk_data, size)){
						printf("Ok!\n");
					}
					else{
						printf("Error to send data!\n");
					}
				}
			}
			else{
				printf("	Error! I can't read beacon payload.\n");
			}
			
			if(time_a)
				printf("### Work Done! zzZ: %" PRIu32 " ms ###\n", pal_sub_time_us(time_b, time_a)/us2ms);
			else
				printf("##### Work Done! zzZ zzZ #####\n");
		}

		/**
		  * Force uC to sleep when not processing MAC/Timer functions
		  * and/or execute nwk_task()
		  **/
		pal_get_current_time(&time_a);
		nwk_beacon_wait();
		pal_get_current_time(&time_b);
	}
}

/**
 * \brief 
 * 
 * \param 
 * 
 * \return void
 */
static void deserialize_beacon_payload(void){
	memcpy(&coord_state, nwk_beacon_data, sizeof(coord_state));
}

/* EOF */