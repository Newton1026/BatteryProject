/*
    This source code implements the functions for simulated nodes.

    Author: Leonardo Martins Rodrigues.
    Date of creation: 11-02-2014 - Version: 1.0
*/

#include "nodes.h"
#include <stdio.h>
#include <stdlib.h>

float As2mAh (float batCapInAs){
	return ((batCapInAs * 2000) / 7200);
}

float sec2min (float timeInSec){
	return (timeInSec / 60);
}

int newNode(node *new, int id, float *taskArray, float *timeArray){
	
	float c = 0.625;
	
	(*new).id = id;
	(*new).taskArray = taskArray;
	(*new).timeArray = timeArray;

	/*	
		3960 As = 1100 mAh;		3600 As = 1000 mAh;		2160 As = 600 mAh;
		1890 As = 525 mAh;		1710 As = 475 mAh;		1530 As = 425 mAh;
		1260 As = 350 mAh;
	*/
		
	(*new).batCap = 3600.0;
	(*new).batUpTime = 0.0;
	(*new).deadBat = 0;
	
    (*new).i0 = (*new).batCap * c;
    (*new).j0 = (*new).batCap * (1-c);

	
	showNode(new);
	return 0;
}

void showNode(node *any){
	int i;
	
	printf("Node %d: ", (*any).id);
	printf("--> Battery: %.2f As (%.2f mAh) > i=%.2f | j=%.2f\n", (*any).batCap, As2mAh((*any).batCap), (*any).i0, (*any).j0);
	printf("	--> Work time: %.2f min (%.2f sec)\n", sec2min((*any).batUpTime), (*any).batUpTime);
	
	if((*any).taskArray == NULL){
		printf("	There is no task set assign to the Node.\n");
	}else{
		for(i=0; (*any).taskArray[i] != '\0'; i++){
			printf("	--> Task %d: %.3f A for %.3f s\n", i, (*any).taskArray[i], (*any).timeArray[i]);
		}
		printf("\n");
	}
}

void emptyTaskArray(node *any){
	(*any).taskArray = NULL;
	(*any).timeArray = NULL;
	showNode(any);
}

void changeTaskArray(node *any, float *newTaskArray, float *newTimeArray){
	if((*any).taskArray != NULL){
		(*any).taskArray = NULL;
		(*any).timeArray = NULL;
	}
	(*any).taskArray = newTaskArray;
	(*any).timeArray = newTimeArray;
	showNode(any);
}