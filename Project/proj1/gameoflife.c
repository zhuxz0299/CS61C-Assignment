/************************************************************************
**
** NAME:        gameoflife.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "imageloader.h"

// Determines what color the cell at the given row/col should be. This function allocates space for a new Color.
// Note that you will need to read the eight neighbors of the cell in question. The grid "wraps", so we treat the top row as adjacent to the bottom row
// and the left column as adjacent to the right column.
Color *evaluateOneCell(Image *image, int row, int col, uint32_t rule)
{
	// YOUR CODE HERE
	int rule_arr[18];
	int live_neighbour_num[24] = {0};
	int rgb_arr[24];
	Color rgb, *ret_rgb;
	int mix_rgb;

	for (int i = 0; i < 18; i++)
	{
		rule_arr[i] = rule % 2;
		rule /= 2;
	}

	for (int row_shift = -1; row_shift <= 1; row_shift++)
		for (int col_shift = -1; col_shift <= 1; col_shift++)
		{
			if (row_shift == 0 && col_shift == 0)
				continue;
			int nb_row = (row + row_shift + image->rows) % image->rows;
			int nb_col = (col + col_shift + image->cols) % image->cols;

			rgb = image->image[nb_row][nb_col];
			mix_rgb = rgb.R * (1 << 16) + rgb.G * (1 << 8) + rgb.B;
			for (int i = 0; i < 24; i++)
			{
				live_neighbour_num[i] += mix_rgb % 2;
				mix_rgb /= 2;
			}
		}

	rgb = image->image[row][col];
	mix_rgb = rgb.R * (1 << 16) + rgb.G * (1 << 8) + rgb.B;
	for (int i = 0; i < 24; i++)
	{
		rgb_arr[i] = mix_rgb % 2;
		mix_rgb /= 2;
		if (rgb_arr[i] == 1)
			rgb_arr[i] = rule_arr[live_neighbour_num[i] + 9];
		else
			rgb_arr[i] = rule_arr[live_neighbour_num[i]];
	}

	ret_rgb = malloc(sizeof(Color));
	ret_rgb->R = ret_rgb->G = ret_rgb->B = 0;
	for (int i = 0; i < 8; i++)
	{
		ret_rgb->R += rgb_arr[i + 16] * (1 << i);
		ret_rgb->G += rgb_arr[i + 8] * (1 << i);
		ret_rgb->B += rgb_arr[i] * (1 << i);
	}

	return ret_rgb;
}

// The main body of Life; given an image and a rule, computes one iteration of the Game of Life.
// You should be able to copy most of this from steganography.c
Image *life(Image *image, uint32_t rule)
{
	// YOUR CODE HERE
	Image *new_image = malloc(sizeof(Image));
	new_image->rows = image->rows;
	new_image->cols = image->cols;
	new_image->image = malloc(image->rows * sizeof(Color *));
	for (int i = 0; i < image->rows; i++)
		new_image->image[i] = malloc(image->cols * sizeof(Color));

	for (int i = 0; i < image->rows; i++)
		for (int j = 0; j < image->cols; j++)
		{
			Color *new_color = evaluateOneCell(image, i, j, rule);
			new_image->image[i][j] = *new_color;
			free(new_color);
		}
	return new_image;
}

/*
Loads a .ppm from a file, computes the next iteration of the game of life, then prints to stdout the new image.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a .ppm.
argv[2] should contain a hexadecimal number (such as 0x1808). Note that this will be a string.
You may find the function strtol useful for this conversion.
If the input is not correct, a malloc fails, or any other error occurs, you should exit with code -1.
Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!

You may find it useful to copy the code from steganography.c, to start.
*/
int main(int argc, char **argv)
{
	// YOUR CODE HERE
	if (argc != 3)
	{
		printf("usage: ./gameOfLife filename rule\nfilename is an ASCII PPM file (type P3) with maximum value 255.\nrule is a hex number beginning with 0x; Life is 0x1808.\n");
		exit(-1);
	}
	char *file_name = argv[1];
	uint32_t rule = strtol(argv[2], NULL, 16);

	Image *image = readData(file_name);
	if (image == NULL)
		exit(-1);
	Image *new_image = life(image, rule);
	writeData(new_image);
	freeImage(image);
	freeImage(new_image);
	return 0;
}
