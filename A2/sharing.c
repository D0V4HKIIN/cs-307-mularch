/*
============================================================================
Filename    : pi.c
Author      : Jonas Bonnaudet and Alexander Müller
SCIPER		: 361946 and ...
============================================================================
*/

#include <stdio.h>
#include <stdlib.h>
#include "utility.h"

int perform_buckets_computation(int num_threads, int num_samples, int num_buckets);

int main(int argc, const char *argv[])
{
	int num_threads, num_samples, num_buckets;

	if (argc != 4)
	{
		printf("Invalid input! Usage: ./sharing <num_threads> <num_samples> <num_buckets> \n");
		return 1;
	}
	else
	{
		num_threads = atoi(argv[1]);
		num_samples = atoi(argv[2]);
		num_buckets = atoi(argv[3]);
	}

	set_clock();
	perform_buckets_computation(num_threads, num_samples, num_buckets);

	printf("Using %d threads: %d operations completed in %.4gs.\n", num_threads, num_samples, elapsed_time());
	return 0;
}

int perform_buckets_computation(int num_threads, int num_samples, int num_buckets)
{

	volatile int *histogram = (int *)calloc(num_buckets, sizeof(int));

	omp_set_num_threads(num_threads);

	rand_gen generator;
	volatile int *thread_histogram;
#pragma omp parallel private(generator, thread_histogram)
	{
		generator = init_rand();
		thread_histogram = (int *)calloc(num_buckets, sizeof(int));

#pragma omp for
		for (int i = 0; i < num_samples; i++)
		{
			int val = next_rand(generator) * num_buckets;
			thread_histogram[val]++;
		}
		free_rand(generator);

#pragma omp critical
		{
			for (int i = 0; i < num_buckets; i++)
			{
				histogram[i] += thread_histogram[i];
			}
		}
	}

	return 0;
}
