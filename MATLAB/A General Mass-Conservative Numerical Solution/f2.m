function ret = f2(x, H, K, dK, C, i, n, dt, dz)
    dH = (x - H(i,n))/dt;
    gammaH = (H(i+1,n) - H(i-1,n))/(2*dz);
   
    
    
%     deltaH = (H(i+1, n) - 2*H(i,n) + H(i-1,n))/(dz^2);
    
    
    f = 1e5*(C(i)*dH - (dK(i)*gammaH + K(i)*gammaH^2) - dK(i)*gammaH);
    
    ret = f;
end