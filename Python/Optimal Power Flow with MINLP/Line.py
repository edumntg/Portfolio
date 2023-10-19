import numpy as np
class Line(object):
    def __init__(self, data):
        self.id = int(data[0])
        self.from_bus = int(data[1])
        self.to_bus = int(data[2])
        self.R = data[3]
        self.X = data[4]
        self.Z = self.R + 1j*self.X
        self.B = data[5]
        self.a = data[6]
        #self.mva = data[7]
        self.mva = 100


    def Y(self):
        return 1.0/self.Z
    
    def S(self, P, Q):
        return np.linalg.norm(np.array([P, Q]))
    
    def Plosses(self, Pout, Pin):
        return Pout + Pin
    

    def __str__(self):
        return f"{self.id} - [{self.from_bus}, {self.to_bus}, {self.R}, {self.X}, {self.B}, {self.a}, {self.mva}]"
