function ret = gammaF(M, dz, i, n)
    ret = (M(i+1,n) - M(i-1,n))/(2*dz);