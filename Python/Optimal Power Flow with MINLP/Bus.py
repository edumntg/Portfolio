class Bus(object):

    def __init__(self, data):
        self.id = int(data[0])
        self.V = data[2]
        self.theta = data[3]
        self.Pgen = data[4]
        self.Qgen = data[5]
        self.Pload = data[6]
        self.Qload = data[7]

    def __str__(self):
        return f"{self.id} - [{self.V}V, {self.theta}rads, P={self.Pgen}, Q={self.Qgen}]"

    