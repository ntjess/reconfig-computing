// Greg Stitt
// University of Florida
// main.cpp
//
// Description: This file is intended as a tutorial for the 5721/4720 ZedBoard
// cluster. It demonstrates how to read and write from an AXI peripheral.

#include <iostream>
#include <cstdlib>
#include <cassert>
#include <cstring>

#include "Board.h"

using namespace std;

// AXI addresses for the input and output
#define IN_ADDR 0
#define OUT_ADDR 1

#define TEST_SIZE 10000
//#define DEBUG

enum addresses {
  IN0_ADDR=0,
  IN1_ADDR,
  IN2_ADDR,
  IN3_ADDR,
  OUT0_ADDR,
  OUT1_ADDR,
  OUT2_ADDR,
  OUT3_ADDR
};

int main(int argc, char* argv[]) {

  // arrays for Board I/O
  unsigned in0[TEST_SIZE];
  unsigned in1[TEST_SIZE];
  unsigned in2[TEST_SIZE];
  unsigned in3[TEST_SIZE];
  unsigned out0[TEST_SIZE];
  unsigned out1[TEST_SIZE];
  unsigned out2[TEST_SIZE];
  unsigned out3[TEST_SIZE];

  // make sure unsigned is 4 bytes on this machine
  assert(sizeof(unsigned) == 4);

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

  // create inputs to test
  for (unsigned i=0; i < TEST_SIZE; i++) {

    // use random inputs 
    in0[i] = rand();
    in1[i] = rand();
    in2[i] = rand();
    in3[i] = rand();
  }
  
  // initialize all outputs to be 0 to make sure Board is doing something
  memset(out0, 0, sizeof(unsigned)*TEST_SIZE);
  memset(out1, 0, sizeof(unsigned)*TEST_SIZE);
  memset(out2, 0, sizeof(unsigned)*TEST_SIZE);
  memset(out3, 0, sizeof(unsigned)*TEST_SIZE);

  // run a set of tests
  for (unsigned i=0; i < TEST_SIZE; i++) {

    // write inputs to the board
    board->write(&in0[i], IN0_ADDR, 1);
    board->write(&in1[i], IN1_ADDR, 1);
    board->write(&in2[i], IN2_ADDR, 1);
    board->write(&in3[i], IN3_ADDR, 1);
    
    // read outputs from the board
    board->read(&out0[i], OUT0_ADDR, 1);
    board->read(&out1[i], OUT1_ADDR, 1);
    board->read(&out2[i], OUT2_ADDR, 1);
    board->read(&out3[i], OUT3_ADDR, 1);
  }
    
  unsigned out0Errors=0, out1Errors=0, out2Errors=0, out3Errors=0, totalErrors=0;

  // check for errors
  for (unsigned i=0; i < TEST_SIZE; i++) {

    if (out0[i] != in0[i]*in1[i]) out0Errors ++;
    if (out1[i] != in0[i]+in1[i]) out1Errors ++;
    if (out2[i] != in2[i] - in3[i]) out2Errors ++;
  
  }

  totalErrors = out0Errors + out1Errors + out2Errors + out3Errors;

  cout << "Out0 Errors: " << out0Errors << endl;
  cout << "Out1 Errors: " << out1Errors << endl;
  cout << "Out2 Errors: " << out2Errors << endl;
  cout << "Out3 Errors: " << out3Errors << endl;
  cout << "Total Errors: " << totalErrors << endl;
  
  if (totalErrors == 0)
    cout << "Application completed successfully!" << endl;

  return 1;
}