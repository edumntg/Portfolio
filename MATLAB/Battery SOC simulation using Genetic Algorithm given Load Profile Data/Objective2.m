function f = Objective2(x, Cene, Pload_vector, t)
    Psch = x(2);
    Pload_t = Pload_vector(t);
    f = Cene(t)*(Pload_t - Psch);
end