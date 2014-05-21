/*
 * main_app_coordt.c
 *
 * Created: 14/05/2014 16:39:29
 *  Author: leomr85
 */

/* === INCLUDES ============================================================ */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <inttypes.h>
#include "pal.h"
#include "tal.h"
#include "sio_handler.h"
#include "mac_api.h"
#include "app_config.h"
#include "ieee_const.h"

#include "terminal.h"
#include "system_config.h"

/* === TYPES =============================================================== */
typedef struct associated_device_tag{
	/* This type definition of a structure can store the short address and the
	 * extended address of a device.
	 */
	uint64_t long_address;
    uint16_t short_address;

	// Fields to experiment
	uint32_t framerec;      // Number of Frames Received from Node
	uint32_t frameproc;     // Number of Frames Processed from Node
	uint8_t	 bufferlength;  // Buffer length of device
	uint8_t  lqi;           // Link Quality Indication (0-FF)
	double   vbat;          // Battery Voltage of Node V
	double   temperature;   // Temperature of Die °C
}associated_device_t;

/* === MACROS ============================================================== */
typedef enum coord_state_tag{
	// This enum store the current state of the coordinator.
    COORD_STARTING = 0,
    COORD_RUNNING
}coord_state_t;

/*
 * Defines the time in ms to initiate a broadcast data transmission
 * to all devices.
 */
#define APP_TIMER_DURATION_MS   (1000)
#define APP_BC_DATA_DURATION_MS (11000)

#if (NO_OF_LEDS >= 3)
	#define LED_START      (LED_0)
	#define LED_NWK_SETUP  (LED_1)
	#define LED_DATA       (LED_2)
#elif (NO_OF_LEDS == 2)
	#define LED_START      (LED_0)
	#define LED_NWK_SETUP  (LED_0)
	#define LED_DATA       (LED_1)
#else
	#define LED_START      (LED_0)
	#define LED_NWK_SETUP  (LED_0)
	#define LED_DATA       (LED_0)
#endif

#define BEACON_PAYLOAD_LEN ((sizeof(double) * 4) + sizeof(uint32_t) + (sizeof(uint8_t) * 3))

/* === GLOBALS ============================================================= */
/* This array stores all device related information. */
static associated_device_t device_list[MAX_NUMBER_OF_DEVICES];

/* Stores the number of associated devices. */
static uint8_t no_of_assoc_devices;
//static uint8_t msdu_handle = 0;

/* This array stores the current beacon payload. */
static uint8_t beacon_payload[BEACON_PAYLOAD_LEN];

/* This variable stores the current state of the node. */
static coord_state_t coord_state = COORD_STARTING;

/** Fusion parameters */
static uint32_t cicle_fusion   = 0;
static uint8_t frames_received = 0;

/* === PROTOTYPES ========================================================== */
static bool assign_new_short_addr(uint64_t addr64, uint16_t *addr16);
static void bcn_payload_update_cb(void *parameter);

// Experiment
static associated_device_t *find_device(wpan_addr_spec_t* SrcAddrSpec);
static void serialize_beacon_payload(void);

/* === IMPLEMENTATION ====================================================== */
/*
 * @brief Main function of the coordinator application
 *
 * This function initializes the MAC, initiates a MLME reset request
 * (@ref wpan_mlme_reset_req()), and implements a the main loop.
 */

int main(void){
	
    /* Initialize the MAC layer and its underlying layers, like PAL, TAL, BMM. */
    if (wpan_init() != MAC_SUCCESS){
        /*
         * Stay here; we need a valid IEEE address.
         * Check kit documentation how to create an IEEE address
         * and to store it into the EEPROM.
         */
        pal_alert();
    }
	
    /* Initialize LEDs. */
    pal_led_init();
    pal_led(LED_START, LED_ON);      // indicating application is started
    pal_led(LED_NWK_SETUP, LED_OFF); // indicating network is started
    pal_led(LED_DATA, LED_OFF);      // indicating data transmission
	
	pal_button_init();

    /*
     * The stack is initialized above, hence the global interrupts are enabled
	 * here.
     */
    pal_global_irq_enable();

	#ifdef SIO_HUB
		/* Initialize the serial interface used for communication with terminal program. */
		if (pal_sio_init(SIO_CHANNEL) != MAC_SUCCESS){
			/* Something went wrong during initialization. */
			pal_alert();
		}

		#if ((!defined __ICCAVR__) && (!defined __ICCARM__))
			fdevopen(_sio_putchar, _sio_getchar);
		#endif
	#endif

	system_config_init();
	if(!system_config_load()){
		pal_alert();
	}

	if(pal_button_read(BUTTON_0) == BUTTON_PRESSED){
		terminal_task();
	}

	#ifdef SIO_HUB
		printf("\n##################################################\n");
		printf("############# Experiment: Coordinator ############\n");
		printf("##################################################\n\n");
	#endif

    /*
     * Reset the MAC layer to the default values.
     * This request will cause a mlme reset confirm message ->
     * usr_mlme_reset_conf
     */
    wpan_mlme_reset_req(true);

    /* Main loop */
    while(1)    {
        wpan_task();
    }
}




/*
 * @brief Callback function usr_mlme_reset_conf
 *
 * @param status Result of the reset procedure
 */
void usr_mlme_reset_conf(uint8_t status){
    if (status == MAC_SUCCESS){
		// Initialize the device struct
		uint8_t index;

		for(index = 0; index < MAX_NUMBER_OF_DEVICES; index++){
			device_list[index].long_address  = 0x0000000000000000;
			device_list[index].short_address = 0x0000;
			device_list[index].framerec      = 0;
			device_list[index].frameproc     = 0;
			device_list[index].bufferlength  = 0;
			device_list[index].lqi           = 0;
			device_list[index].vbat          = 0.0;
			device_list[index].temperature   = 0.0;
		}

        /*
         * Set the short address of this node.
         * Use: bool wpan_mlme_set_req(uint8_t PIBAttribute,
         *                             void *PIBAttributeValue);
         *
         * This request leads to a set confirm message -> usr_mlme_set_conf
         */
        uint8_t short_addr[2];

		short_addr[0] = (uint8_t) system_config_get()->macshort;       // low byte
        short_addr[1] = (uint8_t)(system_config_get()->macshort >> 8); // high byte
        wpan_mlme_set_req(macShortAddress, short_addr);
    }
    else{
        /* Something went wrong; restart. */
        wpan_mlme_reset_req(true);
    }
}



/*
 * @brief Callback function usr_mlme_set_conf
 *
 * @param status        Result of requested PIB attribute set operation
 * @param PIBAttribute  Updated PIB attribute
 */
void usr_mlme_set_conf(uint8_t status, uint8_t PIBAttribute){
    if ((status == MAC_SUCCESS) && (PIBAttribute == macShortAddress)){
        /* Allow other devices to associate to this coordinator. */
         uint8_t association_permit = true;

         wpan_mlme_set_req(macAssociationPermit, &association_permit);
    }
    else if ((status == MAC_SUCCESS) && (PIBAttribute == macAssociationPermit)){
		SystemConfig* config = system_config_get();

		wpan_mlme_set_req(phyTransmitPower, &config->txgain);
	}
    else if ((status == MAC_SUCCESS) && (PIBAttribute == phyTransmitPower)){
        /*
         * Set RX on when idle to enable the receiver as default.
         * Use: bool wpan_mlme_set_req(uint8_t PIBAttribute,
         *                             void *PIBAttributeValue);
         *
         * This request leads to a set confirm message -> usr_mlme_set_conf
         */
         bool rx_on_when_idle = true;

         wpan_mlme_set_req(macRxOnWhenIdle, &rx_on_when_idle);
    }
    else if ((status == MAC_SUCCESS) && (PIBAttribute == macRxOnWhenIdle)){
        /* Set the beacon payload length. */
        uint8_t beacon_payload_len = BEACON_PAYLOAD_LEN;
        wpan_mlme_set_req(macBeaconPayloadLength, &beacon_payload_len);
    }
    else if ((status == MAC_SUCCESS) && (PIBAttribute == macBeaconPayloadLength)){
        /*
         * Once the length of the beacon payload has been defined,
         * set the actual beacon payload.
         */
         serialize_beacon_payload();
    }
    else if ((status == MAC_SUCCESS) && (PIBAttribute == macBeaconPayload)){
        if (COORD_STARTING == coord_state){
	        /*
	         * Initiate an active scan over all channels to determine
	         * which channel to use.
	         * Use: bool wpan_mlme_scan_req(uint8_t ScanType,
	         *                              uint32_t ScanChannels,
	         *                              uint8_t ScanDuration,
	         *                              uint8_t ChannelPage);
	         *
	         * This request leads to a scan confirm message -> usr_mlme_scan_conf
	         * Scan for about 50 ms on each channel -> ScanDuration = 1
	         * Scan for about 1/2 second on each channel -> ScanDuration = 5
	         * Scan for about 1 second on each channel -> ScanDuration = 6
	         */
			SystemConfig* config = system_config_get();
	        wpan_mlme_scan_req(MLME_SCAN_TYPE_ACTIVE,
							   config->scanchannels,
							   SCAN_DURATION_COORDINATOR,
							   config->page);
        }
        else{
            /* Do nothing once the node is properly running. */
        }
    }
    else{
        /* Something went wrong; restart. */
        wpan_mlme_reset_req(true);
    }
}



/**
 * @brief Callback function usr_mlme_scan_conf
 *
 * @param status            Result of requested scan operation
 * @param ScanType          Type of scan performed
 * @param ChannelPage       Channel page on which the scan was performed
 * @param UnscannedChannels Bitmap of unscanned channels
 * @param ResultListSize    Number of elements in ResultList
 * @param ResultList        Pointer to array of scan results
 */
void usr_mlme_scan_conf(uint8_t status,
                        uint8_t ScanType,
                        uint8_t ChannelPage,
                        uint32_t UnscannedChannels,
                        uint8_t ResultListSize,
                        void *ResultList){
	SystemConfig* config = system_config_get();
    /*
     * We are not interested in the actual scan result,
     * because we start our network on the pre-defined channel anyway.
     * Start a beacon-enabled network
     * Use: bool wpan_mlme_start_req(uint16_t PANId,
     *                               uint8_t LogicalChannel,
     *                               uint8_t ChannelPage,
     *                               uint8_t BeaconOrder,
     *                               uint8_t SuperframeOrder,
     *                               bool PANCoordinator,
     *                               bool BatteryLifeExtension,
     *                               bool CoordRealignment)
     *
     * This request leads to a start confirm message -> usr_mlme_start_conf
     */
     wpan_mlme_start_req(config->panid,
                         config->channel,
						 config->page,
                         config->beaconorder,
                         config->superframeorder,
						 config->coordinator > 0 ? true : false,
						 false, false);

    /* Keep compiler happy. */
    status = status;
    ScanType = ScanType;
    ChannelPage = ChannelPage;
    UnscannedChannels = UnscannedChannels;
    ResultListSize = ResultListSize;
    ResultList = ResultList;
}



/*
 * @brief Callback function usr_mlme_start_conf
 *
 * @param status        Result of requested start operation
 */
void usr_mlme_start_conf(uint8_t status){
    if (status == MAC_SUCCESS){
        coord_state = COORD_RUNNING;

        printf(">>> Beacon-Enabled Network initialized!\n\n");

        /*
         * Network is established.
         * Waiting for association indication from a device.
         * -> usr_mlme_associate_ind
         */
        pal_led(LED_NWK_SETUP, LED_ON);

        /*
         * Now that the network has been started successfully,
         * the timer for updating the beacon payload is started.
         */
		//uint32_t beacon_timer = terminal_experiment_variable_get(EV_TIME) * 1000;
		uint32_t beacon_timer = ((uint32_t) APP_TIMER_DURATION_MS) * 1000;
        pal_timer_start(APP_TIMER_BCN_PAYLOAD_UPDATE,
                        beacon_timer,
                        TIMEOUT_RELATIVE,
                        (FUNC_PTR)bcn_payload_update_cb,
                        NULL);
    }
    else{
        /* Something went wrong; restart. */
        wpan_mlme_reset_req(true);
    }
}



/*
 * @brief Callback function usr_mlme_associate_ind
 *
 * @param DeviceAddress         Extended address of device requesting association
 * @param CapabilityInformation Capabilities of device requesting association
 */
void usr_mlme_associate_ind(uint64_t DeviceAddress,
                            uint8_t CapabilityInformation){
    /*
     * Any device is allowed to join the network.
     * Use: bool wpan_mlme_associate_resp(uint64_t DeviceAddress,
     *                                    uint16_t AssocShortAddress,
     *                                    uint8_t status);
     *
     * This response leads to comm status indication -> usr_mlme_comm_status_ind
     * Get the next available short address for this device.
     */
    uint16_t associate_short_addr = macShortAddress_def;

    if(assign_new_short_addr(DeviceAddress, &associate_short_addr) == true){
        wpan_mlme_associate_resp(DeviceAddress, associate_short_addr, ASSOCIATION_SUCCESSFUL);
    }
    else{
        wpan_mlme_associate_resp(DeviceAddress, associate_short_addr, PAN_AT_CAPACITY);
    }

    /* Keep compiler happy. */
    CapabilityInformation = CapabilityInformation;
}



/*
 * @brief Callback function usr_mlme_comm_status_ind
 *
 * @param SrcAddrSpec      Pointer to source address specification
 * @param DstAddrSpec      Pointer to destination address specification
 * @param status           Result for related response operation
 */
void usr_mlme_comm_status_ind(wpan_addr_spec_t *SrcAddrSpec,
                              wpan_addr_spec_t *DstAddrSpec,
                              uint8_t status){
    if(status == MAC_SUCCESS){
        /*
         * Now the association of the device has been successful and its
         * information, like address, could  be stored.
         * But for the sake of simple handling it has been done
         * during assignment of the short address within the function
         * assign_new_short_addr()
         */
    }

    /* Keep compiler happy. */
    SrcAddrSpec = SrcAddrSpec;
    DstAddrSpec = DstAddrSpec;
}



/*
 * Callback function usr_mcps_data_conf
 *
 * @param msduHandle  Handle of MSDU handed over to MAC earlier
 * @param status      Result for requested data transmission request
 * @param Timestamp   The time, in symbols, at which the data were transmitted
 *                    (only if timestamping is enabled).
 *
 */
#ifdef ENABLE_TSTAMP
	void usr_mcps_data_conf(uint8_t msduHandle, uint8_t status, uint32_t Timestamp)
#else
	void usr_mcps_data_conf(uint8_t msduHandle, uint8_t status)
#endif  /* ENABLE_TSTAMP*/
{
    pal_led(LED_DATA, LED_OFF);

    /* Keep compiler happy. */
    status = status;
    msduHandle = msduHandle;
	
	#ifdef ENABLE_TSTAMP
		Timestamp = Timestamp;
	#endif  /* ENABLE_TSTAMP*/
}



/**
 * @brief Callback function for updating the beacon payload
 *
 * @param parameter Pointer to callback parameter
 *                  (not used in this application, but could be used
 *                  to indicated LED to be switched off)
 */
static void bcn_payload_update_cb(void *parameter){
	// The Fusion Algoritm
	uint8_t		index;
	double		actual_temp		= 0.0;

	frames_received				= 0;

	printf("T:%04" PRIu32, cicle_fusion);
	
	if(no_of_assoc_devices > 0){
		//for(index = 0; index < MAX_NUMBER_OF_DEVICES; index++){
		for(index = 0; index < no_of_assoc_devices; index++){

			if(device_list[index].framerec > device_list[index].frameproc){
				++frames_received;
				++device_list[index].frameproc;

				actual_temp	+= device_list[index].temperature;

				printf(" | ID: %02d > %d, %d, %.2f, %.2f", index, device_list[index].short_address, device_list[index].lqi,
				device_list[index].vbat, device_list[index].temperature);
			}
			else{
				printf(" | ID: %02d > Waiting data", index);
			}
		}
	}
	else{
		if(no_of_assoc_devices == 0)
			printf(" Waiting connection");
	}

	if(frames_received > 0)
		actual_temp	/= (double) frames_received;
	else
		actual_temp	= 0.0;

	printf("\n");
	
	// Signal next turn
	++cicle_fusion;

	// Update Beacon Payload
	serialize_beacon_payload();

    /* Restart timer for updating beacon payload. */
	//uint32_t beacon_timer = terminal_experiment_variable_get(EV_TIME) * 1000;
	uint32_t beacon_timer = ((uint32_t) APP_TIMER_DURATION_MS) * 1000;
    pal_timer_start(APP_TIMER_BCN_PAYLOAD_UPDATE,
					beacon_timer,
                    TIMEOUT_RELATIVE,
                    (FUNC_PTR)bcn_payload_update_cb,
                    NULL);

    parameter = parameter;  /* Keep compiler happy. */
}



/*
 * @brief Application specific function to assign a short address
 */
static bool assign_new_short_addr(uint64_t addr64, uint16_t *addr16){
    uint8_t i;
    char sio_array[255];

    /* Check if device has been associated before. */
    for(i = 0; i < MAX_NUMBER_OF_DEVICES; i++){
        if (device_list[i].short_address == 0x0000){
            /* If the short address is 0x0000, it has not been used before. */
            continue;
        }
        if (device_list[i].long_address == addr64){
            /* Assign the previously assigned short address again. */
            *addr16 = device_list[i].short_address;

			sprintf(sio_array, "\n############ Device %" PRIu8 " re-associated #############\n\n", i + 1);
            printf(sio_array);

			return true;
        }
    }

    for(i = 0; i < MAX_NUMBER_OF_DEVICES; i++){
        if(device_list[i].short_address == 0x0000){
            *addr16 = i + 0x0001;
            device_list[i].short_address = i + 0x0001; /* Get next short address. */
            device_list[i].long_address = addr64;      /* Store extended address. */
            no_of_assoc_devices++;

            sprintf(sio_array, "\n############## Device %" PRIu8 " associated ##############\n\n", i + 1);
            printf(sio_array);

            return true;
        }
    }

    /* If we are here, no short address could be assigned. */
    return false;
}



/*
 * @brief Callback function usr_mcps_data_ind
 *
 * @param SrcAddrSpec      Pointer to source address specification
 * @param DstAddrSpec      Pointer to destination address specification
 * @param msduLength       Number of octets contained in MSDU
 * @param msdu             Pointer to MSDU
 * @param mpduLinkQuality  LQI measured during reception of the MPDU
 * @param DSN              DSN of the received data frame.
 * @param Timestamp        The time, in symbols, at which the data were received
 *                         (only if timestamping is enabled).
 */
void usr_mcps_data_ind(wpan_addr_spec_t *SrcAddrSpec,
                       wpan_addr_spec_t *DstAddrSpec,
                       uint8_t msduLength,
                       uint8_t *msdu,
                       uint8_t mpduLinkQuality,
					   
	#ifdef ENABLE_TSTAMP
		uint8_t DSN,
		uint32_t Timestamp)
	#else
		uint8_t DSN)
	#endif  /* ENABLE_TSTAMP */
	
{
	associated_device_t*     adt  = find_device(SrcAddrSpec);
	uint8_t	                 size = 0;

	if(adt == NULL)
		return;

	adt->framerec++;
	adt->lqi = mpduLinkQuality;
	
	memcpy(&adt->vbat, msdu, sizeof(adt->vbat));
	size  = sizeof(adt->vbat);
	
	memcpy(&adt->temperature, msdu + size, sizeof(adt->temperature));
	size += sizeof(adt->temperature);
	
	memcpy(&adt->bufferlength, msdu + size, sizeof(adt->bufferlength));
	size += sizeof(adt->bufferlength);

    /* Keep compiler happy. */
    DstAddrSpec = DstAddrSpec;
	msduLength = msduLength;

	#ifdef ENABLE_TSTAMP
		DSN = DSN;
		Timestamp = Timestamp;
	#endif  /* ENABLE_TSTAMP */
}



// Experiment
static associated_device_t* find_device(wpan_addr_spec_t* SrcAddrSpec){
	uint8_t		index;

	if(SrcAddrSpec->AddrMode == WPAN_ADDRMODE_SHORT){
		uint16_t addr = SrcAddrSpec->Addr.short_address;

		for(index = 0; index < MAX_NUMBER_OF_DEVICES; index++){
			if(addr == device_list[index].short_address)
				return(&device_list[index]);
		}
	}
	else{
		uint64_t addr = SrcAddrSpec->Addr.long_address;
		
		for(index = 0; index < MAX_NUMBER_OF_DEVICES; index++){
			if(addr == device_list[index].long_address)
				return(&device_list[index]);
		}
	}
	return(NULL);
}



static void serialize_beacon_payload(void){
	memcpy(beacon_payload, &cicle_fusion, sizeof(cicle_fusion));
	uint8_t	size = sizeof(cicle_fusion);
	
	memcpy(beacon_payload + size, &no_of_assoc_devices, sizeof(no_of_assoc_devices));
	size += sizeof(no_of_assoc_devices);
	
	memcpy(beacon_payload + size, &frames_received, sizeof(frames_received));
	size += sizeof(frames_received);

	wpan_mlme_set_req(macBeaconPayload, &beacon_payload);
}

/* EOF */