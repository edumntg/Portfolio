from PowerSystem import *
from PowerSystemSolver_gekko import *
import pandas as pd

buses_arr = pd.read_excel('IEEE30.xlsx', 'BUS').to_numpy().astype('float64')
lines_arr = pd.read_excel('IEEE30.xlsx', 'RAMAS').to_numpy().astype('float64')
gens_arr = pd.read_excel('IEEE30.xlsx', 'GEN').to_numpy().astype('float64')

# Preprocess
buses = dict()
lines = dict()
gens = dict()

for i, row in enumerate(buses_arr):
   buses[i]= list(row)

for i, row in enumerate(lines_arr):
   lines[i] = list(row)

for i, row in enumerate(gens_arr):
   gens[i] = list(row)

data = {
    'buses': buses,
    'lines': lines,
    'generators': gens,
    'base': 100 # mva
}

system = PowerSystem(data)
# for line in system.lines:
#    print(str(line))

# Create solver
solver = PowerSystemSolver_gekko(system)

# Solve
solver.opf()
bus, gens, lines = solver.opf_results()
input()
print(bus)
input()
print(gens)
input()
print(lines)
# for i in range(system.n_buses):
#    print(f"V[{i}] = {solver.V[i].value}, theta[{i}] = {solver.theta[i].value}")

# for i in range(system.n_gens):
#    print(f"Pgen[{i}] = {solver.Pgen[i].value}")
#    print(f"Qgen[{i}] = {solver.Qgen[i].value}")

# for i in range(system.n_buses):
#    for j in range(system.n_buses):
#       print(f"Pflow[{i},{j}] = {solver.Pflow[i,j].value}")
#       print(f"Qflow[{i},{j}] = {solver.Qflow[i,j].value}")

# for i in range(system.n_lines):
#    print(f"Line {i} active = ({solver.l[i].value})")

# print('Objective: ' + str(solver.m.options.objfcnval))