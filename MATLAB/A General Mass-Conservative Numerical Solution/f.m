function ret = f(x, H, K, theta, i, n, dt, dz)
    C = (theta(i+1) - theta(i))/dz;
    
    dK = (K(i+1) - K(i))/dz;
    dH = (x - H(n,i))/dt;
    
    d2Hz = (H(n,i+1) - 2*H(n,i) + H(n,i-1))/dz^2; 
    
    ret = 1e6*(C*dH - (dK*(dH)^2 + K(i)*d2Hz) - dK);  
end