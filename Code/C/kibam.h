/*
    This library defines the functions for Kinetic Battery Model (KiBaM), as
    described in [Battery Modeling - M. R. Jongerden and B. R. Haverkort].

    Author: Leonardo Martins Rodrigues.
    Date of creation: 11-02-2014 - Version: 1.0
*/
#include "nodes.h"

#ifndef KIBAM_H_
#define KIBAM_H_

int kibamTop(node *any, float *timeInit);
int kibamTopInterleaved(node *any, float *timeInit);

#endif