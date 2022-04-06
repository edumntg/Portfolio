function f = ImplicitSystemEq(x, H, dt, dz, Nz, n, htop, hbottom)
    global alpha theta_s theta_r beta A gamma Ks

    % Define the variables first
    v = 1;
    for i = 1:Nz
        H(i, n) = x(v);
        v = v + 1;
    end
    
    veq = 1;
	for i = 2:Nz-1
        
        K = Ks*A/(A + abs(H(i+1, n))^gamma);
        C = alpha*(theta_s - theta_r)*beta*abs(H(i+1,n))^(beta-1) /(alpha + abs(H(i+1,n))^beta)^2;
        dK = Ks*A*gamma*abs(H(i+1,n))^(gamma-1) /(A + abs(H(i+1,n))^gamma)^2;
        f(veq) = C*(H(i,n) - H(i,n-1))/dt - dK*((H(i,n) - H(i-1,n))/dz)^2 - K*(H(i+1,n) - 2*H(i,n) + H(i-1,n))/dz^2 - dK;
%         f(veq) = C*(H(i,n) - H(i,n-1))/dt - dK*(H(i,n) - H(i-1,n))/dz - K*(H(i+1,n) - 2*H(i,n) + H(i-1,n))/dz^2 - dK;
        veq = veq + 1;
    end
    
    f(veq) = H(1,n) - hbottom;
    f(veq+1) = H(Nz, n) - htop;
    
    
    f = 1e3.*f;
    
%     fprintf("Size x: %d\nSize f: %d\n", length(x), length(f));
    
end