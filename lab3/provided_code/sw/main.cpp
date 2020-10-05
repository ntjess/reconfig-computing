// Greg Stitt
// University of Florida
// main.cpp
//

#include <iostream>
#include <cstdlib>
#include <cassert>
#include <cstring>
#include <cstdio>
#include <vector>

#include "Board.h"

using namespace std;

#define TEST_SIZE 10000
//#define DEBUG


int main(int argc, char* argv[]) {
  
  if (argc != 2) {
    cerr << "Usage: " << argv[0] << " bitfile" << endl;
    return -1;
  }
  
  vector<float> clocks(Board::NUM_FPGA_CLOCKS);
  clocks[0] = 100.0;
  clocks[1] = 100.0;
  clocks[2] = 100.0;
  clocks[3] = 100.0;
  
  cout << "Programming FPGA...." << endl;

  // initialize board
  Board *board;
  try {
    board = new Board(argv[1], clocks);
  }
  catch(...) {
    exit(-1);
  }

  
  
  return 1;
}
