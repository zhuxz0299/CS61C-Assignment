#include <stdio.h>
#include "bit_ops.h"

// Return the nth bit of x.
// Assume 0 <= n <= 31
unsigned get_bit(unsigned x,
                 unsigned n)
{
    return 1 & (x >> n);
}
// Set the nth bit of the value of x to v.
// Assume 0 <= n <= 31, and v is 0 or 1
void set_bit(unsigned *x,
             unsigned n,
             unsigned v)
{
    unsigned ormask = v << n;
    unsigned andmask = ~((1 - v) << n);
    *x = (*x & andmask) | ormask;
}
// Flip the nth bit of the value of x.
// Assume 0 <= n <= 31
void flip_bit(unsigned *x,
              unsigned n)
{
    unsigned nth_bit = get_bit(*x, n);
    nth_bit = 1 - nth_bit;
    set_bit(x, n, nth_bit);
}
