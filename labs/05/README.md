# COL215 – Digital Logic and System Design

**Lab 7: Debouncing and the Mealy glitch**

---

## 1. Introduction

In this lab you will clock an FSM by hand: **one press of BTNC = one clock
edge**. This brings up two problems you cannot see in a simulation with a
clean clock:

1. **Bouncing.** A push button does not go cleanly from 0 to 1. For a few
   milliseconds its metal contacts bounce, so the FPGA sees many 0 → 1 changes
   for one press. Each one is a clock edge.
2. **The Mealy glitch.** A Mealy output depends on the state **and on the
   input**. When the input changes between clock edges, the output changes
   too, even though the FSM did not move.

The FSM is the Mealy **zero detector** from Mano (Fig. 5.15/5.16). It sets
`y_out = 1` when it sees a `0` right after one or more `1`s (`1 0`,
`1 1 0`, `1 1 1 0`, ... all count).

| State | `x_in = 0`: next / `y_out` | `x_in = 1`: next / `y_out` |
|:-----:|:--------------------------:|:--------------------------:|
| `S0`  |         `S0` / 0           |         `S1` / 0           |
| `S1`  |         `S0` / **1**       |         `S3` / 0           |
| `S2`  |         `S0` / **1**       |         `S2` / 0           |
| `S3`  |         `S0` / **1**       |         `S2` / 0           |

So in `S1`, `S2` and `S3`, `y_out = ~x_in`.

---

## 2. The board

| Input / Output | Meaning                                                    |
|----------------|------------------------------------------------------------|
| BTNC           | the FSM clock: one press = one rising edge                  |
| SW0            | `x_in`                                                     |
| SW1            | reset, active low: **down = reset**, up = run              |
| LD0            | `y_out`                                                    |
| LD12–LD15      | one LED per state: LD12=`S0`, LD13=`S1`, LD14=`S2`, LD15=`S3` |
| 7-segment      | number of presses of BTNC that the FPGA saw (cleared by reset) |

The 7-segment counter runs on the 100 MHz clock and counts every 0 → 1
change of the button signal it is given. It shows exactly how many clock
edges the FSM received.

### Provided files

| File                       | Status     | Description                                      |
|----------------------------|------------|--------------------------------------------------|
| `debounce.v`               | **TODO 1a** | Button debouncer                             |
| `mealy_top.v`              | **TODO 1b** | Board wrapper: FSM, LEDs, press counter      |
| `mealy_fsm.v`              | **TODO 2**     | Mealy zero detector (`Mealy_Zero_Detector`)  |
| `press_display.v`          | Given      | Press counter on the 7-segment display           |
| `ssd.v`                    | Given      | 7-segment decoder                                |
| `mealy_zero_detector.xdc`  | Given      | Basys3 constraints                               |
| `tb_debounce.v`            | Given      | Self-checking testbench for `debounce`           |
| `tb_mealy.v`               | Given      | Testbench for `Mealy_Zero_Detector` (Mano)       |

Do not change module names or port lists.

Make a Vivado project for the Basys3 (`xc7a35tcpg236-1`) with `mealy_top.v`,
`mealy_fsm.v`, `debounce.v`, `press_display.v` and `ssd.v` as design sources,
`mealy_zero_detector.xdc` as the constraint file, and `tb_debounce.v` and
`tb_mealy.v` as simulation sources. `mealy_top` is the top module.

---

## 3. Part 1: Debouncing

### 3.1 See the bouncing

In the given `mealy_top.v` the debouncer is commented out, and BTNC goes
**straight** to the FSM clock and to the press counter.

> Vivado will give a critical warning that `db/clean_reg/Q` is not found.
> That is expected: the debouncer `db` does not exist yet. Ignore it for now.

1. Generate the bitstream and program the board.
2. SW1 down, then up (reset). The display shows `0`.
3. Press and release BTNC **once**, slowly. Look at the display.
4. Do it 20 times, one press at a time. Write down the count after each
   press.
5. Set SW0 up, reset, and press BTNC once. Look at LD12–LD15. With `x_in = 1`
   one edge should take the FSM from `S0` to `S1`. Where did it end up?

You should see that the counter often goes up by more than 1 for a single
press, and sometimes also when you **release** the button. Each extra count
is an extra clock edge for the FSM, so the FSM skips states.

**Record:** after 20 presses, what count did you get? Which presses jumped
the most: fast taps, slow presses, or presses that were held down?

### 3.2 TODO 1: write the debouncer

A bounce lasts at most a few milliseconds. The debouncer keeps a counter
that goes **up while the button reads 1** and **down while it reads 0**. Short
bounces only move the counter a little; the output only changes when the
counter has gone far in one direction.

```verilog
module debounce #(
    parameter THRESHOLD = 100_000,    // 1 ms at 100 MHz
    parameter MAX       = 2**21 - 1   // about 21 ms at 100 MHz
)(
    input      clk,
    input      noisy,   // the button
    output reg clean = 1'b0
);
```

The two flip-flops `s0` and `s1` are given: they bring the button into the
`clk` domain. Use only `s1`.

**TODO 1a (`debounce.v`).** On every rising edge of `clk`:

- If `s1` is 1, add 1 to `count`, but stop at `MAX`.
- If `s1` is 0, subtract 1 from `count`, but stop at 0.
- Set `clean` to 1 if `count` is greater than `THRESHOLD`, and to 0
  otherwise.

```mermaid
flowchart TD
    noisy([noisy: the button]) --> sync["s0 &lt;= noisy<br/>s1 &lt;= s0"]
    sync --> pressed{"s1 == 1 ?"}
    pressed -- "yes: pressed" --> top{"count == MAX ?"}
    top -- no --> inc["count &lt;= count + 1"]
    top -- yes --> keep1["count stays"]
    pressed -- "no: released" --> bottom{"count == 0 ?"}
    bottom -- no --> dec["count &lt;= count - 1"]
    bottom -- yes --> keep0["count stays"]
    inc & keep1 & dec & keep0 --> cmp{"count &gt; THRESHOLD ?"}
    cmp -- yes --> one["clean &lt;= 1"]
    cmp -- no --> zero["clean &lt;= 0"]
```

So a press shows up after about 1 ms. Once the button has been held for
20 ms, `count` is at `MAX`, and the button must be released for about 20 ms
before `clean` goes back to 0. A short drop while the button is held is
ignored.

Delete the placeholder line.

**TODO 1b (`mealy_top.v`).**

- Uncomment the `debounce db (...)` instance. Keep the instance name `db`:
  the XDC file refers to it.
- Use the debounced signal `step` instead of `btnC` for the FSM
  `.clock(...)` and for the counter's `.press(...)`.

### 3.3 Test

1. **Simulate** `tb_debounce.v` (*Set as Top*, *Run Behavioral Simulation*).
   It sets `THRESHOLD` to 5 and `MAX` to 20 so the test is short. It checks
   that short pulses are ignored, that a bouncy press and a bouncy release
   each change `clean` exactly once and in time, and that a short drop while
   the button is held is ignored:

   ```
   Test 1: short pulses ignored
   Test 2: one press, clean went to 1 once
   Test 3: clean stays 1 while held
   Test 4: short drop while held ignored
   Test 5: one release, clean went to 0 once
   tb_debounce: ALL TESTS PASSED
   ```

   Do not go to the board until it passes.

2. **Run on the board.** Program the board and repeat steps 2–5 of 3.1.

   - The counter now goes up by **exactly 1** per press, no matter how you
     press.
   - Releasing the button does not count.
   - With SW0 up, one press takes the FSM from `S0` to `S1` (LD13).

**Record:** your count after 20 presses.

---

## 4. Part 2: The Mealy glitch

From now on keep the debouncer from Part 1. The clock is clean, so anything
odd you see now comes from the FSM itself.

### 4.1 See the glitch in simulation

1. Set `t_Mealy_Zero_Detector` (in `tb_mealy.v`) as the simulation top and
   run a behavioral simulation. Add `M0/state` to the waveform.
2. Zoom in on **40 ns to 60 ns**. The clock has rising edges at 45 and 55 ns.
   The testbench changes `x_in` at 50, **52** and **54** ns, all **between**
   these two edges.

You should see:

```
 time (ns)          45                  50      52      54  55
 clock      ________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\___________________/‾‾‾‾‾‾‾‾
 x_in       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\_______/‾‾‾‾‾‾‾\____________
 state        S0    │ S1                                    │ S0
 y_out      ____________________________/‾‾‾‾‾‾‾\_______/‾‾‾\________
```

The state stays `S1` from 45 to 55 ns, but `y_out` goes 1, 0, 1. Only the value
of `y_out` at the rising edge at 55 ns means anything. The pulse from 50 to
52 ns and the drop from 52 to 54 ns are **glitches**: they come straight from
`x_in` through the output logic, with no clock edge.

### 4.2 See the glitch on the board

1. SW1 down, then up (reset). LD12 (`S0`) is on.
2. SW0 up, press BTNC once. The FSM is in `S1` (LD13). LD0 is off.
3. **Do not press BTNC.** Flip SW0 down. Then up, then down again.

LD0 turns on and off with SW0, while the state LEDs and the press counter do
not move. The FSM received no clock edge, yet its output said "zero
detected" twice. Anything that watched LD0 (another circuit, a counter)
would believe it.

### 4.3 TODO 2: remove the glitch

Change `mealy_fsm.v` so that `y_out` can no longer follow `x_in` between
clock edges. Keep it a Mealy machine: `y_out` must still depend on the state
and on the input.

Hint: the problem is that `x_in` can change at **any** time. Make a
registered copy of `x_in` that only changes on the **inactive (falling)
edge** of `clock`, and use that copy instead of `x_in` in both the
next-state logic and the output logic.

### 4.4 Test

1. **Simulate** `tb_mealy.v` again. Between 50 and 55 ns, `y_out` must now
   stay at 1: the short changes of `x_in` at 52 and 54 ns are gone.
   Check that `y_out` only ever changes at a clock edge (rising or falling).

   ```
    time (ns)          45                  50      52      54  55
    clock      ________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\___________________/‾‾‾‾‾‾‾‾
    x_in       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\_______/‾‾‾‾‾‾‾\____________
    x_sync     ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\____________________________
    state        S0    │ S1                                    │ S0
    y_out      ____________________________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\________
   ```

   `x_sync` (in `M0`) only changes on the falling edge at 50 ns, so the
   changes of `x_in` at 52 and 54 ns never reach `y_out`.

2. **Run on the board.** Repeat 4.2. Flipping SW0 alone no longer changes
   LD0. LD0 changes only when you **release** BTNC (the falling edge of the
   clock).

---

## 5. Summary

| Problem       | Cause                                         | Fix                                          |
|---------------|-----------------------------------------------|----------------------------------------------|
| Bouncing      | button contacts bounce for a few ms           | count up while pressed, down while released; change only past a threshold |
| Mealy glitch  | `y_out` is combinational in `x_in`            | let the input change only at the inactive clock edge |

---

### Questions

Work through these on paper. Be ready to explain your answers.

1. Why does the counter sometimes go up when you **release** the button
   without the debouncer?
2. What goes wrong if `THRESHOLD` is 100 (1 µs)? What goes wrong if `MAX`
   is 100 000 000 (1 s)?
3. Why do we pass the button through two flip-flops before using it? What
   could happen if `noisy` went straight into the counter logic?
4. Without the debouncer, with SW0 up, one press sometimes took the FSM from
   `S0` to `S2`. How many edges did it get? Use the state table.
5. After your fix in TODO 2, on the board, which value of SW0 does a press
   use: the one when you press, or the one when you last released? Is this a
   problem? How would you set SW0 to feed the bits `1 1 0` to the FSM?
6. The switches bounce too. Did SW0 bouncing cause any problem in this lab?
   Would it if `x_in` were a clock?
7. Another way to remove the glitch is a flip-flop on the output:
   `always @(posedge clock) y_reg <= y_out;`. Compare it with your fix. When
   does `y_reg` show a detection, compared with `y_out`?
