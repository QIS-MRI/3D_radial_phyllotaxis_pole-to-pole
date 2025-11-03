function [T1w_est,T2w_est, off, M0] = ORACLE(bSSFPSignal,TR,alpha,VZ)
% ORACLE T1 and T2 mapping using phase-cycled bSSFP. (2024)
%
%   [T1w_est, T2w_est, off, M0] = ORACLE(bSSFPSignal, TR, alpha, VZ)
%
%   Description:
%       Estimates tissue parameters (T1, T2, off-resonance, and proton density)
%       from a complex-valued bSSFP signal profile using the ORACLE method.
%
%   Inputs:
%       bSSFPSignal - Complex-valued bSSFP signal profile
%       TR          - Repetition time (milliseconds)
%       alpha       - RF flip angle (radians)
%       VZ          - Sign: +1 or -1 depends on the MRI system
%
%   Outputs:
%       T1w_est - Estimated T1 relaxation time
%       T2w_est - Estimated T2 relaxation time
%       off     - Estimated off-resonance (gamma * ΔB0 * TR)
%       M0      - Estimated proton density
%
%   Author:
%       Nils Plaehn: ORACLE method development and implementation.
%
%   Citation:
%       When using this code, please cite:
%       Plaehn N et al., ORACLE: An analytical approach for T1, T2, proton density,
%       and off-resonance mapping with phase-cycled balanced steady-state
%       free precession, MRM, 2024

% Phase cycles
nPC  = numel(bSSFPSignal);
phi1 = linspace(0,2*pi,nPC+1);
phi  = circshift(phi1(1:nPC),4,1);

% Modes
cm1 = NPointFT(bSSFPSignal,-1.*VZ,phi);
c0  = NPointFT(bSSFPSignal,0,phi);
c1  = NPointFT(bSSFPSignal,1.*VZ,phi);

% T2 estimation
q       = abs(conj(c1))/abs((cm1));
r       = abs(c1)/abs(c0);
E2      = abs((1+q).*r./(q+r^2));
T2w_est = abs(-TR./log(E2));

% T1 estimation
a       = E2-2*r+E2*r^2;
b       = E2*(1-2*E2*r+r^2);
Zaehler = a+b*cos(alpha);
Nenner  = b+a*cos(alpha);
E1      = abs(Zaehler/Nenner);
T1w_est = abs(-TR./log(E1));

% PD estimation
M0 = (abs(c0)+abs(c0*cm1/c1))/(abs(E2)^0.5);

% off estimation
zw  = c1/c0;
off = angle(zw);
end

function Gp = NPointFT(MatInput,order,phi)
N = numel(MatInput);
tmp = 0;
for j = 1:N
    tmp = MatInput(j).*exp(-1i.*order.*phi(j))+tmp;
end
Gp = 1./N.*tmp;
end

