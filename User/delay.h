#ifndef __DELAY_H
#define	__DELAY_H

#ifdef __cplusplus
extern "C"
{
#endif 

#include "mhscpu.h"
#include "stdint.h"

void Delay_Init(void);

void Delay_us(uint32_t usec);
void Delay_ms(uint32_t msec);

#ifdef __cplusplus
}
#endif

#endif   ///< __DELAY_H
