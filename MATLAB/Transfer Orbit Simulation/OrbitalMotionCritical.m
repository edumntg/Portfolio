function df = OrbitalMotionCritical(vars, mu)

    % Define variables
    x = vars(1);
    u = vars(2);
    y = vars(3);
    v = vars(4);
    z = vars(5);
    w = vars(6);
    
    dx = u;
    du = 2*v + x - mu*(-1 + x + mu)/(y^2 + z^2 +(-1 + x + mu)^2)^(3/2) - (1-mu)*(x+mu)/(y^2 + z^2 + (x+mu)^2)^(3/2);
    dy = v;
    dv = -2*u + y - mu*y/(y^2 + z^2 + (-1 + x + mu)^2)^(3/2) - (1-mu)*y/(y^2 + z^2 + (x+mu)^2)^(3/2);
    dz = w;
    dw = -mu*z/(y^2 + z^2 + (-1 + x + mu)^2)^(3/2) - (1-mu)*z/(y^2 + z^2 + (x+mu)^2)^(3/2);
    
    df = [dx;du;dy;dv;dz;dw];
end