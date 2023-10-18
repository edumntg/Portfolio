from PowerSystem import *
import pyomo.environ as pyo
from pyomo.environ import cos, sin

class PowerSystemSolver(object):

    def __init__(self, system: PowerSystem):
        self.system = system
        self.opf_solved = False
        self.pf_solved = False
        self.opf_solution = None
        self.opf_solver = None
        self.pf_solution = None

    def opf(self):
        if not self.system:
            raise "No PowerSystem object declared"
        
        # Construct Ybus
        self.system.construct_ybus()

        # Construct Pyomo model
        model = self.__construct_optim_model()

        # Construct solver
        solver = self.__construct_solver()

        # Now, solve
        results = solver.solve(model)
        self.opf_solution = results

        return self.opf_solution

    def __construct_optim_model(self):
        self.optim_model = pyo.ConcreteModel()

        # Initialize constants
        self.optim_model.Buses = pyo.Set(initialize = self.system.buses.keys())
        self.optim_model.Lines = pyo.Set(initialize = self.system.lines.keys())
        self.optim_model.Generators =  pyo.Set(initialize = self.system.generators.keys())

        # Create variables
        
        # Bus voltages
        self.optim_model.V = pyo.Var(self.optim_model.Buses, initialize=1.0, bounds = (0.95, 1.05), within = pyo.PositiveReals)
        
        # Bus angles
        self.optim_model.theta = pyo.Var(self.optim_model.Buses, initialize = 0.0, bounds = (-np.pi, np.pi), within = pyo.Reals)

        # Active power generated at each bus/gen
        self.optim_model.Pgen = pyo.Var(self.optim_model.Buses, initialize = 0.0, within = pyo.Reals)
        
        # Reactive power generagted at each bus/gen
        self.optim_model.Qgen = pyo.Var(self.optim_model.Buses, initialize = 0.0, within = pyo.Reals)

        # Active power flow through lines
        self.optim_model.Pflow = pyo.Var(self.optim_model.Buses, self.optim_model.Buses, initialize = 0.0, within = pyo.Reals)

        # Reactive power flow through lines
        self.optim_model.Qflow = pyo.Var(self.optim_model.Buses, self.optim_model.Buses, initialize = 0.0, within = pyo.Reals)

        # Integer variables which declares is a line is active or not
        self.optim_model.l = pyo.Var(self.optim_model.Lines, initialize = 1, within = pyo.Binary)

        # Declare the objective function. For this problem, we want to minimize the operating cost
        self.optim_model.obj = pyo.Objective(rule = self.__optim_objective, sense = pyo.minimize)

        # Add constraints
        self.optim_model.c0 = pyo.Constraint(self.optim_model.Buses, rule = self.__optim_constr_gen_Pmin)
        self.optim_model.c1 = pyo.Constraint(self.optim_model.Buses, rule = self.__optim_constr_gen_Pmax)
        self.optim_model.c2 = pyo.Constraint(self.optim_model.Buses, rule = self.__optim_constr_gen_Qmin)
        self.optim_model.c3 = pyo.Constraint(self.optim_model.Buses, rule = self.__optim_constr_gen_Qmax)
        self.optim_model.c4 = pyo.Constraint(self.optim_model.Buses, rule = self.__optim_constr_kirchoff_P)
        self.optim_model.c5 = pyo.Constraint(self.optim_model.Buses, rule = self.__optim_constr_kirchoff_Q)
        self.optim_model.c6 = pyo.Constraint(self.optim_model.Lines, rule = self.__optim_constr_line_P_fromto)
        self.optim_model.c7 = pyo.Constraint(self.optim_model.Lines, rule = self.__optim_constr_line_P_tofrom)
        self.optim_model.c8 = pyo.Constraint(self.optim_model.Lines, rule = self.__optim_constr_line_Q_fromto)
        self.optim_model.c9 = pyo.Constraint(self.optim_model.Lines, rule = self.__optim_constr_line_Q_tofrom)
        self.optim_model.c10 = pyo.Constraint(self.optim_model.Lines, rule = self.__optim__constr_line_max_mva_fromto)
        self.optim_model.c11 = pyo.Constraint(self.optim_model.Lines, rule = self.__optim__constr_line_max_mva_tofrom)

        return self.optim_model

    def __construct_solver(self, solver = 'ipopt'):
        self.opf_solver = pyo.SolverFactory(solver)
        return self.opf_solver


    def __optim_objective(self, model):
        total_cost = 0.0
        for id, gen in self.system.generators.items():
            bus = int(gen[0])
            a = gen[4]
            b = gen[5]
            c = gen[6]

            total_cost += c*model.Pgen[bus]**2 + b*model.Pgen[bus] + a

        return total_cost
    
    def __optim_constr_gen_Pmin(self, model, bus):
        ids = [key for (key, v) in self.system.generators.items() if v[0] == bus]
        lower_bound = 0
        if ids:
            lower_bound = self.system.generators[ids[0]][1]

        return model.Pgen[bus] >= lower_bound
    
    def __optim_constr_gen_Pmax(self, model, bus):
        ids = [key for (key, v) in self.system.generators.items() if v[0] == bus]
        upper_bound = 0
        if ids:
            upper_bound = self.system.generators[ids[0]][2]

        return model.Pgen[bus] <= upper_bound
    
    def __optim_constr_gen_Qmin(self, model, bus):
        ids = [key for (key, v) in self.system.generators.items() if v[0] == bus]
        lower_bound = 0
        if ids:
            lower_bound = self.system.generators[ids[0]][3]

        return model.Qgen[bus] >= lower_bound
    
    def __optim_constr_gen_Qmax(self, model, bus):
        ids = [key for (key, v) in self.system.generators.items() if v[0] == bus]
        upper_bound = 0
        if ids:
            upper_bound = self.system.generators[ids[0]][4]

        return model.Qgen[bus] <= upper_bound
    
    def __optim_constr_kirchoff_P(self, model, bus):
        Pflow = 0.0
        Pgen = model.Pgen[bus]

        for line in model.Lines:
            from_bus = int(self.system.lines[line][0])
            to_bus = int(self.system.lines[line][1])
            if from_bus == bus:
                Pflow += model.Pflow[from_bus, to_bus]
            elif to_bus == bus:
                Pflow += model.Pflow[to_bus, from_bus]

        return Pgen == self.system.buses[bus][6] + Pflow
    
    def __optim_constr_kirchoff_Q(self, model, bus):
        Qflow = 0.0
        Qgen = model.Qgen[bus]
        Qshunt = 0.0

        for line in model.Lines:
            from_bus = int(self.system.lines[line][0])
            to_bus = int(self.system.lines[line][1])
            if from_bus == bus:
                Qflow += model.Qflow[from_bus, to_bus]
            elif to_bus == bus:
                Qflow += model.Qflow[to_bus, from_bus]

        return Qgen == self.system.buses[bus][7] + Qflow + Qshunt
    
    def __optim_constr_line_P_fromto(self, model, line):
        i = int(self.system.lines[line][0])
        k = int(self.system.lines[line][1])

        return model.Pflow[i,k] == model.l[line]*(
            (-self.system.G[i-1,k-1] + self.system.g[i-1,k-1])*model.V[i]**2 +\
                model.V[i]*model.V[k]*(self.system.G[i-1,k-1]*cos(model.theta[i] - model.theta[k]) +\
                               self.system.B[i-1,k-1]*sin(model.theta[i]-model.theta[k]))
        )
    
    def __optim_constr_line_P_tofrom(self, model, line):
        i = int(self.system.lines[line][1])
        k = int(self.system.lines[line][0])

        return model.Pflow[i,k] == model.l[line]*(
            (-self.system.G[i-1,k-1] + self.system.g[i-1,k-1])*model.V[i]**2 +\
                model.V[i]*model.V[k]*(self.system.G[i-1,k-1]*cos(model.theta[i] - model.theta[k]) +\
                               self.system.B[i-1,k-1]*sin(model.theta[i]-model.theta[k]))
        )
    
    def __optim_constr_line_Q_fromto(self, model, line):
        i = int(self.system.lines[line][0])
        k = int(self.system.lines[line][1])

        return model.Pflow[i,k] == model.l[line]*(
            (self.system.B[i-1,k-1] - self.system.b[i-1,k-1])*model.V[i]**2 +\
                model.V[i]*model.V[k]*(-self.system.B[i-1,k-1]*cos(model.theta[i] - model.theta[k]) +\
                               self.system.G[i-1,k-1]*sin(model.theta[i]-model.theta[k]))
        )
    
    def __optim_constr_line_Q_tofrom(self, model, line):
        i = int(self.system.lines[line][1])
        k = int(self.system.lines[line][0])

        return model.Pflow[i,k] == model.l[line]*(
            (-self.system.B[i-1,k-1] - self.system.b[i-1,k-1])*model.V[i]**2 +\
                model.V[i]*model.V[k]*(-self.system.B[i-1,k-1]*cos(model.theta[i] - model.theta[k]) +\
                               self.system.G[i-1,k-1]*sin(model.theta[i]-model.theta[k]))
        )
    
    def __optim__constr_line_max_mva_fromto(self, model, line):
        # Get apparent power
        S = self.system.lines[line][6]
        from_bus = int(self.system.lines[line][0])
        to_bus = int(self.system.lines[line][1])

        return model.Pflow[from_bus, to_bus]**2 + model.Qflow[from_bus, to_bus] <= S**2
    
    def __optim__constr_line_max_mva_tofrom(self, model, line):
        # Get apparent power
        S = self.system.lines[line][6]
        from_bus = int(self.system.lines[line][1])
        to_bus = int(self.system.lines[line][0])

        return model.Pflow[from_bus, to_bus]**2 + model.Qflow[from_bus, to_bus] <= S**2
    
    
    
    

        
    
