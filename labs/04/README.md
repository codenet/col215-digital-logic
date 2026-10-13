# COL215 – Digital Logic and System Design

**Lab 4: A 4-bit ALU (non-graded)**

---

## 1. Introduction

An **Arithmetic Logic Unit (ALU)** is the part of a CPU that does the
calculating. In this lab you will build the ALU of the *Hack* computer from
Nisan & Schocken, *The Elements of Computing Systems* (2nd ed.),
section 2.5.2 (pp. 68–72). The book's ALU works on 16-bit numbers; ours
works on **4-bit** numbers, but the design is otherwise identical.

The ALU takes two 4-bit two's complement inputs `x` and `y` and six control
bits. Each control bit switches on one simple operation. Together the six
bits select which function of `x` and `y` the ALU computes:

```
if (zx) x = 0          // zero the x input
if (nx) x = !x         // negate (bit-wise NOT) the x input
if (zy) y = 0          // zero the y input
if (ny) y = !y         // negate (bit-wise NOT) the y input
if (f)  out = x + y    // two's complement addition (overflow ignored)
else    out = x & y    // bit-wise AND
if (no) out = !out     // negate (bit-wise NOT) the output

zr = 1 if out == 0, else 0
ng = 1 if out <  0, else 0
```

These steps happen **in this order**: first the inputs, then `+` or `&`,
then the output. `!` always means bit-wise NOT, not arithmetic negation.

That doesn't look like much, but by choosing the six bits carefully the ALU
computes all 18 functions below (figure 2.5b in the book):

| `zx` | `nx` | `zy` | `ny` | `f` | `no` | `out` |
|:----:|:----:|:----:|:----:|:---:|:----:|:-----:|
|  1   |  0   |  1   |  0   |  1  |  0   |  `0`  |
|  1   |  1   |  1   |  1   |  1  |  1   |  `1`  |
|  1   |  1   |  1   |  0   |  1  |  0   | `-1`  |
|  0   |  0   |  1   |  1   |  0  |  0   |  `x`  |
|  1   |  1   |  0   |  0   |  0  |  0   |  `y`  |
|  0   |  0   |  1   |  1   |  0  |  1   | `!x`  |
|  1   |  1   |  0   |  0   |  0  |  1   | `!y`  |
|  0   |  0   |  1   |  1   |  1  |  1   | `-x`  |
|  1   |  1   |  0   |  0   |  1  |  1   | `-y`  |
|  0   |  1   |  1   |  1   |  1  |  1   | `x+1` |
|  1   |  1   |  0   |  1   |  1  |  1   | `y+1` |
|  0   |  0   |  1   |  1   |  1  |  0   | `x-1` |
|  1   |  1   |  0   |  0   |  1  |  0   | `y-1` |
|  0   |  0   |  0   |  0   |  1  |  0   | `x+y` |
|  0   |  1   |  0   |  0   |  1  |  1   | `x-y` |
|  0   |  0   |  0   |  1   |  1  |  1   | `y-x` |
|  0   |  0   |  0   |  0   |  0  |  0   | `x&y` |
|  0   |  1   |  0   |  1   |  0  |  1   | `x\|y` |

You will build the ALU from small modules:

```
full_adder ─► four_bit_adder ─┐
  (given)        (given)      │
zero_negate ──────────────────┼─►  alu  ─►  top (given)
  (TODO 1)                    │  (TODO 3, 4)
mux2_4 ───────────────────────┘
  (TODO 2)
```

### Block diagram

```
           zx  nx
           │   │
       ┌───▼───▼─────┐ x_pre       ┌────────────────┐ and_out  ┌──────────┐
 x ───►│ zero_negate ├──────┬─────►│      AND       ├─────────►│ a        │
       │   (pre_x)   │      │   ┌─►│                │          │          │          no
       └─────────────┘      │   │  └────────────────┘          │  mux2_4  │ f_out    │
                            │   │                              │(select_f)├────►┌─────▼───────┐
       ┌─────────────┐      │   │  ┌────────────────┐ add_out  │          │     │ zero_negate ├──► out ──► zr, ng
 y ───►│ zero_negate ├──────┼───┴─►│ four_bit_adder ├─────────►│ b        │     │ (post_out)  │
       │   (pre_y)   │ y_pre└─────►│    (adder)     │          │   sel    │     │    z = 0    │
       └───▲───▲─────┘             └────────────────┘          └────▲─────┘     └─────────────┘
           │   │                                                    │
           zy  ny                                                   f
```

The same `zero_negate` module is used three times: for `x`, for `y`, and
for the output (with its zero input tied to `0`).

---

## 2. Provided Files

| File               | Status         | Description                                              |
|--------------------|----------------|----------------------------------------------------------|
| `full_adder.v`     | Given          | 1-bit full adder (Lab 3)                                 |
| `four_bit_adder.v` | Given          | 4-bit ripple-carry adder (Lab 3)                         |
| `zero_negate.v`    | **TODO 1**     | Optionally zero, then optionally negate, a 4-bit value   |
| `mux2_4.v`         | **TODO 2**     | 4-bit 2-to-1 multiplexer                                 |
| `alu.v`            | **TODO 3, 4**  | The ALU datapath and the `zr`, `ng` flags                |
| `ssd.v`            | Given          | 7-segment decoder, now with a minus sign                 |
| `top.v`            | Given          | Connects switches → `alu` → LEDs and 7-segment display   |
| `master.xdc`       | Given          | Basys3 constraints                                       |
| `tb_*.v`           | Given          | Self-checking testbenches, one per module                |


Do not change the module names or port lists. `top.v`, `master.xdc` and the
testbenches depend on them.

### Bit ordering and two's complement

As in Lab 3, all vectors are declared `[0:3]`, so **index 0 is the MSB and
index 3 is the LSB**.

All values are 4-bit **two's complement** numbers, so they range from −8 to
7. Index 0 is the sign bit:

| Bits   | Value | Bits   | Value |
|:------:|:-----:|:------:|:-----:|
| `0000` |   0   | `1000` |  −8   |
| `0001` |   1   | `1001` |  −7   |
| `0010` |   2   | `1010` |  −6   |
| `0011` |   3   | `1011` |  −5   |
| `0100` |   4   | `1100` |  −4   |
| `0101` |   5   | `1101` |  −3   |
| `0110` |   6   | `1110` |  −2   |
| `0111` |   7   | `1111` |  −1   |

Addition ignores the carry out of the MSB, so results wrap around:
`7 + 1` gives `1000`, which is −8.

### Board mapping

| Signal                         | Board                                       |
|--------------------------------|---------------------------------------------|
| `x[0:3]`                       | SW3 (MSB), SW2, SW1, SW0 (LSB)              |
| `zx`, `nx`, `zy`, `ny`, `f`, `no` | SW9, SW8, SW7, SW6, SW5, SW4             |
| `y[0:3]`                       | SW15 (MSB), SW14, SW13, SW12 (LSB)          |
| `out[0:3]`                     | LD3 (MSB), LD2, LD1, LD0 (LSB)              |
| `zr`                           | LD15                                        |
| `ng`                           | LD14                                        |
| `out` as a signed decimal      | Sign on AN1, magnitude on AN0 (rightmost)   |

The control switches SW9–SW4 are in the same left-to-right order as the
columns of the table above, so you can copy a row straight onto the board.

---

## 3. Tasks

### TODO 1: Zero / negate unit (`zero_negate.v`)

`zero_negate` has a 4-bit input `in`, two control bits `z` and `n`, and a
4-bit output `out`:

```
if (z == 1) in  = 0
if (n == 1) out = !in    else out = in
```

1. Start with one bit. Write the truth table of `out` as a function of
   `in`, `z`, `n`.
2. Split it in two steps. Which single gate passes a bit through when a
   control is `0` and forces it to `0` when the control is `1`? Which gate
   passes a bit through when the control is `0` and inverts it when the
   control is `1`?
3. Apply your answer to all 4 bits at once. In Verilog, `{4{z}}` is the
   4-bit vector `{z, z, z, z}`, so `in & {4{z}}` ANDs every bit of `in`
   with `z`.

### TODO 2: Multiplexer (`mux2_4.v`)

`mux2_4` outputs `a` when `sel = 0` and `b` when `sel = 1`.

1. Write the truth table of a 1-bit 2-to-1 mux (inputs `a`, `b`, `sel`).
2. Use a K-map to derive a simplified expression for `out`.
3. Implement it for 4 bits with one `assign` statement.

### TODO 3: ALU datapath (`alu.v`)

Connect the parts as in the block diagram. The internal wires are already
declared, and `pre_x` is instantiated for you. Add:

1. `pre_y`: a `zero_negate` for `y` controlled by `zy`, `ny`.
2. `and_out`: the bit-wise AND of `x_pre` and `y_pre`.
3. `adder`: a `four_bit_adder` computing `x_pre + y_pre`. Its carry out is
   not used, so leave it unconnected: `.cout()`.
4. `select_f`: a `mux2_4` choosing `and_out` when `f = 0` and `add_out`
   when `f = 1`.
5. `post_out`: a `zero_negate` on `f_out` that never zeroes and negates
   when `no = 1`. Its output is the module output `out`.

### TODO 4: Status flags (`alu.v`)

- `zr` must be `1` exactly when `out` is `0000`.
- `ng` must be `1` exactly when `out` is negative.

Use only `&`, `|`, `~` on the individual bits of `out`. How many bits of
`out` do you need to look at to decide `ng`?

### Questions

Work through these on paper. Be ready to explain your answers.

1. In two's complement, `!v = −v − 1` for every 4-bit `v`. Check this for
   `v = 3` and `v = −8`.
2. The book traces the row `x-1` (`001110`) on p. 71. Do the same for
   `x+1` (`011111`) with `x = 5`: write down `x_pre`, `y_pre`, `f_out` and
   `out` in binary. Then use question 1 to show that this row gives `x+1`
   for **every** `x`.
3. Do the same for `x-y` (`010011`).
4. `zero_negate` zeroes first and negates second. Which rows of the table
   would stop working if the order were swapped? Why?
5. Set `x = 7`, `y = 1` and compute `x+y`. What do `out`, `zr` and `ng`
   show? Is `ng` "wrong"? What is going on?
6. Six control bits allow 64 settings, but the table lists only 18. What
   does `000001` compute? Find one more setting not in the table that
   computes something useful.

### Rules

- In `zero_negate`, `mux2_4` and `alu` use only `&`, `|`, `^`, `~`,
  replication (`{4{...}}`), and instances of the given modules.
- **No** `+`, `-`, `?:`, `if`, `case`, `==`, `<` or other comparison
  operators in these three files. Addition must come from `four_bit_adder`.
- Do not modify `top.v`, `ssd.v`, `master.xdc` or the testbenches.

---

## 4. Testing

1. **Simulate first.** Each module has its own self-checking testbench:

   | Testbench             | Module under test | Inputs tried                                    |
   |-----------------------|-------------------|-------------------------------------------------|
   | `tb_full_adder.v`     | `full_adder`      | all 8 `x, y, cin`                               |
   | `tb_four_bit_adder.v` | `four_bit_adder`  | all 256 `a, b`                                  |
   | `tb_zero_negate.v`    | `zero_negate`     | all 16 `in` × 4 `z, n`                          |
   | `tb_mux2_4.v`         | `mux2_4`          | all 256 `a, b` × 2 `sel`                        |
   | `tb_alu.v`            | `alu`             | the 18 table rows, then all 64 control settings, each for all 256 `x, y` |

   Test `zero_negate` and `mux2_4` before `alu`: if either is broken, the
   ALU will fail too.

   `tb_alu` first prints `PASS`/`FAIL` for each of the 18 functions in the
   table, then one line for the sweep over all 64 control settings. It
   prints at most 20 failing cases. A passing run ends with
   `alu: ALL 20992 TESTS PASSED`.

   **In Vivado:** add the `tb_*.v` files as *simulation sources*, right-click
   the testbench you want and choose *Set as Top*, then run *Run Simulation →
   Run Behavioral Simulation*. The result is printed in the Tcl console.

2. **Then run on the board.** Create a Vivado project with all design `.v`
   files and `master.xdc`, set `top` as the top module, generate the
   bitstream and program the Basys3.

   Set `x = 3` (SW3–SW0 = `0011`) and `y = 2` (SW15–SW12 = `0010`), then try
   these rows:

   | Function | SW9–SW4 (`zx nx zy ny f no`) | Display | LD3–LD0 | LD15 (`zr`) | LD14 (`ng`) |
   |:--------:|:----------------------------:|:-------:|:-------:|:-----------:|:-----------:|
   |   `0`    |           `101010`           |   `0`   | `0000`  |     on      |     off     |
   |  `x+y`   |           `000010`           |   `5`   | `0101`  |     off     |     off     |
   |  `x-y`   |           `010011`           |   `1`   | `0001`  |     off     |     off     |
   |  `y-x`   |           `000111`           |  `-1`   | `1111`  |     off     |     on      |
   |  `!x`    |           `001101`           |  `-4`   | `1100`  |     off     |     on      |
   |  `x&y`   |           `000000`           |   `2`   | `0010`  |     off     |     off     |
   |  `x\|y`  |           `010101`           |   `3`   | `0011`  |     off     |     off     |

   Then check your answer to question 5 on the board.

---
