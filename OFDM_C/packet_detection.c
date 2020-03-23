#include "L138_LCDK_aic3106_init.h"
#include "evmomapl138_gpio.h"
#include <stdint.h>
#include <math.h>
#include <ti/dsplib/dsplib.h>

#define STF_LEN 210
float y_conj_i[(STF_LEN*11)-1];
float y_conj_q[(STF_LEN*11)-1];

float r_i[STF_LEN*10];
float r_q[STF_LEN*10];
float r_mag[STF_LEN*10];

float r_mean;
float r_std;
float thresh;

float possible_peaks[STF_LEN*10];

bool detected;

conjugate_y(){
    int i, j;
    for (i = 0; i < (STF_LEN*10); i++){
        y_conj_i[i] = y_i[i];
        y_conj_q[i] = -1 * y_q[i];
    }
    for (j = 0; j < (STF_LEN-1); j++){
        y_conj_i[STF_LEN+J] = 0;
        y_conj_q[STF_LEN+J] = 0;
    }
}

calculateMagnitude_r () {
	int i;
	for (i = 0; i < (STF_LEN*10); i++) {
	        r_mag[i] = sqrtf(powf(r_i[i],2.0) + powf(r_q[i],2.0));
	    }
}

calculateThresh (){
    int i, j;
    for (i = 0; i < (STF_LEN*10); i++){
        r_mean = r_mean + (r_mag[i] / (STD_LEN * 10));
    }
    for (j = 0; j < (STF_LEN*10); j++){
        r_std = r_std + (powf((r_mag[i] - r_mean),2) / (STD_LEN * 10));
    }
    r_std = sqrtf(r_std);
    thresh = r_mean + (2*r_std);
}

correlate_stf () {
    int i, j;
    for (i = 0; i < (STF_LEN*10); i++) {
        for (j = 0; j < STF_LEN; j++) {
            r_i[i] = r_i[i] + ((y_i[i+j] * STF_i[j]) + (y_q[i+j] * STF_q[j]))
            r_q[i] = r_q[i] + ((y_i[i+j] * STF_q[j]) - (y_q[i+j] * STF_i[j]))
        }
        r_mag[i] = sqrtf(powf(r_i[i],2.0) + powf(r_q[i],2.0));
    }
}

packet_detect(){
    correlate_stf();
    // calculateMagnitude_r();
    // calculateThresh();
    int i, j;
    for(i = 0; i < (STF_LEN*2); i++){
        peak_cnt = 0;
        for(j = i; j < (i+(8*STF_LEN)); j+=STF_LEN){
            if (r_mag[j] > thresh) {
                peak_cnt++;
            }
        }
        if (peak_cnt == 9){
            detected = true;
            break;
        }
    }
}
