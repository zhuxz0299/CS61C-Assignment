#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "lfsr.h"

void lfsr_calculate(uint16_t *reg)
{
    uint16_t bit_0 = *reg & 1;
    uint16_t bit_2 = (*reg >> 2) & 1;
    uint16_t bit_3 = (*reg >> 3) & 1;
    uint16_t bit_5 = (*reg >> 5) & 1;
    uint16_t new_bit = ((bit_0 ^ bit_2) ^ bit_3) ^ bit_5;
    *reg = (*reg >> 1) | (new_bit << 15);
}
