from PowerSystem import *
from PowerSystemSolver import *
import pandas as pd

buses_arr = pd.read_excel('IEEE30.xlsx', 'BUS').to_numpy().astype('float64')
lines_arr = pd.read_excel('IEEE30.xlsx', 'RAMAS').to_numpy().astype('float64')
gens_arr = pd.read_excel('IEEE30.xlsx', 'GEN').to_numpy().astype('float64')

# Preprocess
buses = dict()
lines = dict()
gens = dict()

for i, row in enumerate(buses_arr):
   buses[i+1]= list(row)

for i, row in enumerate(lines_arr):
   row[6] = 100 # base
   lines[i+1] = list(row)

for i, row in enumerate(gens_arr):
   gens[i+1] = list(row)

data = {
    'buses': buses,
    'lines': lines,
    'generators': gens,
    'base': 100 # mva
}

system = PowerSystem(data)

# Create solver
solver = PowerSystemSolver(system)

# Solve
results = solver.opf()
print(results)