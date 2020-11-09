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

#include "Board.h"
#include "Timer.h"

using namespace std;

#define NUM_TESTS 10
#define NUM_ITERATIONS 1000000

enum MMAP {
  GO_ADDR=0, ITERATIONS_ADDR, COUNT_ADDR, DONE_ADDR
};

int main(int argc, char* argv[]) {
  
  if (argc != 2) {
    cerr << "Usage: " << argv[0] << " bitfile" << endl;
    return -1;
  }

  // setup clock frequencies
  vector<float> clocks(Board::NUM_FPGA_CLOCKS);
  clocks[0] = 133.0;
  clocks[1] = 0.0; 
  clocks[2] = 0.0;
  clocks[3] = 75.0; 
  
  // initialize board
  Board *board;
  try {
    board = new Board(argv[1], clocks);
  }
  catch(...) {
    exit(-1);
  }

  unsigned go, done;
  unsigned iterations, count;
  unsigned long long diff = 0;
  
  iterations = NUM_ITERATIONS;
  board->write(&iterations, ITERATIONS_ADDR, 1);

  for (unsigned i=0; i < NUM_TESTS; i++) {
    
    go = 1;
    board->write(&go, GO_ADDR, 1);
    
    done = 0;
    while (!done) {
      board->read(&done, DONE_ADDR, 1);
    }
    
    board->read(&count, COUNT_ADDR, 1);
    diff += abs((int)iterations-(int)count);
  }
  
  printf("Avg difference: %f\n", (float) (diff/(float) NUM_TESTS));  
  delete board;
  return 0;
}
