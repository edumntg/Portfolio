from gekko import GEKKO
import numpy as np
# Create model

m = GEKKO()
m.options.SOLVER = 1

x = m.Var(value = 0.0)
def obj(x):
    return x

def const(x):
    return m.sin(x) >= 1
m.Maximize(obj(x))
m.Equation(const(x))
m.solve(disp = True)
print(x.value)
print(m.options.objfcnval)