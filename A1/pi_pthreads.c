/*
============================================================================
Filename    : pi.c
Author      : Jonas Bonnaudet
SCIPER		: 361946
============================================================================
*/

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
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

struct thread_args
{
	int *counter;
	int samples;
	int *thread_num;
};

void *work(void *a)
{
	struct thread_args *args = (struct thread_args *)a;

	// printf("found args at %p\n", args);

	int *counter = args->counter;
	int samples = args->samples;
	int thread_num = *(args->thread_num);
	// printf("starting %d\n", thread_num);

	rand_gen random = init_rand_pthreads(thread_num);
	for (int i = 0; i < samples; i++)
	{
		float x = next_rand(random);
		float y = next_rand(random);

		if (x * x + y * y < 1)
		{
			{
				(*counter)++;
			}
		}
	}

	free_rand(random);

	free(args);

	return 0;
}

double calculate_pi(int num_threads, int samples)
{
	/* Your code goes here */
	int *inside = calloc(num_threads, sizeof(int));

	int new_samples = samples / num_threads;
	pthread_t tid[num_threads];
	int thread_num[num_threads];

	for (int i = 0; i < num_threads; i++)
	{
		// printf("creating thread %d\n", i);
		thread_num[i] = i;
		struct thread_args *args = malloc(sizeof(struct thread_args));

		args->counter = &(inside[i]);
		args->samples = new_samples;
		args->thread_num = &thread_num[i];

		// printf("thread_num in thread_args is: %p, value is %d\n", args->thread_num, *args->thread_num);
		// printf("args is at %p\n", &args);
		pthread_create(&tid[i], NULL, work, (void *)(args));
	}

	/* All threads join master thread and disband */
	for (int i = 0; i < num_threads; i++)
	{
		pthread_join(tid[i], NULL);
	}

	int sum = 0;
	for (int i = 0; i < num_threads; i++)
	{
		// printf("then inside is: %d and thread_num is: %d\n", inside[i], thread_num[i]);
		sum += inside[i];
	}

	double pi = (sum / (float)samples) * 4;

	return pi;
}
