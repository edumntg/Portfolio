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
        #results = solver.solve(model, mip_solver='glpk', nlp_solver='ipopt', tee = True)
        results = solver.solve(model, tee = True)
        self.opf_solution = results

        return self.opf_solution

    def __construct_optim_model(self):
        self.optim_model = pyo.ConcreteModel()

        # Initialize constants
        self.optim_model.Buses = pyo.Set(initialize = [bus.id for bus in self.system.buses])
        self.optim_model.Lines = pyo.Set(initialize = [line.id for line in self.system.lines])
        self.optim_model.Generators =  pyo.Set(initialize = [gen.id for gen in self.system.generators])

        # Create variables
        
        # Bus voltages
        self.optim_model.V = pyo.Var(self.optim_model.Buses, initialize=1.0, bounds = (0.90, 1.1), within = pyo.PositiveReals)
        
        # Bus angles
        self.optim_model.theta = pyo.Var(self.optim_model.Buses, initialize = 0.0, bounds = (-np.pi, np.pi), within = pyo.Reals)

        # Active power generated at each bus/gen
        self.optim_model.Pgen = pyo.Var(self.optim_model.Generators, initialize = 0.0, within = pyo.Reals)
        
        # Reactive power generagted at each bus/gen
        self.optim_model.Qgen = pyo.Var(self.optim_model.Generators, initialize = 0.0, within = pyo.Reals)

        # Active power flow through lines
        self.optim_model.Pflow = pyo.Var(self.optim_model.Buses, self.optim_model.Buses, initialize = 0.0, within = pyo.Reals)

        # Reactive power flow through lines
        self.optim_model.Qflow = pyo.Var(self.optim_model.Buses, self.optim_model.Buses, initialize = 0.0, within = pyo.Reals)

        # Integer variables which declares is a line is active or not
        self.optim_model.l = pyo.Var(self.optim_model.Lines, initialize = 1, bounds = (0,1), within = pyo.Binary)

        # Declare the objective function. For this problem, we want to minimize the operating cost
        self.optim_model.obj = pyo.Objective(rule = self.__optim_objective, sense = pyo.minimize)

        # Add constraints
        self.optim_model.c0 = pyo.Constraint(self.optim_model.Generators, rule = self.__optim_constr_gen_Pmin)
        self.optim_model.c1 = pyo.Constraint(self.optim_model.Generators, rule = self.__optim_constr_gen_Pmax)
        self.optim_model.c2 = pyo.Constraint(self.optim_model.Generators, rule = self.__optim_constr_gen_Qmin)
        self.optim_model.c3 = pyo.Constraint(self.optim_model.Generators, rule = self.__optim_constr_gen_Qmax)
        self.optim_model.c4 = pyo.Constraint(self.optim_model.Buses, rule = self.__optim_constr_kirchoff_P)
        self.optim_model.c5 = pyo.Constraint(self.optim_model.Buses, rule = self.__optim_constr_kirchoff_Q)
        self.optim_model.c6 = pyo.Constraint(self.optim_model.Lines, rule = self.__optim_constr_line_P_fromto)
        self.optim_model.c7 = pyo.Constraint(self.optim_model.Lines, rule = self.__optim_constr_line_P_tofrom)
        self.optim_model.c8 = pyo.Constraint(self.optim_model.Lines, rule = self.__optim_constr_line_Q_fromto)
        self.optim_model.c9 = pyo.Constraint(self.optim_model.Lines, rule = self.__optim_constr_line_Q_tofrom)
        self.optim_model.c10 = pyo.Constraint(self.optim_model.Lines, rule = self.__optim__constr_line_max_mva_fromto)
        self.optim_model.c11 = pyo.Constraint(self.optim_model.Lines, rule = self.__optim__constr_line_max_mva_tofrom)

        return self.optim_model

    def __construct_solver(self, solver = 'gurobi'):
        self.opf_solver = pyo.SolverFactory(solver, solver_io='python')
        return self.opf_solver


    def __optim_objective(self, model):
        total_cost = 0.0

        for gen in self.system.generators:
            total_cost += gen.cost(model.Pgen[gen.id])

        return total_cost
    
    def __optim_constr_gen_Pmin(self, model, gen):
        Pmin = self.system.get_gen(gen).Pmin

        return model.Pgen[gen] >= Pmin
    
    def __optim_constr_gen_Pmax(self, model, gen):
        Pmax = self.system.get_gen(gen).Pmax

        return model.Pgen[gen] <= Pmax
    
    def __optim_constr_gen_Qmin(self, model, gen):
        Qmin = self.system.get_gen(gen).Qmin

        return model.Qgen[gen] >= Qmin
    
    def __optim_constr_gen_Qmax(self, model, gen):
        Qmax = self.system.get_gen(gen).Qmax

        return model.Qgen[gen] <= Qmax
    
    def __optim_constr_kirchoff_P(self, model, bus):
        Pflow = 0.0
        Pgen = 0

        # Find if there is a generator connected at this bus
        for gen in self.system.generators:
            if gen.bus == bus:
                Pgen += model.Pgen[gen.id]

        for line in self.system.lines:
            if line.from_bus == bus:
                Pflow += model.Pflow[line.from_bus, line.to_bus]

        for line in self.system.lines:
            if line.to_bus == bus:
                Pflow += model.Pflow[line.to_bus, line.from_bus]

        return Pgen == self.system.get_bus(bus).Pload + Pflow
    
    def __optim_constr_kirchoff_Q(self, model, bus):
        Qflow = 0.0
        Qgen = 0

        # Find if there is a generator connected at this bus
        for gen in self.system.generators:
            if gen.bus == bus:
                Qgen += model.Qgen[gen.id]

        for line in self.system.lines:
            if line.from_bus == bus:
                Qflow += model.Qflow[line.from_bus, line.to_bus]

        for line in self.system.lines:
            if line.to_bus == bus:
                Qflow += model.Qflow[line.to_bus, line.from_bus]

        return Qgen == self.system.get_bus(bus).Qload + Qflow
    
    def __optim_constr_line_P_fromto(self, model, line):
        i = self.system.get_line(line).from_bus
        k = self.system.get_line(line).to_bus

        return model.Pflow[i,k] == ((-self.system.G[i,k] + self.system.g[i,k])*model.V[i]**2 + model.V[i]*model.V[k]*(self.system.G[i,k]*cos(model.theta[i] - model.theta[k]) + self.system.B[i,k]*sin(model.theta[i] - model.theta[k])))
    
    def __optim_constr_line_P_tofrom(self, model, line):
        i = self.system.get_line(line).to_bus
        k = self.system.get_line(line).from_bus

        return model.Pflow[i,k] == ((-self.system.G[i,k] + self.system.g[i,k])*model.V[i]**2 + model.V[i]*model.V[k]*(self.system.G[i,k]*cos(model.theta[i] - model.theta[k]) + self.system.B[i,k]*sin(model.theta[i] - model.theta[k])))
    
    def __optim_constr_line_Q_fromto(self, model, line):
        i = self.system.get_line(line).from_bus
        k = self.system.get_line(line).to_bus

        return model.Qflow[i,k] == ((self.system.B[i,k] - self.system.b[i,k])*model.V[i]**2 + model.V[i]*model.V[k]*(-self.system.B[i,k]*cos(model.theta[i] - model.theta[k]) + self.system.G[i,k]*sin(model.theta[i] - model.theta[k])))
    
    def __optim_constr_line_Q_tofrom(self, model, line):
        i = self.system.get_line(line).to_bus
        k = self.system.get_line(line).from_bus

        return model.Qflow[i,k] == ((self.system.B[i,k] - self.system.b[i,k])*model.V[i]**2 + model.V[i]*model.V[k]*(-self.system.B[i,k]*cos(model.theta[i] - model.theta[k]) + self.system.G[i,k]*sin(model.theta[i] - model.theta[k])))
    
    def __optim__constr_line_max_mva_fromto(self, model, line):
        # Get apparent power

        line_obj = self.system.get_line(line)

        return model.Pflow[line_obj.from_bus, line_obj.to_bus]**2 + model.Qflow[line_obj.from_bus, line_obj.to_bus]**2 <= line_obj.mva**2
    
    def __optim__constr_line_max_mva_tofrom(self, model, line):
        # Get apparent power
        line_obj = self.system.get_line(line)

        return model.Pflow[line_obj.to_bus, line_obj.from_bus]**2 + model.Qflow[line_obj.to_bus, line_obj.from_bus]**2 <= line_obj.mva**2
    
    
    
    

        
    
