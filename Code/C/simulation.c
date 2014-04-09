/*
    This source code defines the main informations for simulated nodes.

    Author: Leonardo Martins Rodrigues.
    Date of creation: 11-02-2014 - Version: 1.0

	Execution instructions (terminal/console):
	$ gcc nodes.c kibam.c simulation.c -o out
	$ ./out

	From GNU/Octave (Same folder of the source files):
	$ plot(load('results.txt'));

*/

#include <time.h>
#include <stdio.h>

#include "kibam.h"
#include "nodes.h"

#define NODES 	1			// Defining how many nodes in simulation.
#define CONTROL 1			// Use: 1 - Node after node; or 2 - Node interchanging.


int main(){
	
	// Testing if the especified file exists. If YES, remove it.
	if(fopen("results.txt","r")){
		remove("results.txt");
	}

	node node[NODES];
	float taskSet[]		=	{0.040,		'\0'};		// in A.
	float taskTimes[]	=	{01.00,		'\0'};		// in s.
	
	int x, z, diedBatteries;
	float timeInit;				// in s.

	timeInit = 0.0;
	diedBatteries = 0;
	
	printf("\n\n");

	// Creating nodes.
	for(x=0;x < NODES;x++)	newNode(&node[x], x, taskSet, taskTimes);

	if(CONTROL == 1){
		// Executing one node after the other.
		for(x=0;x < NODES;x++)	kibamTop(&node[x], &timeInit);
	}
	else{
		// Switching nodes.
		kibamTopInterleaved(node, &timeInit);
	}
	
	for(x=0;x < NODES;x++)	showNode(&node[x]);
	return 0;
}