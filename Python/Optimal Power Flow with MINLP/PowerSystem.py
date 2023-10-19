import numpy as np
import pyomo.environ as pyomo_env
from Bus import *
from Line import *
from Generator import *

class PowerSystem(object):

    def __init__(self, data: dict):
        self.buses_raw = data['buses']
        self.lines_raw = data['lines']
        self.generators_raw = data['generators']

        # Initialize buses, lines and generators
        self.buses = []
        for id, data in self.buses_raw.items():
            bus = Bus(data)
            self.buses.append(bus)

        self.lines = []
        for id, data in self.lines_raw.items():
            line = Line([id] + data)
            self.lines.append(line)

        self.generators = []
        for id, data in self.generators_raw.items():
            gen = Generator([id] + data)
            self.generators.append(gen)

        self.Ybus = None
        self.N = len(self.buses)

        self.n_buses = len(self.buses)
        self.n_lines = len(self.lines)
        self.n_gens = len(self.generators)

        self.b = None
        self.g = None
        self.G = None
        self.B = None

    def construct_ybus(self) -> np.array:
        self.Ybus = np.zeros((self.N, self.N), dtype="complex_")
        self.b = np.zeros((self.N, self.N))
        self.g = np.zeros((self.N, self.N))

        # Loop through lines
        for line in self.lines:

            self.Ybus[line.from_bus, line.from_bus] += line.Y() * (1.0/line.a**2)
            self.Ybus[line.to_bus, line.to_bus] += line.Y() * (1.0/line.a**2)

            self.Ybus[line.from_bus, line.to_bus] -= line.Y() * 1.0/line.a
            self.Ybus[line.to_bus, line.from_bus] -= line.Y() * 1.0/line.a

            # Add shunts
            self.Ybus[line.from_bus, line.from_bus] += 1j*line.B
            self.Ybus[line.to_bus, line.from_bus] += 1j*line.B

            self.b[line.from_bus, line.to_bus] = line.B
            self.b[line.to_bus, line.from_bus] = line.B
            
        self.G = self.Ybus.real
        self.B = self.Ybus.imag

        return self.Ybus, self.G, self.B, self.g, self.b
    
    def get_gen(self, id):
        for gen in self.generators:
            if gen.id == id:
                return gen
            
        return None
    
    def get_bus(self, id):
        for bus in self.buses:
            if bus.id == id:
                return bus
        
        return None

    def get_line(self, id):
        for line in self.lines:
            if line.id == id:
                return line
            
        return None

        

    
