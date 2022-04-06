function f = Objective(x, Cdem)
    
    Ppeak = x(1);
    f = Cdem*Ppeak;
end