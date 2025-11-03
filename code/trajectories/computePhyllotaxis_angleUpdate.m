function [x, y, z,azimuthal,polar,R] = computePhyllotaxis_angleUpdate (N, nseg, nshot, flagSelfNav, flagTrajDesign, nPC)
% COMPUTEPHYLLOTAXIS_ANGLEUPDATE  Computes a 3D phyllotaxis trajectory for MRI sampling with different spokes per phase cycle (nPC). (2024)
%
%   [x, y, z, azimuthal, polar, R] = computePhyllotaxis_angleUpdate(N, nseg, nshot, flagSelfNav, flagTrajDesign, nPC)
%
%   Inputs:
%       N              - Number of readout points 
%       nseg           - Number of 'segments' (also called 'spokes per interleave')
%       nshot          - Number of 'interleaves' (also called 'shots')
%       flagSelfNav    - Logical flag if an SI spoke should be included (e.g. for self-gating)
%       flagTrajDesign - Logical flag controlling trajectory design 
%                        (0 = original phyllotaxis, 
%                         1 = pole-to-pole phyllotaxis, 
%                         2 = continuous phyllotaxis)
%       nPC            - Number of phase cycles (this dimension can also be use for other consecutive sampling, e.g. time points)
%
%   Outputs:
%       x, y, z        - Cartesian coordinates of the phyllotaxis trajectory with dimensions: [N, nseg, nshot]
%       azimuthal      - Azimuthal angles (radians) with dimensions: [N, nseg*nshot]
%       polar          - Polar angles (radians) with dimensions: [N, nseg*nshot]
%       R              - K-space readout with the range [-0.5 0.5]
%
%   Description:
%       Computes a 3D phyllotaxis-based k-space sampling trajectory, with
%       different trajectory designs. Updates the polar angle between phase
%       cycles so that no spokes are repeated.
%
%   Authors:
%       Davide Piccini: Original phyllotaxis implementation
%       Eva S Peper: Pole-to-pole and continuous phyllotaxis implementation (evaspeper@gmail.com)
%       Eva S Peper: Angle update implementation for phase cycles (evaspeper@gmail.com)

if nargin < 5
    flagTrajDesign = false;
end

if flagTrajDesign == 0
    [polarAngle, azimuthalAngle, ~, ~, ~] = phyllotaxis3D_angleUpdate_original(nshot, nseg, flagSelfNav, nPC);
elseif flagTrajDesign == 1 
    [polarAngle, azimuthalAngle, ~, ~, ~] = phyllotaxis3D_angleUpdate_poletopole(nshot, nseg, flagSelfNav, nPC);
elseif flagTrajDesign == 2
    [polarAngle, azimuthalAngle, ~, ~, ~] = phyllotaxis3D_angleUpdate_continuous(nshot, nseg, flagSelfNav, nPC);
end

% Define readout
r = (-0.5 : 1/N : 0.5-(1/N));

% Replicate angles for readout and PCs
azimuthal = repmat(azimuthalAngle, [N 1]);
polar     = repmat(pi/2 - polarAngle, [N 1]);
R         = repmat(r', [1 nshot*nseg nPC]); % including nPC

% Convert spherical coordinates to Cartesian coordinates
[x, y, z] = sph2cart(azimuthal,polar,R);

% Reshape the coordinates
x = reshape(x, [N, nseg, nshot, nPC]); % including nPC
y = reshape(y, [N, nseg, nshot, nPC]); % including nPC
z = reshape(z, [N, nseg, nshot, nPC]); % including nPC

