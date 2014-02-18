/*
    This library define the functions for simulated nodes.

    Author: Leonardo Martins Rodrigues.
    Date of creation: 11-02-2014 - Version: 1.0
*/

#ifndef NODE_H_
#define NODE_H_

typedef struct nodes_t{
	int id;				// Identifies the node.
	float *tasks;		// Defining a set of tasks (in Ampere).
	int *taskPeriods;	// Defining a set of task Periods (in ms).
	float battery;		// Defining the node battery.
	float batteryUpTime;// Defining a time control for battery up time (in sec).
}node;

int newNode(node *new, float *taskArray, int *timeArray);
void showNode(node *any);
void emptyTaskArray(node *any);
void changeTaskArray(node *any, float *newTaskArray, int *newTimeArray);

#endif