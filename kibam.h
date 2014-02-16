/*
    This library define the functions for Kinetic Battery Model (KiBaM), as
    described in [Battery Modeling - M. R. Jongerden and B. R. Haverkort].

    Author: Leonardo Martins Rodrigues.
    Date of creation: 11-02-2014 - Version: 1.0
*/

#ifndef KIBAM_H_
#define KIBAM_H_

int kibam(float *batCapacity, float *currents, float *timeInit, float maxPeriod, int *timePeriods, int numberOfCharges, float *batteryUpTime);

#endif