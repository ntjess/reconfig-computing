# Lab 2: Uploading Logic to Zynq Processors

## Group members: Nathan Jessurun, Mir Rahman (Tanjid)

Per extra credit requirements, the test bench checks all possible combinations for 4-bit inputs.

However, instead of using 4 drivers (one for each input), only 2 drivers are used (one for input 0/1, the other for input 2/3). This is because only two inputs interact with each other within the circuit, so just two drivers are sufficient to exhaustively evaluate the synthesized circuit.