// Greg Stitt
// University of Florida
// main.cpp
//
// Description: This file is intended as a tutorial for the 5721/4720 ZedBoard
// cluster. It demonstrates how to read and write from an AXI peripheral.

#include <iostream>
#include <cstdlib>

#include "Board.h"

using namespace std;

// AXI addresses for the input and output
#define IN_ADDR 0
#define OUT_ADDR 1

#define TEST_SIZE 10000
//#define DEBUG

int main(int argc, char* argv[]) {

  if (argc != 2) {
    cerr << "Usage: " << argv[0] << " bitfile" << endl;
    return -1;
  }

  // initialize board
  Board *board;
  try {
    board = new Board(argv[1]);
  }
  catch(...) {
    exit(-1);
  }

  unsigned short in0[TEST_SIZE];
  unsigned short in1[TEST_SIZE];
  unsigned int packedIn[TEST_SIZE];
  unsigned int out[TEST_SIZE];
  unsigned int correctOut;

  // create inputs to test
  for (unsigned i=0; i < TEST_SIZE; i++) {

    // use random inputs 
    in0[i] = rand();
    in1[i] = rand();

    // concatenate two 16-bit inputs into one 32-bit input
    // by shifting in0 left by 16 bits and the oring in1
    packedIn[i] = (in0[i] << (sizeof(unsigned short)*8)) | in1[i];

    // initialize output to 0 to see if board is generating anything
    out[i] = 0;
  }
  
  // run a set of tests
  for (unsigned i=0; i < TEST_SIZE; i++) {


    // bool Board::write(unsigned int *data, unsigned long addr, unsigned long words);
    // 
    // Parameters:
    // -------------------------------------
    // data: pointer to the data to write to the board
    // addr: starting address for the write on the AXI peripheral 
    // words: the number of 32-bit words to write
    //
    // Returns true if successful, false otherwise 

    // write input i to the board at address IN_ADDR (slv_reg0)
    board->write(&packedIn[i], IN_ADDR, 1);

    // bool Board::read(unsigned int *data, unsigned long addr, unsigned long words);
    // 
    // Parameters:
    // -------------------------------------
    // data: pointer to memory location to store the data read from the board
    // addr: starting address for the read on the AXI peripheral 
    // words: the number of 32-bit words to read
    //
    // Returns true if successful, false otherwise 

    // read output from board at address OUT_ADDR (multiplier output)
    board->read(&out[i], OUT_ADDR, 1);

    // calculate the correct output
    correctOut = in0[i] * in1[i];

    // check if board output is incorrect
    if (correctOut != out[i]) {
      cerr << "Error: Board output for " << in0[i] << "*" << in1[i] << " is " << out[i] << " instead of " << correctOut << endl;
      return -1;
    }
  }

  cout << "Application completed successfully!" << endl;
  return 1;
}
