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
#include <climits>

#include "Board.h"

using namespace std;

#define TEST_SIZE 10000
//#define DEBUG
#define C_GO_ADDR     0
#define C_N_ADDR      1
#define C_RESULT_ADDR 2
#define C_DONE_ADDR   3

unsigned int calcFib(int n) {
  if (n == 0) return 0;
  else if (n == 1) return 1;
  else return calcFib(n-1) + calcFib(n-2);
}

void waitWhile(unsigned int doneCmp, Board *board, unsigned int iterNum) {
  unsigned int timeoutCnt = 0, done = 0;
  while (done == doneCmp && timeoutCnt < UINT_MAX) {
    board->read(&done, C_DONE_ADDR, 1);
    timeoutCnt++;
  }
  if (timeoutCnt == UINT_MAX) {
    cout << "Timeout error! (iteration " << iterNum << ")" << endl;
  }
}

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
  
  //cout << "Programming FPGA...." << endl;

  // initialize board
  Board *board;
  try {
    board = new Board(argv[1], clocks);
  }
  catch(...) {
    exit(-1);
  }

  unsigned int go = 0, result = 0;
  board->write(&go, C_GO_ADDR, 1);

  for (unsigned ii = 1; ii <= 30; ii++) {
    board->write(&ii, C_N_ADDR, 1);
    go = 1;
    board->write(&go, C_GO_ADDR, 1);
    waitWhile(0, board, ii);

    board->read(&result, C_RESULT_ADDR, 1);
    go = 0;
    board->write(&go, C_GO_ADDR, 1);

    cout << ii << ": HW = " << result << ", SW = " << calcFib(ii) << endl;

    waitWhile(1, board, ii);
  }
  
  return 1;
}
