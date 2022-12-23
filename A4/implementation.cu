/*
============================================================================
Filename    : algorithm.c
Author      : Your name goes here
SCIPER      : Your SCIPER number
============================================================================
*/

#include <iostream>
#include <iomanip>
#include <sys/time.h>
#include <cuda_runtime.h>
using namespace std;

// CPU Baseline
void array_process(double *input, double *output, int length, int iterations)
{
    double *temp;

    for(int n=0; n<(int) iterations; n++)
    {
        for(int i=1; i<length-1; i++)
        {
            for(int j=1; j<length-1; j++)
            {
                output[(i)*(length)+(j)] = (input[(i-1)*(length)+(j-1)] +
                                            input[(i-1)*(length)+(j)]   +
                                            input[(i-1)*(length)+(j+1)] +
                                            input[(i)*(length)+(j-1)]   +
                                            input[(i)*(length)+(j)]     +
                                            input[(i)*(length)+(j+1)]   +
                                            input[(i+1)*(length)+(j-1)] +
                                            input[(i+1)*(length)+(j)]   +
                                            input[(i+1)*(length)+(j+1)] ) / 9;

            }
        }
        output[(length/2-1)*length+(length/2-1)] = 1000;
        output[(length/2)*length+(length/2-1)]   = 1000;
        output[(length/2-1)*length+(length/2)]   = 1000;
        output[(length/2)*length+(length/2)]     = 1000;

        temp = input;
        input = output;
        output = temp;
    }
}

// copied from CPU baseline
__global__ void four_ifs(double *input, double *output, int length, int iterations)
{
    int i = (blockIdx.x * blockDim.x) + threadIdx.x + 1;
    int j = (blockIdx.y * blockDim.y) + threadIdx.y + 1;

    int posInArray = (i)*(length)+(j);

    output[posInArray] = (input[(i-1)*(length)+(j-1)] +
                            input[(i-1)*(length)+(j)]   +
                            input[(i-1)*(length)+(j+1)] +
                            input[(i)*(length)+(j-1)]   +
                            input[(i)*(length)+(j)]     +
                            input[(i)*(length)+(j+1)]   +
                            input[(i+1)*(length)+(j-1)] +
                            input[(i+1)*(length)+(j)]   +
                            input[(i+1)*(length)+(j+1)] ) / 9;
    
    if (posInArray == (length/2-1)*length+(length/2-1))
        output[(length/2-1)*length+(length/2-1)] = 1000;
    
    if (posInArray == (length/2)*length+(length/2-1))
        output[(length/2)*length+(length/2-1)] = 1000;
    
    if (posInArray == (length/2-1)*length+(length/2))
        output[(length/2-1)*length+(length/2)] = 1000;
    
    if (posInArray == (length/2)*length+(length/2))
        output[(length/2)*length+(length/2)] = 1000;
}

__global__ void no_ifs(double *input, double *output, int length, int iterations)
{
    int i = (blockIdx.x * blockDim.x) + threadIdx.x + 1;
    int j = (blockIdx.y * blockDim.y) + threadIdx.y + 1;

    int posInArray = (i)*(length)+(j);

    output[posInArray] = (input[(i-1)*(length)+(j-1)] +
                            input[(i-1)*(length)+(j)]   +
                            input[(i-1)*(length)+(j+1)] +
                            input[(i)*(length)+(j-1)]   +
                            input[(i)*(length)+(j)]     +
                            input[(i)*(length)+(j+1)]   +
                            input[(i+1)*(length)+(j-1)] +
                            input[(i+1)*(length)+(j)]   +
                            input[(i+1)*(length)+(j+1)] ) / 9;
    
    output[(length/2-1)*length+(length/2-1)] = 1000;
    output[(length/2)*length+(length/2-1)] = 1000;
    output[(length/2-1)*length+(length/2)] = 1000;
    output[(length/2)*length+(length/2)] = 1000;
}

__global__ void one_if(double *input, double *output, int length, int iterations)
{
    int i = (blockIdx.x * blockDim.x) + threadIdx.x + 1;
    int j = (blockIdx.y * blockDim.y) + threadIdx.y + 1;

    int posInArray = (i)*(length)+(j);

     if (posInArray == (length/2)*length+(length/2) || posInArray == (length/2-1)*length+(length/2-1) || posInArray == (length/2)*length+(length/2-1) || posInArray == (length/2-1)*length+(length/2)){
        output[posInArray] = 1000;
        return;
     }

    output[posInArray] = (input[(i-1)*(length)+(j-1)] +
                            input[(i-1)*(length)+(j)]   +
                            input[(i-1)*(length)+(j+1)] +
                            input[(i)*(length)+(j-1)]   +
                            input[(i)*(length)+(j)]     +
                            input[(i)*(length)+(j+1)]   +
                            input[(i+1)*(length)+(j-1)] +
                            input[(i+1)*(length)+(j)]   +
                            input[(i+1)*(length)+(j+1)] ) / 9;
    
}
__global__ void no_rewrite(double *input, double *output, int length, int iterations)
{
    int i = (blockIdx.x * blockDim.x) + threadIdx.x + 1;
    int j = (blockIdx.y * blockDim.y) + threadIdx.y + 1;

    int posInArray = (i)*(length)+(j);

     if (posInArray == (length/2)*length+(length/2) || posInArray == (length/2-1)*length+(length/2-1) || posInArray == (length/2)*length+(length/2-1) || posInArray == (length/2-1)*length+(length/2)){
        // output[posInArray] = 1000;
        return;
     }

    output[posInArray] = (input[(i-1)*(length)+(j-1)] +
                            input[(i-1)*(length)+(j)]   +
                            input[(i-1)*(length)+(j+1)] +
                            input[(i)*(length)+(j-1)]   +
                            input[(i)*(length)+(j)]     +
                            input[(i)*(length)+(j+1)]   +
                            input[(i+1)*(length)+(j-1)] +
                            input[(i+1)*(length)+(j)]   +
                            input[(i+1)*(length)+(j+1)] ) / 9;
    
}


// not working for more than 76 length
__global__ void shared_memory(double *input, double *output, int length, int iterations)
{
    int max_len = length * length;

    int tidx = threadIdx.x + 1;
    int tidy = threadIdx.y + 1;

    int arrX = (blockIdx.x * blockDim.x) + threadIdx.x + 1;
    int arrY = (blockIdx.y * blockDim.y) + threadIdx.y + 1;

    int posInArray = arrX + length * arrY;

    // in shared memory
    __shared__ double shared_input[THREADS_PER_BLOCK + 2][THREADS_PER_BLOCK + 2];
    // extern __shared__ double shared_output[64][n];
    // copy data
    
    // shared_input[y][x]
    shared_input[tidy][tidx] = (posInArray < max_len) ? input[posInArray] : 0;
    if (arrX >= length - 1 || arrY >= length - 1) return;
    // printf("%d, %d\n", arrX, arrY);

    if (tidx == 1){
        shared_input[tidy][0] = input[posInArray - 1];
        if(tidy == 1){
            shared_input[0][0] = input[posInArray - 1 - length];
        }
    }
    if(tidy == 1){
        shared_input[0][tidx] = input[posInArray - length];
        if (tidx == THREADS_PER_BLOCK){
            shared_input[0][THREADS_PER_BLOCK + 1] = input[posInArray + 1 - length];
        }
    }
    if(tidx == THREADS_PER_BLOCK){
        shared_input[tidy][THREADS_PER_BLOCK + 1] = (posInArray + 1 < max_len) ? input[posInArray + 1] : 0;
        if(tidy == THREADS_PER_BLOCK){
            shared_input[THREADS_PER_BLOCK + 1][THREADS_PER_BLOCK + 1] = (posInArray + 1 + length < max_len) ? input[posInArray + 1 + length] : 0;
        }
    }
    if (tidy == THREADS_PER_BLOCK){
            shared_input[THREADS_PER_BLOCK + 1][tidx] = (posInArray + length < max_len) ? input[posInArray + length] : 0;
            if(tidx == 1){
                shared_input[THREADS_PER_BLOCK + 1][0] = (posInArray - 1 + length < max_len) ? input[posInArray - 1 + length] : 0;
            }
    }
    __syncthreads();

    if (posInArray == (length/2-1)*length+(length/2-1) ||
        posInArray == (length/2)*length+(length/2-1)   ||
        posInArray == (length/2-1)*length+(length/2)   ||
        posInArray == (length/2)*length+(length/2))
    {
        output[posInArray] = 1000;
        // __syncthreads();
        return;
    }

    output[posInArray] = (
                            shared_input[tidy-1][tidx-1]    +
                            shared_input[tidy-1][tidx  ]    +
                            shared_input[tidy-1][tidx+1]    +
                            shared_input[tidy  ][tidx-1]    +
                            shared_input[tidy  ][tidx  ]    +
                            shared_input[tidy  ][tidx+1]    +
                            shared_input[tidy+1][tidx-1]    +
                            shared_input[tidy+1][tidx  ]    +
                            shared_input[tidy+1][tidx+1]
                        ) / 9;
    __syncthreads();

    // if(tidx == 1 && tidy == 1 && blockIdx.x == 0 && blockIdx.y == 0){
    //     printf("shared -------------------------------------\n");
    //     for(int y = 0; y < THREADS_PER_BLOCK + 2; y++){
    //         for(int x = 0; x < THREADS_PER_BLOCK + 2; x++){
    //             printf("%lf, ", shared_input[y][x]);
    //         }
    //         printf("\n");
    //     }

    //     printf("output -------------------------------------\n");
    //     for(int y = 0; y < length; y++){
    //         for(int x = 0; x < length; x++){
    //             printf("%lf, ", output[x + length * y]);
    //         }
    //         printf("\n");
    //     }
    // }
}


// GPU Optimized function
void GPU_array_process(double *input, double *output, int length, int iterations)
{
    //Cuda events for calculating elapsed time
    cudaEvent_t cpy_H2D_start, cpy_H2D_end, comp_start, comp_end, cpy_D2H_start, cpy_D2H_end;
    cudaEventCreate(&cpy_H2D_start);
    cudaEventCreate(&cpy_H2D_end);
    cudaEventCreate(&cpy_D2H_start);
    cudaEventCreate(&cpy_D2H_end);
    cudaEventCreate(&comp_start);
    cudaEventCreate(&comp_end);

    /* Preprocessing goes here */

    double* gpu_input;
    double* gpu_output;
    // malloc on gpu
    cudaMalloc( (void**)&gpu_input, sizeof(double) * length * length);
    cudaMalloc( (void**)&gpu_output, sizeof(double) * length* length);

    cudaEventRecord(cpy_H2D_start);
    /* Copying array from host to device goes here */
    // copy data input
    cudaMemcpy(
        gpu_input,                  /* DEST */
        input,                      /* SRC */
        sizeof(double) * length * length,    /* NBYTES */
        cudaMemcpyHostToDevice      /* DIRECTION */
    );
    
    // copy data output
    // not sure if needed
    cudaMemcpy(
        gpu_output,                 /* DEST */
        output,                     /* SRC */
        sizeof(double) * length * length,    /* NBYTES */
        cudaMemcpyHostToDevice      /* DIRECTION */
    );

    cudaEventRecord(cpy_H2D_end);
    cudaEventSynchronize(cpy_H2D_end);

    cudaEventRecord(comp_start);

    /* GPU calculation goes here */
    int thrsPerBlock = 8; 
    int nBlks = ceil((double)(length -2)/thrsPerBlock);

    dim3 thrsPerBlockDim(thrsPerBlock, thrsPerBlock);
    dim3 nBlksDim(nBlks, nBlks);

    for(int n=0; n<iterations; n++)
    {
        one_if<<<nBlksDim, thrsPerBlockDim>>>(gpu_input, gpu_output, length, iterations);

        cudaDeviceSynchronize();
        
        double *temp;
        temp = gpu_input;
        gpu_input = gpu_output;
        gpu_output = temp;
    }
    
    // swap back
    double *temp;
    temp = gpu_input;
    gpu_input = gpu_output;
    gpu_output = temp;

    cudaEventRecord(comp_end);
    cudaEventSynchronize(comp_end);

    cudaEventRecord(cpy_D2H_start);
    /* Copying array from device to host goes here */
    
    // copy output back
    // not sure if needed
    cudaMemcpy(
        output,                     /* DEST */
        gpu_output,                 /* SRC */
        sizeof(double) * length * length,    /* NBYTES */
        cudaMemcpyDeviceToHost      /* DIRECTION */
    );

    cudaEventRecord(cpy_D2H_end);
    cudaEventSynchronize(cpy_D2H_end);

    /* Postprocessing goes here */

    // free gpu_input and gpu_output
    // should cudaFreeArray() be used?
    cudaFree(gpu_input);
    cudaFree(gpu_output);


    float time;
    cudaEventElapsedTime(&time, cpy_H2D_start, cpy_H2D_end);
    cout<<"Host to Device MemCpy takes "<<setprecision(4)<<time/1000<<"s"<<endl;

    cudaEventElapsedTime(&time, comp_start, comp_end);
    cout<<"Computation takes "<<setprecision(4)<<time/1000<<"s"<<endl;

    cudaEventElapsedTime(&time, cpy_D2H_start, cpy_D2H_end);
    cout<<"Device to Host MemCpy takes "<<setprecision(4)<<time/1000<<"s"<<endl;
}