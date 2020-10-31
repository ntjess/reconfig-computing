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

#include "Board.h"
#include "Timer.h"

using namespace std;

// DON'T CHANGE WITHOUT ALSO CHANGING VHDL TO MATCH
#define ADDR_WIDTH 15
#define MAX_SIZE 100//(1<<ADDR_WIDTH)
#define MEM_IN_ADDR 0
#define MEM_OUT_ADDR 0
#define GO_ADDR ((1<<MMAP_ADDR_WIDTH)-3)
#define SIZE_ADDR ((1<<MMAP_ADDR_WIDTH)-2)
#define DONE_ADDR ((1<<MMAP_ADDR_WIDTH)-1)

#define MAX_TIMEOUT   2000000
#define PRINT_TIMEOUT 1


// software implementation of the code implemented on the FPGA
void sw(unsigned *input, unsigned *output, unsigned size) {
  
  unsigned i;

  for (i=0; i < size; i++) {

      unsigned in1, in2, in3, in4;
      in1 = (input[i] >> 24) & 0xff;
      in2 = (input[i] >> 16) & 0xff;
      in3 = (input[i] >> 8) & 0xff;
      in4 = (input[i]) & 0xff;

      output[i] = in1*in2 + in3*in4;
  }
}

uint waitWhile(unsigned int cmp, uint addr, Board *board) {
  uint timeoutCnt = 0;
  uint readVal = cmp;
  while (readVal == cmp && timeoutCnt < MAX_TIMEOUT) {
    board->read(&readVal, addr, 1);
    timeoutCnt++;
  }
  if (timeoutCnt == MAX_TIMEOUT && PRINT_TIMEOUT) {
    cout << "Timeout error! (timeout = " << timeoutCnt << ")" << endl << flush;
  }
  return timeoutCnt;
}


int main(int argc, char* argv[]) {
  
  if (argc != 2) {
    cerr << "Usage: " << argv[0] << " bitfile" << endl;
    return -1;
  }

  // setup clock frequencies
  vector<float> clocks(Board::NUM_FPGA_CLOCKS);
  clocks[0] = 100.0;
  clocks[1] = 0.0;
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

  if (PRINT_TIMEOUT) {
    cout << "Initialized board..." << endl;
  }
  // change to test smaller amounts
  unsigned size = MAX_SIZE;

  unsigned go, done;
  unsigned *input, *swOutput, *hwOutput;
  Timer swTime, hwTime, readTime, writeTime, waitTime;

  input = new unsigned[size];
  hwOutput = new unsigned[size];
  swOutput = new unsigned[size];
  assert(input != NULL);
  assert(swOutput != NULL);
  assert(hwOutput != NULL);
  // initialize input and output arrays
  for (unsigned i=0; i < size; i++) {

    // pack 4 8-bit inputs into one 32-bit word
    input[i] = ((i*4) & 0xff) << 24 |
      ((i*4+1) & 0xff) << 16 |
      ((i*4+2) & 0xff) << 8 |
      ((i*4+3) & 0xff);

    swOutput[i] = 0;
    hwOutput[i] = 0;
  }
  if (PRINT_TIMEOUT) {
    cout << "Inputs Initialized..." << endl;
  }
  // transfer input array and size to FPGA
  hwTime.start();
  writeTime.start();
  board->write(input, MEM_IN_ADDR, size);
  board->write(&size, SIZE_ADDR, 1);
  writeTime.stop();

  // assert go. Note that the memory map automatically sets go back to 1 to 
  // avoid an additional transfer.
  if (PRINT_TIMEOUT) {
    cout << "About to go..." << endl;
  }
  go = 1;
  board->write(&go, GO_ADDR, 1);
    
  // wait for the board to assert done
  waitTime.start();
  done = 0;
  cout << "waiting for done..." << endl;
  // return 0;
  waitWhile(0, DONE_ADDR, board);
  // while (!done) {
  //   board->read(&done, DONE_ADDR, 1);
  // }
  waitTime.stop();

  // read the outputs back from the FPGA
  readTime.start();
  board->read(hwOutput, MEM_OUT_ADDR, size);
  readTime.stop();
  hwTime.stop();

  // execute the same code in software
  swTime.start();
  sw(input, swOutput, size);
  swTime.stop();

  printf("Results:\n");
  for (unsigned i=0; i < size; i++) {
    printf("%d: HW = %d, SW = %d\n", i, hwOutput[i], swOutput[i]);
  }

  // calculate speedup
  double transferTime = writeTime.elapsedTime() + readTime.elapsedTime();
  double hwTimeNoTransfer = hwTime.elapsedTime() - transferTime;
  cout << "Speedup: " << swTime.elapsedTime()/hwTime.elapsedTime() << endl;
  cout << "Speedup (no transfers): " << swTime.elapsedTime()/hwTimeNoTransfer << endl;

  delete input;
  delete hwOutput;
  delete swOutput;
  return 0;
}
