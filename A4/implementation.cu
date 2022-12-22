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

__global__ void GPU_process(double *input, double *output, int length, int iterations)
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
        GPU_process<<<nBlksDim, thrsPerBlockDim>>>(gpu_input, gpu_output, length, iterations);

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