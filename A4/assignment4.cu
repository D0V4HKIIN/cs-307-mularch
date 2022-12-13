/*
 ============================================================================
 Filename    : assignment4.c
 Author      : Arash Pourhabibi
 ============================================================================
 */

#include <iostream>
#include <iomanip>
#include <fstream>
#include <sys/time.h>
#include <cuda_runtime.h>
using namespace std;
#include "utility.h"

void array_process(double *input, double *output, int length, int iterations);
void GPU_array_process(double *input, double *output, int length, int iterations);

int main (int argc, const char *argv[]) {

    int length, iterations;

    if (argc != 3) {
		cout<<"Invalid input!"<<endl<<"Usage: ./assignment4 <length> <iterations>"<<endl;
		return 1;
	} else {
        length      = atoi(argv[1]);
        iterations  = atoi(argv[2]);
        if(length%2!=0)
        {
            cout<<"Invalid input!"<<endl<<"Array length must be even"<<endl;
            return 1;
        }
	}


    //Allocate arrays
    double *input   = new double[length*length];
    double *output  = new double[length*length];

    //Reset Device
    cudaDeviceReset();

    //Initialize the arrays
    init(input, length);
    init(output, length);

    //Start timer
    set_clock();

    /*Use either the CPU or the GPU functions*/

    //CPU Baseline
    //Uncomment the block to use the baseline
    array_process(input, output, length, iterations);
    if(iterations%2==0)
    {
        double *temp;
        temp = input;
        input = output;
        output = temp;
    }

    //Stop timer
    double cpu_time = elapsed_time();


    //Save array in file
    save(output, length, "cpu_output.csv");

    //Initialize the arrays
    init(input, length);
    init(output, length);

    double gpu_start = elapsed_time();

    //GPU function
    GPU_array_process(input, output,  length, iterations);

    double gpu_time = elapsed_time();

    //Report time required for n iterations
    cout<<"Running the algorithm on "<<length<<" by "<<length<<" array for "<<iterations<<" iteration"<<endl;
    cout << "takes " << setprecision(4) << cpu_time << "s on the cpu" << endl;
    cout << "takes " << setprecision(4) << gpu_time - gpu_start << "s on the gpu" << endl;
    
    //Save array in file
    save(output, length, "gpu_output.csv");

    //Free allocated memory
    delete[] input;
    delete[] output;

    return 0;
}
