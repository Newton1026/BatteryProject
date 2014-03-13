/*
    This source code implements the functions for Kinetic Battery Model (KiBaM), as
    described in [Battery Modeling - M. R. Jongerden and B. R. Haverkort].

    Author: Leonardo Martins Rodrigues.
    Date of creation: 11-02-2014 - Version: 1.0
*/

#include "kibam.h"
#include <stdio.h>
#include <math.h>

#define BATLEVEL 1400

int kibamTop(node *any, float *timeInit){
	
	// Defining the model constants.
    float c = 0.625;
    float k = 0.000010;	// Original Value: 0.000045
	
    // Defining the model variables.
    float y0, kl, I, i, i0, j, j0, t;
	
	// Initializing variables values.
	y0 = (*any).batCap;
	i0 = (*any).i0;
	j0 = (*any).j0;
    kl = k / (c * (1-c));
	
    // Defining auxiliary variables.
    int x;
	
	// Defining a file to write the results.
    FILE *ans;
	
	// File is created at the same folder of the source code file.
	ans = fopen("results.txt","a");
	    if (ans == NULL) {
	      fprintf(stderr, "Can't open input file 'results.txt'!\n");
	      return -1;
	    }
	
	// Two or more charges.
	int charges=0;
	for(x=0; (*any).taskArray[x] != '\0'; x++)	charges++;
	
	t = (*timeInit);
	do{
		for (x = 0; x < charges; x++){
			I = (*any).taskArray[x];

			while(t < *timeInit + (*any).timeArray[x]){
				i = (i0 * exp(- kl * t)) + ((((y0 * kl * c) - I)*(1 - exp(- kl * t))) / kl) - (I * c * ((kl * t) - 1 + exp(- kl * t)) / kl);
				j = (j0 * exp(- kl * t)) + (y0 * (1 - c) * (1 - exp(- kl * t)))	- ((I * (1 - c) * ((kl * t) - 1 + exp(- kl * t))) / kl);
				t = t + 0.01;
			}
			(*timeInit) = t;
			// fprintf(ans, "%f %f\n", t, i);
			if (i < BATLEVEL){
				(*any).deadBat = 1;
			}
		}
		(*any).batUpTime = t;
	}while((*any).deadBat == 0);
	
	y0 = i + j;
	(*any).batCap = y0;
	(*any).i0 = i;
	(*any).j0 = j;
	(*any).batUpTime = t;
	
	close(ans);
	return 0;	
}

int kibamTopInterleaved(node *any, float *timeInit){
	// Defining the model constants.
    float c = 0.625;
    float k = 0.000010;	// Original Value: 0.000045
	
    // Defining the model variables.
    float y0, kl, I, t;
	
	// Initializing variables values.
    kl = k / (c * (1-c));
	
    // Defining auxiliary variables.
    int x, y, z, diedbatteries;
	float timeInit2;
	
	// Defining a file to write the results.
    FILE *ans;
	
	// File is created at the same folder of the source code file.
	ans = fopen("results.txt","a");
	    if (ans == NULL) {
	      fprintf(stderr, "Can't open input file 'results.txt'!\n");
	      return -1;
	    }
	
	// Two or more charges.
	int charges=0;
	for(x=0; (*any).taskArray[x] != '\0'; x++)	charges++;
	
	int nodes=0;
	for(x=0; any[x].batCap == 3600; x++)	nodes++;

	diedbatteries = 0;
	timeInit2 = 0.0;
	
	do{
		for(y=0; y < nodes; y++){
			if(any[y].deadBat == 0){
				timeInit2 = *timeInit;

				// Main execution.
				// printf("Id: %d - I: %f - ",any[y].id,I);
				for (x = 0; x < charges; x++){
					t = (*timeInit);
					I = any[y].taskArray[x];
					// printf("t: %f\n  %f -",t,any[y].i);
					while(t < *timeInit + any[y].timeArray[x]){
						any[y].i = (any[y].i0 * exp(- kl * t)) + ((((any[y].batCap * kl * c) - I)*(1 - exp(- kl * t))) / kl) - (I * c * ((kl * t) - 1 + exp(- kl * t)) / kl);
						any[y].j = (any[y].j0 * exp(- kl * t)) + (any[y].batCap * (1 - c) * (1 - exp(- kl * t)))	- ((I * (1 - c) * ((kl * t) - 1 + exp(- kl * t))) / kl);
						t = t + 0.01;
					}
					fprintf(ans, "%f %f\n", t, any[y].i);
					// printf("  %f \n",any[y].i);
					*timeInit = t;
 				}
				any[y].batUpTime = t;
				if(any[y].i < BATLEVEL && any[y].deadBat == 0){
					any[y].deadBat = 1;
				}
// printf("\n\n");
				
				// Executing all other nodes.
				for(z=0; z < nodes; z++){
					if(z != y && any[z].deadBat == 0){
						*timeInit = timeInit2;
						// printf(">Id: %d - I: %f -",any[z].id,I);
						for (x = 0; x < charges; x++){
							t = (*timeInit);
							I = 0.005; // Charge rest (in A).
							// printf("t: %f\n  %f -",t,any[z].i);
							while(t < *timeInit + any[z].timeArray[x]){
								any[z].i = (any[z].i0 * exp(- kl * t)) + ((((any[z].batCap * kl * c) - I)*(1 - exp(- kl * t))) / kl) - (I * c * ((kl * t) - 1 + exp(- kl * t)) / kl);
								any[z].j = (any[z].j0 * exp(- kl * t)) + (any[z].batCap * (1 - c) * (1 - exp(- kl * t))) - ((I * (1 - c) * ((kl * t) - 1 + exp(- kl * t))) / kl);
								t = t + 0.01;
							}
							// printf("  %f (out)\n",any[z].i);
							*timeInit = t;
						}
						any[z].batUpTime = t;
						if(any[z].i < BATLEVEL && any[z].deadBat == 0){
							any[z].deadBat = 1;
						}
					}
				}
// printf("\n\n");
			}
			//(*timeInit) = t;
		}
		
		diedbatteries=0;
		for(z=0; z < nodes; z++){
			if(any[z].deadBat == 1){
				diedbatteries++;
			}
		}
	}while (diedbatteries < nodes);

	for(z=0; z < nodes; z++){
		any[z].batCap = any[z].i + any[z].j;
		any[z].i0 = any[z].i;
		any[z].j0 = any[z].j;
	}
	
	close(ans);
	return 0;	
}