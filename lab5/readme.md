# Lab 5 - Cross-Domain Clock Signals

_Lab members: Nathan Jessurun, Tanjid Rahman_

## Part 1

The provided code initially would not run without timing errors, as noted in the included screenshot:

![](./part1/part1_incorrect.png)

However, after adding a simple dual-flop synchronizer to the pulse train, this issue was resolved.

## Part 2

The provided code for part 2 never gave us any timing errors. I.e. there was an average error of `0` even without any changes to the handshake files. However, a closer look at `handshake.vhd` showed the `send_s` and `ack_s` signals were not properly synchronized between the two clock domains. So, we added the appropriate dual flop synchronizers similar to part 1 on both signals:

```vhdl
U_SEND_S_DELAY : entity work.delay
    generic map (
        cycles => 2,
        width  => 1,
        init => "0")
    port map (
        clk       => clk_dest,
        rst       => rst,
        en        => '1',
        input(0)  => send_s,
        output(0) => send_s_delayed);
        
U_ACK_S_DELAY : entity work.delay
    generic map (
        cycles => 2,
        width  => 1,
        init => "0")
    port map (
        clk       => clk_src,
        rst       => rst,
        en        => '1',
        input(0)  => ack_s,
        output(0) => ack_s_delayed);
  
```

This way, the `send` and `ack` signals are properly synchronized when read from either the `ack` or `send` processes, respectively.



## Part 3

Per lab instructions, we added IP cores for both the 32-bit input and 17-bit output FIFOs. After minor modification to the `user_app` vhdl file, the code synthesized and ran with no errors in software.