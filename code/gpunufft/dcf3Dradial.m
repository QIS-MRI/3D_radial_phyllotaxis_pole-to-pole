function [wcut,w] = dcf3Dradial (N,NProj,filterFactor)

% ------------------------------
% Non Cartesian Reconstruction
% compute density compensation function for 3D radial
% adapted from Siemens code, nonCartesianFunctor.cpp
% ------------------------------
% Author: Gabriele Bonanno
% Date: November 2012
% ------------------------------

k = -N/2 : 1 : N/2-1;
k(end + 1) = N/2; 
w = zeros(1,length(k));

% The factor of two considers readout oversampling
nyqDiameter = filterFactor * 2.0 * sqrt (2. * NProj / pi ); 

if (nyqDiameter > N)
   nyqDiameter = N; 
end

for i = 2: N    
        w(i) = ( pi * abs ( (k(i) + k(i+1))^3 - (k(i) + k(i-1))^3 ) ) / (6 * NProj);
end
w(1) = 2.0 * w(N) - w(N-1);

wcut = w;

for i = N/2+1 : N            
    if abs(k(i)) < (nyqDiameter / 2)
               nyqDensity = wcut(i);                
    end
end

for i = 1 : N
    if abs(k(i)) > (nyqDiameter / 2)                
                wcut(i) = nyqDensity;
    end
end

maxNorm = max(w);
maxNormcut = max(wcut);

w = w / maxNorm;
wcut = wcut / maxNormcut;

w = w(1:end-1);
wcut = wcut(1:end-1);
k = k(1:end-1);
 

