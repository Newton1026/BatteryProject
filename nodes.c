/*
    This source code implements the functions for simulated nodes.

    Author: Leonardo Martins Rodrigues.
    Date of creation: 11-02-2014 - Version: 1.0
*/

#include "nodes.h"
#include <stdio.h>
#include <stdlib.h>

int newNode(node *new, float *taskArray, int *timeArray){
	
	(*new).id = rand() % 20;
	printf("New node created!\n");
	
	(*new).battery = 3600;
	/*	3960 As = 1100 mAh;
		3600 As = 1000 mAh;
		2160 As = 600 mAh;
		1890 As = 525 mAh;
		1710 As = 475 mAh;
		1530 As = 425 mAh;
		1260 As = 350 mAh;
	*/
	
	(*new).batteryUpTime = 0.0;
	
	(*new).tasks = taskArray;
	
	(*new).taskPeriods = timeArray;
	
	showNode(new);
}

void showNode(node *any){
	int i;
	
	printf("---> Id #%d",(*any).id);
	printf("  Battery: %.1f As (%.1f mAh) worked for %.1f min (%.1f sec)\n",(*any).battery, (((*any).battery)*2000)/7200, (*any).batteryUpTime/60,(*any).batteryUpTime);
	
	if((*any).tasks == NULL){
		printf("	There is no task set assign to Node %d.\n",(*any).id);
	}else{
		for(i=0; (*any).tasks[i] != '\0'; i++){
			printf("	Task %d: %.3f for %d ms\n", i, (*any).tasks[i], (*any).taskPeriods[i]);
		}
		printf("\n");
		
	}
}

void emptyTaskArray(node *any){
	(*any).tasks = NULL;
	(*any).taskPeriods = NULL;
	printf("The task set for Node %d is now empty!\n", (*any).id);
	showNode(any);
}

void changeTaskArray(node *any, float *newTaskArray, int *newTimeArray){
	if((*any).tasks != NULL){
		(*any).tasks = NULL;
		(*any).taskPeriods = NULL;
	}
	(*any).tasks = newTaskArray;
	(*any).taskPeriods = newTimeArray;
	printf("New task set for Node %d!\n", (*any).id);
	showNode(any);
}