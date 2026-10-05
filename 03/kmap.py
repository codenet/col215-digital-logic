#!/usr/bin/env python3

"""
4-variable Karnaugh-map solver/drawer for the COL 215 lab exam.

Inputs:
    w x y z

K-map layout:
    rows    = wx = 00, 01, 11, 10
    columns = yz = 00, 01, 11, 10

Minterms 10-15 are don't-cares because the circuit only needs
to represent decimal digits 0-9.

Requires:
    pip install pyeda matplotlib
"""
from pyeda.inter import exprvars
from pyeda.boolalg.table import truthtable
from pyeda.boolalg.minimization import espresso_tts

import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle


# ------------------------------------------------------------
# Seven-segment truth table
# ------------------------------------------------------------
#
# 0 = LED ON
# 1 = LED OFF
#
#        A
#      -----
#   F |     | B
#     |  G  |
#      -----
#   E |     | C
#     |     |
#      -----
#        D
#
# Values for digits 0..9.
#

SEGMENTS = {
    0: dict(A=0, B=0, C=0, D=0, E=0, F=0, G=1),
    1: dict(A=1, B=0, C=0, D=1, E=1, F=1, G=1),
    2: dict(A=0, B=0, C=1, D=0, E=0, F=1, G=0),
    3: dict(A=0, B=0, C=0, D=0, E=1, F=1, G=0),
    4: dict(A=1, B=0, C=0, D=1, E=1, F=0, G=0),
    5: dict(A=0, B=1, C=0, D=0, E=1, F=0, G=0),
    6: dict(A=0, B=1, C=0, D=0, E=0, F=0, G=0),
    7: dict(A=0, B=0, C=0, D=1, E=1, F=1, G=1),
    8: dict(A=0, B=0, C=0, D=0, E=0, F=0, G=0),
    9: dict(A=0, B=0, C=0, D=0, E=1, F=0, G=0),
}


# ------------------------------------------------------------
# Variables
# ------------------------------------------------------------

w, x, y, z = exprvars("v", 4)

# K-map Gray-code ordering
GRAY = [
    (0, 0),
    (0, 1),
    (1, 1),
    (1, 0),
]


# ------------------------------------------------------------
# Build truth table for one segment
# ------------------------------------------------------------

def make_truth_table(segment):
    """
    Return a PyEDA truth table.

    PyEDA's table is indexed by the four input variables.
    For variables [w, x, y, z], row index i corresponds to:
        w = i & 1
        x = (i >> 1) & 1
        y = (i >> 2) & 1
        z = (i >> 3) & 1

    But digits are indexed as:
        w = (d >> 3) & 1
        x = (d >> 2) & 1
        y = (d >> 1) & 1
        z = d & 1

    So we need to reorder the values string to match the truthtable row ordering.
    """

    values_by_row = ["-"] * 16

    # Map digit value d to truthtable row index
    for d in range(16):
        if d <= 9:
            digit_value = SEGMENTS[d][segment]
        else:
            digit_value = "-"

        # Calculate which row this digit maps to
        w_d = (d >> 3) & 1
        x_d = (d >> 2) & 1
        y_d = (d >> 1) & 1
        z_d = d & 1

        # Row index where w = i & 1, x = (i >> 1) & 1, etc.
        row_index = w_d | (x_d << 1) | (y_d << 2) | (z_d << 3)

        values_by_row[row_index] = str(digit_value)

    return truthtable([w, x, y, z], "".join(values_by_row))


# ------------------------------------------------------------
# Minimize
# ------------------------------------------------------------

def minimize(segment):
    tt = make_truth_table(segment)

    minimized, = espresso_tts(tt)

    return minimized


# ------------------------------------------------------------
# Convert PyEDA expression to a nicer formula
# ------------------------------------------------------------

def formula(expr):
    """
    Convert PyEDA's expression representation into
    a readable Boolean formula.

    Example:

        Or(And(~v[0], v[1]), And(v[2], ~v[3]))

    becomes:

        w'x + yz'
    """

    # Constant
    if str(expr) == "0":
        return "0"

    if str(expr) == "1":
        return "1"

    # DNF gives us product terms
    expr = expr.to_dnf()

    # Single literal / single product
    terms = expr.xs if expr.__class__.__name__ == "OrOp" else [expr]

    result = []

    for term in terms:

        # If the term is just one variable
        if term.__class__.__name__ in ("Variable", "Complement"):
            factors = [term]
        else:
            factors = (
                term.xs
                if term.__class__.__name__ == "AndOp"
                else [term]
            )

        # Map v[i] to actual variable
        # v[0]→w, v[1]→x, v[2]→y, v[3]→z (standard order)
        var_map = ["w", "x", "y", "z"]

        # Extract variable assignments from factors
        var_assignments = {}
        for factor in factors:
            s = str(factor)
            if s.startswith("~"):
                idx = int(s.split("[")[1].split("]")[0])
                var_assignments[var_map[idx]] = "'"
            else:
                idx = int(s.split("[")[1].split("]")[0])
                var_assignments[var_map[idx]] = ""

        # Build product in wxyz order
        product = []
        for var in ["w", "x", "y", "z"]:
            if var in var_assignments:
                product.append(var + var_assignments[var])

        result.append("".join(product))

    return " + ".join(result)


# ------------------------------------------------------------
# Determine which minterms an implicant covers
# ------------------------------------------------------------

def cube_for_term(term):
    """
    Convert a PyEDA product term into a 4-character cube.

    Example:

        ~w & x & z

    becomes:

        01-1

    '-' means the variable is eliminated.
    """

    cube = ["-", "-", "-", "-"]

    names = ["w", "x", "y", "z"]

    if term.__class__.__name__ == "AndOp":
        factors = term.xs
    else:
        factors = [term]

    for factor in factors:

        s = str(factor)

        negated = s.startswith("~")

        if negated:
            s = s[1:]

        idx = int(s.split("[")[1].split("]")[0])

        cube[idx] = "0" if negated else "1"

    return "".join(cube)


def get_cubes(expr):
    """
    Extract product terms from a minimized expression.
    """

    expr = expr.to_dnf()

    if expr.__class__.__name__ == "OrOp":
        terms = expr.xs
    else:
        terms = [expr]

    return [cube_for_term(term) for term in terms]


# ------------------------------------------------------------
# Minterm coordinates
# ------------------------------------------------------------

def minterm_to_position(m):
    """
    Convert a minterm to K-map row/column.

    Rows    = wx
    Columns = yz
    Both are Gray ordered.
    """

    bits = (
        (m >> 3) & 1,
        (m >> 2) & 1,
        (m >> 1) & 1,
        m & 1,
    )

    wx = bits[:2]
    yz = bits[2:]

    row = GRAY.index(wx)
    col = GRAY.index(yz)

    return row, col


# ------------------------------------------------------------
# Does a cube cover a minterm?
# ------------------------------------------------------------

def cube_covers(cube, m):
    bits = f"{m:04b}"

    return all(
        c == "-" or c == b
        for c, b in zip(cube, bits)
    )


# ------------------------------------------------------------
# Draw K-map
# ------------------------------------------------------------

def draw_kmap(segment, expr):

    # --------------------------------------------------------
    # Cell values
    # --------------------------------------------------------

    values = []

    for row_bits in GRAY:
        row = []

        for col_bits in GRAY:

            bits = row_bits + col_bits

            m = (
                bits[0] * 8
                + bits[1] * 4
                + bits[2] * 2
                + bits[3]
            )

            if m <= 9:
                value = SEGMENTS[m][segment]
            else:
                value = "X"

            row.append(value)

        values.append(row)

    # --------------------------------------------------------
    # Figure
    # --------------------------------------------------------

    fig, ax = plt.subplots(figsize=(7, 6))

    ax.set_xlim(0, 4)
    ax.set_ylim(0, 4)

    ax.set_aspect("equal")

    # Grid
    for i in range(5):
        ax.plot([i, i], [0, 4], linewidth=1)
        ax.plot([0, 4], [i, i], linewidth=1)

    # --------------------------------------------------------
    # Header labels
    # --------------------------------------------------------

    for col, bits in enumerate(GRAY):
        ax.text(
            col + 0.5,
            4.18,
            f"{bits[0]}{bits[1]}",
            ha="center",
            va="center",
            fontsize=12,
        )

    for row, bits in enumerate(GRAY):
        ax.text(
            -0.18,
            3.5 - row,
            f"{bits[0]}{bits[1]}",
            ha="right",
            va="center",
            fontsize=12,
        )

    ax.text(
        2,
        4.55,
        "yz",
        ha="center",
        fontsize=13,
    )

    ax.text(
        -0.55,
        2,
        "wx",
        ha="center",
        fontsize=13,
        rotation=90,
    )

    # --------------------------------------------------------
    # Cell contents
    # --------------------------------------------------------

    for row in range(4):
        for col in range(4):

            value = values[row][col]

            ax.text(
                col + 0.5,
                3.5 - row,
                str(value),
                ha="center",
                va="center",
                fontsize=16,
            )

    # --------------------------------------------------------
    # Draw implicant groups
    # --------------------------------------------------------

    cubes = get_cubes(expr)

    # Different line styles make overlapping groups easier
    # to distinguish without depending on colors.
    styles = [
        ("-", 2.5),
        ("--", 2.5),
        (":", 3.0),
        ("-.", 2.5),
    ]

    for i, cube in enumerate(cubes):

        cells = []

        for m in range(16):

            if cube_covers(cube, m):

                row, col = minterm_to_position(m)

                cells.append((row, col))

        if not cells:
            continue

        # ----------------------------------------------------
        # Find contiguous rectangular pieces.
        #
        # A K-map wraps around. For example, columns 0 and 3
        # are adjacent. Splitting the cells into simple
        # rectangles keeps the drawing understandable.
        # ----------------------------------------------------

        rows = sorted(set(r for r, _ in cells))
        cols = sorted(set(c for _, c in cells))

        # Handle normal rectangles first.
        #
        # For wrapping groups, the simple representation below
        # draws the participating cells individually.
        #
        # This is visually unambiguous even for wrap-around
        # groups.
        #

        linestyle, linewidth = styles[i % len(styles)]

        for row, col in cells:

            # Slightly inset rectangle around the cell
            rect = Rectangle(
                (col + 0.08, 3 - row + 0.08),
                0.84,
                0.84,
                fill=False,
                linewidth=linewidth,
                linestyle=linestyle,
            )

            ax.add_patch(rect)

    # --------------------------------------------------------
    # Title / formula
    # --------------------------------------------------------

    ax.set_title(
        f"{segment}: {formula(expr)}",
        fontsize=15,
        pad=35,
    )

    ax.axis("off")

    plt.tight_layout()

    return fig


# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

def main():

    print()

    for segment in "ABCDEFG":

        expr = minimize(segment)

        print(
            f"{segment} = {formula(expr)}"
        )

    print()

    # Draw individual maps
    for segment in "ABCDEFG":

        expr = minimize(segment)

        fig = draw_kmap(segment, expr)

        # Save
        fig.savefig(
            f"kmap_{segment}.png",
            dpi=200,
            bbox_inches="tight",
        )

        plt.show()


if __name__ == "__main__":
    main()
