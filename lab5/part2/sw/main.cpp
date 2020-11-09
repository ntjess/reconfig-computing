// Greg Stitt
// University of Florida
// main.cpp
//
// Description: This file is the software portion of the simple pipeline 
// application implemented on the FPGA.

#include <iostream>
#include <cstdlib>
#include <cassert>
#include <cstring>
#include <cstdio>
#include <cmath>

#include <unistd.h>

#include "Board.h"
#include "Timer.h"

using namespace std;

#define DEBUG

#define NUM_TESTS 1000
#define ADDR_WIDTH 15
#define MAX_SIZE (1<<ADDR_WIDTH)
#define MEM_IN_ADDR 0
#define MEM_OUT_ADDR 0
#define GO_ADDR ((1<<MMAP_ADDR_WIDTH)-3)
#define SIZE_ADDR ((1<<MMAP_ADDR_WIDTH)-2)
#define DONE_ADDR ((1<<MMAP_ADDR_WIDTH)-1)

void sw(unsigned int *input, unsigned int *output, unsigned int size) {
  
  unsigned int i;

  for (i=0; i < size; i++) {

      unsigned int in1, in2, in3, in4;
      in1 = (input[i] >> 24) & 0xff;
      in2 = (input[i] >> 16) & 0xff;
      in3 = (input[i] >> 8) & 0xff;
      in4 = (input[i]) & 0xff;

      output[i] = in1*in2 + in3*in4;
  }
}


int main(int argc, char* argv[]) {
  
  if (argc != 2) {
    cerr << "Usage: " << argv[0] << " bitfile" << endl;
    return -1;
  }

  // setup clock frequencies
  vector<float> clocks(Board::NUM_FPGA_CLOCKS);
  clocks[0] = 133.0;
  clocks[1] = 40.0;
  clocks[2] = 0.0;
  clocks[3] = 0.0;
  
  // initialize board
  Board *board;
  try {
    board = new Board(argv[1], clocks);
  }
  catch(...) {
    exit(-1);
  }

  unsigned go, done;    
  unsigned size = MAX_SIZE;
  unsigned *input;
  unsigned *swOutput;
  unsigned *hwOutput;
  unsigned long long diff = 0;
  Timer totalTime;

  input = new unsigned[size];
  hwOutput = new unsigned[size];
  swOutput = new unsigned[size];
  
  for (unsigned i=0; i < size; i++) {
    
    input[i] = ((i*4) & 0xff) << 24 |
      ((i*4+1) & 0xff) << 16 |
      ((i*4+2) & 0xff) << 8 |
      ((i*4+3) & 0xff);
    
    swOutput[i] = 0;
    hwOutput[i] = 0;
  }
    
  sw(input,swOutput,size);

  totalTime.start();
  board->write(&size, SIZE_ADDR, 1);  
  board->write(input, MEM_IN_ADDR, size);

  for (unsigned i=0; i < NUM_TESTS; i++) {
    
    printf("Test %d...\n", i);
    fflush(stdout);
    
    go = 1;
    board->write(&go, GO_ADDR, 1);
    
    done = 0;
    while (!done) {
      board->read(&done, DONE_ADDR, 1);
      
#ifdef DEBUG
      usleep(100);
#endif
    }
    
    board->read(hwOutput, MEM_OUT_ADDR, size);
    
    for (unsigned j=0; j < size; j++) {
      
      diff += abs((int) hwOutput[j]- (int) swOutput[j]);
    }
  }
  
  totalTime.stop();

  printf("Avg difference: %f\n", (float) (diff/(float) NUM_TESTS));  
  printf("Total time: %f seconds\n", totalTime.elapsedTime());
    
  delete[] input;
  delete[] hwOutput;
  delete[] swOutput;
  delete board;
  return 0;
}
