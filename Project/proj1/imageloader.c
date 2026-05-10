/************************************************************************
**
** NAME:        imageloader.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**              Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-15
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>
#include "imageloader.h"

// Opens a .ppm P3 image file, and constructs an Image object.
// You may find the function fscanf useful.
// Make sure that you close the file with fclose before returning.
Image *readData(char *filename)
{
	FILE *fp = fopen(filename, "r");
	if (fp == NULL)
	{
		printf("Error filename!\n");
		return NULL;
	}

	Image *new_image = malloc(sizeof(Image));
	char buf[5];
	int range;

	fscanf(fp, "%4s", buf);
	fscanf(fp, "%u %u", &(new_image->cols), &(new_image->rows));
	fscanf(fp, "%d", &range);

	new_image->image = malloc(new_image->rows * sizeof(Color *));
	for (int i = 0; i < new_image->rows; i++)
		new_image->image[i] = malloc(new_image->cols * sizeof(Color));

	for (int i = 0; i < new_image->rows; i++)
		for (int j = 0; j < new_image->cols; j++)
		{
			int r, g, b;
			fscanf(fp, "%d %d %d", &r, &g, &b);
			new_image->image[i][j].R = r;
			new_image->image[i][j].G = g;
			new_image->image[i][j].B = b;
		}

	fclose(fp);
	return new_image;
}

// Given an image, prints to stdout (e.g. with printf) a .ppm P3 file with the image's data.
void writeData(Image *image)
{
	printf("P3\n");
	printf("%u %u\n", image->cols, image->rows);
	printf("255\n");

	for (int i = 0; i < image->rows; i++)
	{
		for (int j = 0; j < image->cols; j++)
		{
			printf("%3u %3u %3u",
				   (unsigned int)image->image[i][j].R,
				   (unsigned int)image->image[i][j].G,
				   (unsigned int)image->image[i][j].B);
			if (j < image->cols - 1)
				printf("   ");
		}
		printf("\n");
	}
}

// Frees an image
void freeImage(Image *image)
{
	for (int i = 0; i < image->rows; i++)
		free(image->image[i]);

	free(image->image);
	free(image);
}
