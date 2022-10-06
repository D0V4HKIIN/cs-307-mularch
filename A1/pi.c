/*
============================================================================
Filename    : pi.c
Author      : Jonas Bonnaudet
SCIPER		: 361946
============================================================================
*/

#include <stdio.h>
#include <stdlib.h>
#include "utility.h"

double calculate_pi(int num_threads, int samples);

int main(int argc, const char *argv[])
{

	int num_threads, num_samples;
	double pi;

	if (argc != 3)
	{
		printf("Invalid input! Usage: ./pi <num_threads> <num_samples> \n");
		return 1;
	}
	else
	{
		num_threads = atoi(argv[1]);
		num_samples = atoi(argv[2]);
	}

	set_clock();
	pi = calculate_pi(num_threads, num_samples);

	printf("- Using %d threads: pi = %.15g computed in %.4gs.\n", num_threads, pi, elapsed_time());

	return 0;
}

double calculate_pi(int num_threads, int samples)
{

	/* Your code goes here */
	int sum = 0;
	omp_set_num_threads(num_threads);
	int new_samples = samples / num_threads;

#pragma omp parallel
	{
		int inside = 0;
		int tid = omp_get_thread_num();
		rand_gen random = init_rand();
		for (int i = 0; i < new_samples; i++)
		{
			float x = next_rand(random);
			float y = next_rand(random);

			if (x * x + y * y < 1)
			{
				{
					inside++;
				}
			}
		}

		free_rand(random);

#pragma critical
		{
			sum += inside;
		}
	}

	return (sum / (float)samples) * 4;
}
