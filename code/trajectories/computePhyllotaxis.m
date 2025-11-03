function [x, y, z, azimuthal, polar, R] = computePhyllotaxis (N, nseg, nshot, flagSelfNav, flagTrajDesign)
% COMPUTEPHYLLOTAXIS  Computes a 3D phyllotaxis trajectory for MRI sampling. 
%
%   [x, y, z, azimuthal, polar, R] = computePhyllotaxis(N, nseg, nshot, flagSelfNav, flagTrajDesign)
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
%
%   Outputs:
%       x, y, z        - Cartesian coordinates of the phyllotaxis trajectory with dimensions: [N, nseg, nshot]
%       azimuthal      - Azimuthal angles (radians) with dimensions: [N, nseg*nshot]
%       polar          - Polar angles (radians) with dimensions: [N, nseg*nshot]
%       R              - K-space readout with the range [-0.5 0.5]
%
%   Description:
%       Computes a 3D phyllotaxis-based k-space sampling trajectory, with
%       different trajectory designs.
%
%   Authors:
%       Davide Piccini: Original phyllotaxis implementation
%       Eva S Peper: Pole-to-pole and continuous phyllotaxis implementation (evaspeper@gmail.com)

if nargin < 5
    flagTrajDesign = false;
end

if flagTrajDesign == 0 
    [polarAngle, azimuthalAngle, ~, ~, ~] = phyllotaxis3D_original(nshot, nseg, flagSelfNav);
elseif flagTrajDesign == 1
    [polarAngle, azimuthalAngle, ~, ~, ~] = phyllotaxis3D_poletopole(nshot, nseg, flagSelfNav);
elseif flagTrajDesign == 2
    [polarAngle, azimuthalAngle, ~, ~, ~] = phyllotaxis3D_continuous(nshot, nseg, flagSelfNav);
end

% Define readout
r = (-0.5 : 1/N : 0.5-(1/N));

% Replicate angles for readout
azimuthal = repmat(azimuthalAngle, [N, 1]);
polar     = repmat(pi/2 - polarAngle, [N, 1]); 
R         = repmat(r', [1, nshot * nseg]);

% Convert spherical coordinates to Cartesian coordinates
[x, y, z] = sph2cart(azimuthal,polar,R);

% Reshape the coordinates
x = reshape(x, [N, nseg, nshot]);
y = reshape(y, [N, nseg, nshot]);
z = reshape(z, [N, nseg, nshot]);
