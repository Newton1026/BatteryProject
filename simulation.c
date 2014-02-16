#include <time.h>
#include <stdio.h>

#include "kibam.h"
#include "nodes.h"

#define NODES 2
#define BATTERYLEVEL 3500 // Used for tests. Default Value: 0.0;
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
	int i, diedBatteries;
	float timeInit;								// in ms.
	float maxPeriod;							// in seconds.
	
	printf("\n\n");

	timeInit = 0.0;
	diedBatteries = 0;
	maxPeriod = 300.0;

	// // Executing one node after the other.
	// for(i=0;i < NODES;i++){
	// 	newNode(&node[i], taskSet, taskTimes);
	// 	while(node[i].battery > BATTERYLEVEL){
	// 		kibam(&(node[i].battery), node[i].tasks, &timeInit, maxPeriod, node[i].taskPeriods, ITEMS(taskSet), &(node[i].batteryUpTime));
	// 		printf("Node: %d .:. Battery: %f .:. UpTime: %.1f.\n\n", i, node[i].battery, node[i].batteryUpTime);
	// 	}
	// 	showNode(&node[i]);
	// 	printf("########################################\n");
	// }

	/*##########################################################################################################*/

	// 	Switching nodes.
	for(i=0;i < NODES;i++)	newNode(&node[i], taskSet, taskTimes);
	while(diedBatteries < NODES){
		for(i=0;i < NODES;i++){
			if(node[i].battery > BATTERYLEVEL){
				kibam(&(node[i].battery), node[i].tasks, &timeInit, maxPeriod, node[i].taskPeriods, ITEMS(taskSet),&(node[i].batteryUpTime));
				printf("Node: %d .:. Battery: %f .:. UpTime: %.1f.\n\n", i, node[i].battery, node[i].batteryUpTime);
			}else{
				printf("All batteries are dead.\n\n");
				diedBatteries++;
			}
		}
	}
	for(i=0;i < NODES;i++)	showNode(&node[i]);

	printf("\n");
	return 0;
}