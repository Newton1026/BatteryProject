#include <time.h>
#include <stdio.h>

#include "kibam.h"
#include "nodes.h"

#define CONTROL 1
#define NODES 2
#define BATTERYLEVEL 2500 // Used for tests. Default Value: 0.0;
#define ITEMS(x) (sizeof(x)-sizeof(x[0]))/sizeof(x[0])

int main(){
	
	srand(time(NULL));

	// Testing if the especified file exists. If YES, remove it.
	if(fopen("results.txt","r")){
		remove("results.txt");
	}

	node node[NODES];
	float taskSet[] = {0.40,	0.005,	'\0'};	// in mA.
	int taskTimes[] = {10,		120,	'\0'};	// in ms.

	float recoveryTaskSet[] = {0.005,	'\0'};	// in mA.
	int recoveryTaskTimes[] = {130,		'\0'};	// in ms.	
	
	int i, j, diedBatteries;
	float timeInit, timeInit2;					// in ms.
	float maxPeriod;							// in seconds.
	
	printf("\n\n");

	timeInit = 0.0;
	diedBatteries = 0;
	maxPeriod = 30.0;

	if(CONTROL == 1){
		// Executing one node after the other.
		for(i=0;i < NODES;i++){
			newNode(&node[i], taskSet, taskTimes);
			while(node[i].battery > BATTERYLEVEL){
				kibam(&(node[i].battery), node[i].tasks, &timeInit, maxPeriod, node[i].taskPeriods, ITEMS(taskSet), &(node[i].batteryUpTime));
				printf("Node: %d .:. Battery: %.2f .:. UpTime: %.1f .:. timeInit: %.1f\n\n", i, node[i].battery, node[i].batteryUpTime, timeInit);
			}
			printf("######################################################################\n\n");
			timeInit = 0.0;
		}
		for(i=0;i < NODES;i++)	showNode(&node[i]);
	}
	/*################################################################################################################################*/
	else{
		// 	Switching nodes.
		for(i=0;i < NODES;i++)	newNode(&node[i], taskSet, taskTimes);
		while(diedBatteries < NODES){
			for(i=0;i < NODES;i++){
				if(node[i].battery > BATTERYLEVEL){
					timeInit2 = timeInit;
					printf("Node: %d .:. Battery: %f .:. UpTime: %.1f .:. timeInit: %.1f\n\n", i, node[i].battery, node[i].batteryUpTime, timeInit);
					kibam(&(node[i].battery), node[i].tasks, &timeInit, maxPeriod, node[i].taskPeriods, ITEMS(taskSet),&(node[i].batteryUpTime));
				
					// Loop responsible for the Recovery Effect. The node execute a low charge for a predefined time.
					for(j=0;j < NODES;j++){
						if(j != i){
							if(node[j].battery > BATTERYLEVEL){
								printf(">Node: %d .:. Battery: %f .:. UpTime: %.1f .:. timeInit: %.1f\n\n", j, node[j].battery, node[j].batteryUpTime, timeInit2);
								kibam(&(node[j].battery), recoveryTaskSet, &timeInit2, maxPeriod, recoveryTaskTimes, ITEMS(recoveryTaskSet),&(node[j].batteryUpTime));
							}
						}
					}
			
				}else{
					diedBatteries++;
				}
			}
			if(diedBatteries == NODES)	printf("All batteries are dead.\n\n");
		}
		for(i=0;i < NODES;i++)	showNode(&node[i]);
	}
	
	printf("\n");
	return 0;
}