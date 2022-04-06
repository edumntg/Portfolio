function [c, ceq] = NonLin2(x, t, Pload_vector, Ppeak_ini, ndch, ncha, SOC_ini, SOC_fin, SOC_old, t_last)
    
    ceq = [];
    Pload_t = Pload_vector(t);

    Ppeak = x(1);
    Psch = x(2);
    Pgrid = x(3);
    udch = x(4);
    Pdch = x(5);
    ucha = x(6);
    Pcha = x(7);
    
    SOC = x(8);
    
    if t == 1
        c(1) = Ppeak - max(Pload_t - Psch, Pload_t - Ppeak_ini);
        c(2) = max(Pload_t - Psch, Pload_t - Ppeak_ini) - Ppeak;
    else
        c(1) = Ppeak - (Pload_t - Psch);
        c(2) = (Pload_t - Psch) - Ppeak;
    end
    
    c(3) = Pgrid - Pload_t - (udch*Pdch - ucha*Pcha);
    c(4) = (udch*Pdch - ucha*Pcha) + Pload_t - Pgrid;
    c(5) = Psch - udch*Pdch + ucha*Pcha;
    c(6) = -ucha*Pcha + udch*Pdch - Psch;
    c(7) = udch + ucha - 1;
    c(8) = 1 - udch - ucha;
    
    c(9) = SOC - SOC_old + udch*Pdch*ndch - ucha*Pcha*ncha;
    c(10) = -SOC + SOC_old - udch*Pdch*ndch + ucha*Pcha*ncha;
    v = 11;
    if t == 1
        c(11) = SOC - SOC_ini;
        c(12) = SOC_ini - SOC;
        v = 13;
    end
    
    if t == t_last
        c(11) = SOC - SOC_fin;
        c(12) = SOC_fin - SOC;
        v = 13;
    end
    
    c(v) = Pload_t - Psch - Ppeak;
    
    
    
    

end