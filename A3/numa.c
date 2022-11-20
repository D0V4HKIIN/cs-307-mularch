#include <stdio.h>
#include <stdlib.h>
#include "utility.h"
#include <stdint.h>

#define UINTMAX (uint8_t)(-1)

#define GB (uint64_t)(1 << 30)
#define SIZE (uint64_t)(8 * GB)

volatile uint8_t *arr;

// ~5s
inline uint64_t next_addr_reversed(uint64_t i)
{
	if(i == 0)
		return SIZE -1;
	// end the loop
	if(i == 1)
		return SIZE;
	return -1;
}

// ~10s
inline uint64_t next_addr_cache_miss(uint64_t i)
{
	if (i == 0)
		return 1;
	if (i + 8 > SIZE)
	{
		printf("%li\n",  -i + ((i + 9) % SIZE));
		return -i + ((i + 9) % SIZE);
	}
	return 8;
}

inline uint64_t next_addr(uint64_t i)
{
	// Change this part
	return arr[i];

}

inline void init_array(rand_gen gen)
{
	printf("initializing array\n");fflush(stdout);
	// Change this part
	for (uint64_t i = 0; i < SIZE; i++)
	{
		arr[i] = 8*( (int)(next_rand(gen) * 8 + 8));
	}
	printf("array initialized!\n");fflush(stdout);
}

int main()
{
	uint64_t i, counter;
	double time;
	volatile uint8_t temp;

	arr = (uint8_t *)malloc(SIZE);
	rand_gen gen = init_rand();

	init_array(gen);
	// don't forget to free man >:-(
	free_rand(gen);

	// Start timer
	set_clock();

	for (i = 0, counter = 0; i < SIZE; counter++)
	{
		temp = arr[i];
		i += next_addr(i);
	}

	// Stop timer
	time = elapsed_time();

	temp = next_rand(gen) * 10;
	i = temp; // Just to suppress the compiler warning for not using temp and gen

	if (counter < 10000000)
		printf("ERROR: Too few accesses. You have to access more elements to measure reasonable time difference.\n");
	if ((time / counter) < 1.0e-8)
		printf("ERROR: Time per access is too small. You have to further deoptimize the program to measure reasonable time difference.\n");
	printf("Traversing %lx GB array took total time = %.4g seconds, number of accesses = %lu, %.4g seconds per access\n", SIZE / GB, time, counter, time / counter);

	return 0;
}