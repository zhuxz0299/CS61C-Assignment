#include "transpose.h"

/* The naive transpose function as a reference. */
void transpose_naive(int n, int blocksize, int *dst, int *src)
{
    for (int x = 0; x < n; x++)
    {
        for (int y = 0; y < n; y++)
        {
            dst[y + x * n] = src[x + y * n];
        }
    }
}

/* Implement cache blocking below. You should NOT assume that n is a
 * multiple of the block size. */
void transpose_blocking(int n, int blocksize, int *dst, int *src)
{
    // YOUR CODE HERE
    for (int i = 0; i < n; i += blocksize)
    {
        int i_end = i + blocksize < n ? i + blocksize : n;
        for (int j = 0; j < n; j += blocksize)
        {
            int j_end = j + blocksize < n ? j + blocksize : n;
            for (int x = i; x < i_end; x++)
            {
                for (int y = j; y < j_end; y++)
                {
                    dst[y + x * n] = src[x + y * n];
                }
            }
        }
    }
}

void transpose_blocking_v1(int n, int blocksize, int *dst, int *src)
{
    for (int i = 0; i * blocksize < n; i++)
        for (int j = 0; j * blocksize < n; j++)
            for (int x = 0; x < blocksize && x + i * blocksize < n; x++)
                for (int y = 0; y < blocksize && y + j * blocksize < n; y++)
                {
                    dst[j * blocksize + y + (i * blocksize + x) * n] = src[i * blocksize + x + (j * blocksize + y) * n];
                }
}

void transpose_blocking_v2(int n, int blocksize, int *dst, int *src)
{
    for (int i = 0; i < n; i += blocksize)
        for (int j = 0; j < n; j += blocksize)
            for (int x = i; x < n && x < i + blocksize; x++)
                for (int y = j; y < n && y < j + blocksize; y++)
                    dst[y + x * n] = src[x + y * n];
}
