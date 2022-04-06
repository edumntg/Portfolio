function ret = f3(x, H, K, dK, C, i, n, dt, dz)
    dHdt = (x - H(i,n))/dt;
    dHdz = (H(i+1,n) - H(i,n))/dz;
    
    d2Hdz = (H(i+1,n) - 2*H(i,n) + H(i-1,n))/(dz^2);
    
    f = 1e3*(C(i)*dHdt - (dK(i)*dHdz^2 + K(i)*d2Hdz) - dK(i)*dHdz);
    
    ret = f;
end