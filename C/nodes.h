/*
    This library defines the functions for simulated nodes.

    Author: Leonardo Martins Rodrigues.
    Date of creation: 11-02-2014 - Version: 1.0
*/

#ifndef NODE_H_
#define NODE_H_

typedef struct nodes_t{
	
	int id;
	
	float *taskArray;		// Defining a set of tasks (in A).
	float *timeArray;		// Defining a set of task Periods (in sec).
	
	float batCap;		// Defining the node battery (in As).
	float batUpTime;	// Defining a time control for battery up time (in sec).
	int deadBat;

	float i0;	// For KiBaM use.
	float j0;	// For KiBaM use.
	float i;	// For KiBaM use.
	float j;	// For KiBaM use.
	
}node;

float As2mAh (float batCapInAs);
float sec2min (float timeInSec);

int newNode(node *new, int id, float *taskArray, float *timeArray);

void showNode(node *any);
void emptyTaskArray(node *any);
void changeTaskArray(node *any, float *newTaskArray, float *newTimeArray);

#endif