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

#define MAX_TIMEOUT   2000

unsigned int calcFib(int n) {
  if (n == 0) return 0;
  else if (n == 1) return 1;
  else return calcFib(n-1) + calcFib(n-2);
}

uint waitWhile(unsigned int cmp, uint addr, Board *board) {
  uint timeoutCnt = 0;
  uint readVal = cmp;
  while (readVal == cmp && timeoutCnt < MAX_TIMEOUT) {
    board->read(&readVal, addr, 1);
    timeoutCnt++;
  }
  if (timeoutCnt == MAX_TIMEOUT) {
    cout << "Timeout error! (timeout = " << timeoutCnt << ")" << endl << flush;
  }
  return timeoutCnt;
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
  uint waitCnt = 0;
  for (unsigned ii = 1; ii <= 30; ii++) {
    board->write(&ii, C_N_ADDR, 1);
    go = 1;
    board->write(&go, C_GO_ADDR, 1);
    waitWhile(0, C_DONE_ADDR, board);

    board->read(&result, C_RESULT_ADDR, 1);
    waitCnt = waitWhile(1, C_GO_ADDR, board);
    if (waitCnt == MAX_TIMEOUT) {
      // Device failed to update 'go' on its own
      go = 0;
      board->write(&go, C_GO_ADDR, 1);
    }
    waitWhile(1, C_DONE_ADDR, board);

    cout << ii << ": HW = " << result << ", SW = " << calcFib(ii) << endl;
  }
  
  return 1;
}
