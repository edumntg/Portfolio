from pyomo.environ import *
import numpy as np

# Define the number of variables
n = 10
nv = range(n) # a vector containing the indexes 0, 1, 2 ... n

# DEFINE THE VECTOR p AS A VECTOR OF RANDOM NUMBERS
p = np.random.rand(1, n)

# DEFINE P AS A MATRIX OF RANDOM NUMBERS, WITH SIZE nxn
P = np.random.rand(n,n)

"""
    MODEL
"""
# Create the model
model = ConcreteModel()

# Define the variables
model.x = Var(nv, within = Binary) # xi variables where i = 0, 1, 2... n
# xi are defined as binary

model.z = Var(nv) # zi variables where i = 0, 1, 2... n
# zi are in the domain of real numbers

# Define the lower and upper bounds values Li and Ui. Those are not variables, are constants
# For test purposes, these bounds are built using random numbers
L = np.random.rand(1,n)
U = np.random.rand(1,n) + 5

# Define the objective function
def ObjectiveFunc(model):
    return sum(p[0][i]*model.x[i] for i in range(n)) + sum(model.z[i] for i in range(n))


"""
    DEFINE THE CONSTRAINTS
"""

# The following two contraints are for the equations:
# Li*xi <= zi <= Ui*xi
def C0(model, i):
    return model.z[i] >= L[0][i]*model.x[i]

def C1(model, i):
    return model.z[i] <= U[0][i]*model.x[i]

# The following two constraints are for the equations:
    # sum(Pij*xj) - Ui(1-xi) <= zi <= NOT VISIBLE
def C2(model, i):
    upper = 0
    for j in range(n):
        if i != j:
            upper += P[i][j]*model.x[j]
    
    return model.z[i] >= upper - U[0][i]*(1-model.x[i])

def C3(model, i):
    return model.z[i] <= 99999 # This is the not visible equation

"""
    Add the objective and constraints to the model
"""
model.obj = Objective(rule = ObjectiveFunc, sense = maximize)
model.c0 = Constraint(range(n), rule = C0)
model.c1 = Constraint(range(n), rule = C1)
model.c2 = Constraint(range(n), rule = C2)
model.c3 = Constraint(range(n), rule = C3)

"""
    Define the solver. For this problem, we use Gurobi
"""
solver = SolverFactory('gurobi', solver_io = 'python')

"""
    Get results and print them
"""
results = solver.solve(model)
print(results.solver.termination_condition) # should return "optimal"

print(results)
model.display()