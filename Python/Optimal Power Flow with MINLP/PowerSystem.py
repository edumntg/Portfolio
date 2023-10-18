import numpy as np
import pyomo.environ as pyomo_env

class PowerSystem(object):

    def __init__(self, data: dict):
        self.buses = data['buses']
        self.lines = data['lines']
        self.generators = data['generators']
        self.base = data['base']

        self.Ybus = None
        self.N = len(self.buses)
        self.b = None
        self.g = None
        self.G = None
        self.B = None

    def construct_ybus(self) -> np.array:
        self.Ybus = np.zeros((self.N, self.N))
        self.b = np.zeros((self.N, self.N))
        self.g = np.zeros((self.N, self.N))

        # Loop through lines
        for id, line in self.lines.items():
            from_bus = int(line[0])-1
            to_bus = int(line[1])-1
            R = line[2] # Resistance
            X = line[3] # Reactance
            B = line[4] # Shunt
            a = line[5] # Tap

            # Create impedance
            Z = R + 1j*X

            self.Ybus[from_bus,from_bus] += 1/(Z*a**2)
            self.Ybus[to_bus,to_bus] += 1/(Z*a**2)

            self.Ybus[from_bus,to_bus] -= 1/(Z*a)
            self.Ybus[to_bus,from_bus] -= 1/(Z*a)

            # Add shunts
            self.Ybus[from_bus,from_bus] += 1j*B
            self.Ybus[to_bus,from_bus] += 1j*B

            self.b[from_bus,to_bus] = B.imag
            self.b[to_bus,from_bus] = B.imag
            
        self.G = self.Ybus.real
        self.B = self.Ybus.imag

        return self.Ybus, self.G, self.B, self.g, self.b
        

        

    
