# COL215 – Digital Logic and System Design

**Lab Assignment 3: BCD Adder**

---

## 1. Introduction

Design and implement a circuit that adds two decimal digits (0–9) set on the
switches of the Basys3 board and shows the two-digit decimal result (0–18) on
the 7-segment displays. For example, if the two inputs are 7 and 5, the display
should show `12`.

You will build the adder bottom-up from structural Verilog:

```
full_adder  ──►  four_bit_adder  ──►  bcd_adder  ──►  top (given)
 (TODO 1)          (TODO 2)            (TODO 3)
```

---

## 2. Provided Files

| File               | Status        | Description                                                 |
|--------------------|---------------|-------------------------------------------------------------|
| `full_adder.v`     | **TODO 1**    | 1-bit full adder                                            |
| `four_bit_adder.v` | **TODO 2**    | 4-bit ripple-carry adder built from `full_adder`s           |
| `bcd_adder.v`      | **TODO 3**    | 1-digit BCD adder (you design the circuit)                  |
| `ssd.v`            | Given         | BCD digit to 7-segment decoder (as in Lab 2)                |
| `top.v`            | Given         | Connects switches → `bcd_adder` → two 7-segment displays    |
| `master.xdc`       | Given         | Basys3 constraints                                          |
| `tb_*.v`           | Given         | Self-checking testbenches, one per TODO module              |

Do not change the module names or port lists. `top.v`, `ssd.v` and
`master.xdc` depend on them.

### Bit ordering

All vectors in this lab are declared as `[0:3]`, so **index 0 is the MSB and
index 3 is the LSB**. For example, `a = 4'b0011` (decimal 3) means:

| `a[0]` | `a[1]` | `a[2]` | `a[3]` |
|:------:|:------:|:------:|:------:|
|   0    |   0    |   1    |   1    |

This is why the given `fa0` in `four_bit_adder.v` adds `a[3]` and `b[3]`.

### Board mapping

| Signal   | Switches / display                            |
|----------|-----------------------------------------------|
| `a[0:3]` | SW3 (MSB), SW2, SW1, SW0 (LSB)                |
| `b[0:3]` | SW15 (MSB), SW14, SW13, SW12 (LSB)            |
| Tens     | Leftmost 7-segment display (AN3)              |
| Units    | Second display from the left (AN2)            |

`top.v` switches between the two displays fast enough that both look lit at
the same time.

---

## 3. Tasks

### TODO 1: Full adder (`full_adder.v`)

A full adder adds three bits `x`, `y`, `cin` and produces a sum bit `s` and a
carry bit `cout`.

1. Write the truth table.
2. Derive simplified Boolean expressions for `s` and `cout` using K-maps.
3. Implement them with `assign` statements using only `&`, `|`, `^`, `~`.

### TODO 2: 4-bit adder (`four_bit_adder.v`)

Build a 4-bit ripple-carry adder by chaining four `full_adder` instances.

1. The LSB stage `fa0` is given. Its carry in is tied to `0`.
2. Add `fa1`, `fa2`, `fa3` for bits 2, 1 and 0. Each stage's `cin` is the
   previous stage's `cout` (`c1`, `c2`, `c3`).
3. The carry out of the MSB stage is the module output `cout`.

`{cout, s}` should equal `a + b` for **all** 256 input combinations.

### TODO 3: BCD adder (`bcd_adder.v`)

In BCD (binary-coded decimal) each decimal digit is stored as its own 4-bit
binary number, so only the codes `0000`–`1001` (0–9) are valid. Your
`bcd_adder` adds two BCD digits `a` and `b` and must produce the answer in
BCD: `c` is the tens digit (0 or 1) and `s` is the units digit (0–9).

This time **you design the circuit.** Start from the truth table below. Since
`a, b ≤ 9`, the sum is at most 18. For each possible sum, the table shows what
your `four_bit_adder` produces (carry out and 4-bit sum) and what `bcd_adder`
must output instead.

| Sum | Carry | 8 | 4 | 2 | 1 | `c` | `s` 8 | `s` 4 | `s` 2 | `s` 1 |
|:---:|:-----:|:-:|:-:|:-:|:-:|:---:|:-----:|:-----:|:-----:|:-----:|
|  0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
|  1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 1 |
|  2 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 0 |
|  3 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 1 | 1 |
|  4 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |
|  5 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | 1 | 0 | 1 |
|  6 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 1 | 1 | 0 |
|  7 | 0 | 0 | 1 | 1 | 1 | 0 | 0 | 1 | 1 | 1 |
|  8 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
|  9 | 0 | 1 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | 1 |
| 10 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 0 |
| 11 | 0 | 1 | 0 | 1 | 1 | 1 | 0 | 0 | 0 | 1 |
| 12 | 0 | 1 | 1 | 0 | 0 | 1 | 0 | 0 | 1 | 0 |
| 13 | 0 | 1 | 1 | 0 | 1 | 1 | 0 | 0 | 1 | 1 |
| 14 | 0 | 1 | 1 | 1 | 0 | 1 | 0 | 1 | 0 | 0 |
| 15 | 0 | 1 | 1 | 1 | 1 | 1 | 0 | 1 | 0 | 1 |
| 16 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 | 0 |
| 17 | 1 | 0 | 0 | 0 | 1 | 1 | 0 | 1 | 1 | 1 |
| 18 | 1 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 0 | 0 |

The left half is the output of `four_bit_adder` (binary sum). The right half
is the required output of `bcd_adder` (BCD sum).

Work through these questions on paper before writing any Verilog:

1. For which sums are the binary and BCD columns the same? For which do they
   differ?
2. In the rows where they differ, compare the two 4-bit values as numbers. Is
   there a pattern?
3. Write `c` as a Boolean function of the binary-sum columns (Carry, 8, 4, 2,
   1) and simplify it. Sums 19–31 can never occur, so you can treat them as
   don't cares.
4. How can you turn the binary sum into the BCD sum using only the modules you
   have already built and a few gates?

Draw your circuit as a block diagram, then implement it in `bcd_adder.v`. For
every `a, b` in 0–9, `{c, s}` must be the BCD form of `a + b`. Behaviour for
inputs above 9 is not specified.

Be ready to explain your design: your expression for `c`, how you got it, and
why your circuit gives the correct `s` in every row of the table.

### Rules

- **Do not use the `+` operator** in `full_adder`, `four_bit_adder` or
  `bcd_adder`. Addition must come from the gates and instances you write.
- `four_bit_adder` must use `full_adder` instances. `bcd_adder` must be built
  from `four_bit_adder` instances and logic gates only: no `+`, `-`, `<`,
  `>`, `/`, `%`, and no `case`/`if` lookup of the truth table.
- Do not modify `top.v`, `ssd.v` or `master.xdc`.

---

## 4. Testing

1. **Simulate first.** Each TODO module has its own self-checking testbench
   that tries every valid input and prints each mismatch:

   | Testbench             | Module under test | Inputs tried            |
   |-----------------------|-------------------|-------------------------|
   | `tb_full_adder.v`     | `full_adder`      | all 8 `x, y, cin`       |
   | `tb_four_bit_adder.v` | `four_bit_adder`  | all 256 `a, b` in 0–15  |
   | `tb_bcd_adder.v`      | `bcd_adder`       | all 100 `a, b` in 0–9   |

   Test the modules in order: a broken `full_adder` will also make the other
   two fail. A passing run ends with a line like
   `four_bit_adder: ALL 256 TESTS PASSED`.

   **In Vivado:** add the `tb_*.v` files as *simulation sources*, right-click
   the testbench you want and choose *Set as Top*, then run *Run Simulation →
   Run Behavioral Simulation*. The result is printed in the Tcl console.

   **From the command line** (with Vivado's `bin` directory on your `PATH`):

   ```sh
   xvlog full_adder.v four_bit_adder.v bcd_adder.v tb_bcd_adder.v
   xelab tb_bcd_adder -s tb_bcd_adder
   xsim tb_bcd_adder -R
   ```

   Change the testbench name to run the other two.

2. **Then run on the board.** Create a Vivado project with all `.v` files and
   `master.xdc`, set `top` as the top module, generate the bitstream and
   program the Basys3. Try at least these inputs:

| `a` | `b` | Expected display |
|:---:|:---:|:----------------:|
|  0  |  0  |       `00`       |
|  3  |  4  |       `07`       |
|  5  |  5  |       `10`       |
|  7  |  5  |       `12`       |
|  9  |  9  |       `18`       |

---
