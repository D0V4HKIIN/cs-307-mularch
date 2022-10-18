/*
============================================================================
Filename    : algorithm.c
Author      : Jonas Bonnaudet and Alexander Müller
SCIPER		: 361946 and 312276
============================================================================
*/
#include <math.h>

#define INPUT(I, J) input[(I)*length + (J)]
#define OUTPUT(I, J) output[(I)*length + (J)]

#define THREAD_OUTPUT(J) thread_output[J]

void simulate(double *input, double *output, int threads, int length, int iterations)
{
	double *temp;
	double *thread_output;

	omp_set_num_threads(threads);
	
	// Parallelize this!!
	for (int n = 0; n < iterations; n++)
	{
		#pragma omp parallel private(thread_output)
		{
			thread_output = (double *)calloc(length, sizeof(double));
			#pragma omp for
			for (int i = 1; i < length - 1; i++)
			{
				for (int j = 1; j < length - 1; j++)
				{
					if (((i == length / 2 - 1) || (i == length / 2)) && ((j == length / 2 - 1) || (j == length / 2)))
						continue;

					THREAD_OUTPUT(j) = (INPUT(i - 1, j - 1) + INPUT(i - 1, j) + INPUT(i - 1, j + 1) +
										INPUT(i, j - 1) + INPUT(i, j) + INPUT(i, j + 1) +
										INPUT(i + 1, j - 1) + INPUT(i + 1, j) + INPUT(i + 1, j + 1)) /
									9;
				}
				
					for (int j = 1; j < length - 1; j++)
					{
						OUTPUT(i, j) = THREAD_OUTPUT(j);
					}
			
			}
		}

		temp = input;
		input = output;
		output = temp;
	}
}
