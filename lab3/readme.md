# Lab 3: Fibonacci on Zynq Processors

## Group members: Nathan Jessurun, Mir Rahman (Tanjid)


## Extra credit: Clear `Go` in hardware instead of software
The provided code in `main.cpp` does not set `go` to 0 inside the testing loop. Instead,
`memory_map.vhd` always assigns `go='0'` unless `go` is explicitly being written to by the user.
So, the extra credit requirement of clearing `go` in hardware has been achieved.