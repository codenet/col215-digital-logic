from sympy import symbols
from sympy.logic import simplify_logic

x, y = symbols('x y')

expr = x | (x & y)     # x + xy
simplified = simplify_logic(expr)
print(f"{expr}  =  {simplified}")

# expr = x & (~x | y)     # x (x'+y)
# simplified = simplify_logic(expr)
# print(f"{expr}  =  {simplified}")
# 
# expr = x | (~x & y)     # x + x'y
# simplified = simplify_logic(expr)
# print(f"{expr}  =  {simplified}")
