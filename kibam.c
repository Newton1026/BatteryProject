/*
    This source code implements the functions for Kinetic Battery Model (KiBaM), as
    described in [Battery Modeling - M. R. Jongerden and B. R. Haverkort].

    Author: Leonardo Martins Rodrigues.
    Date of creation: 11-02-2014 - Version: 1.0
*/

#include "kibam.h"
#include <stdio.h>
#include <math.h>

int kibam(float *batCapacity, float *currents, float *timeInit, float maxPeriod, int *timePeriods, int numberOfCharges, float *batteryUpTime){
	
	// Defining the model constants.
    float c = 0.625;
    float k = 0.000010;	// Original Value: 0.000045
    float ts = 1000;

    // Defining the model variables.
    float I, y0, i, i0, j, j0, t, kl;
	
	// Initializing variables values.
	y0 = *batCapacity;
    i0 = (c) * y0;
    j0 = (1-c) * y0;
    kl = k / (c * (1-c));

    // Defining auxiliary variables.
    int loop;
	float period;
    FILE *results; // The simulation results will be printed in a file.
	
	results = fopen("results.txt","a"); // The file is created in the same folder of the source code file.
    if (results == NULL) {
      fprintf(stderr, "Can't open input file 'results.txt'!\n");
      return -1;
    }
	
	t = (*timeInit) / ts;
	period = (maxPeriod) + (*timeInit / ts);
	
	while(t < period){
		// Loop for execute the main calculations.
	    for (loop=0;loop < numberOfCharges;loop++){
			// 'I' receives each charge in 'currents' vector.
	        I = currents[loop];

	        for(t = (*timeInit) / ts; t < ((*timeInit + timePeriods[loop]) / ts); t = t + 0.01){ // t = t + 0.01;
				
				// If 't' passes the period especified by 'maxPeriod'.
				if(t >= period){
					y0 = i + j;
					*batCapacity = y0;
					*timeInit = t * 1000;
					*batteryUpTime = *batteryUpTime + t;
					fclose(results);
					return -1;
				}
				
				i = (i0 * exp(- kl * t)) + ((((y0 * kl * c) - I)*(1 - exp(- kl * t))) / kl) - (I * c * ((kl * t) - 1 + exp(- kl * t)) / kl);
				j = (j0 * exp(- kl * t)) + (y0 * (1 - c) * (1 - exp(- kl * t)))	- ((I * (1 - c) * ((kl * t) - 1 + exp(- kl * t))) / kl);
				fprintf(results, "%f %f\n", i, j);	// Writing the result of 'i' and 'j' in the file.
				
				// If the battery charge is low.
				if(i < (0.03 * i0)){
					y0 = i + j;
					*batCapacity = -1.0;
					*timeInit = t * 1000;
					*batteryUpTime = *batteryUpTime + t;
					fclose(results);
					return -1;
				}
			}
	        *timeInit = *timeInit + timePeriods[loop];	// Changed: *timeInit = *timeInit + (t * 1000);
	        y0 = i + j;
			*batCapacity = y0;
	    }
	}

	fclose(results);    // Close the file.
    return 0;
}