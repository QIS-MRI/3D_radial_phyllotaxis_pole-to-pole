function [theta_closest, phi_closest, index_closest, distance_closest, angle_deg] = find_closest_opposing_vectors(theta, phi)
% FIND_CLOSEST_OPPOSING_VECTORS Finds closest opposing spoke. (2025)
%
%   [theta_closest, phi_closest, index_closest, distance_closest, angle_deg] = find_closest_opposing_vectors(theta, phi)
%
%   Description:
%       Finds the vector in a set of spherical coordinates that is closest 
%       to being opposite (antiparallel) to each input vector. This can be 
%       used for trajectory correction, or analysis of opposing k-space 
%       directions in MRI.
%
%   Inputs:
%       theta - Azimuthal angles of the input vectors (in radians)
%       phi   - Polar angles of the input vectors (in radians)
%
%   Outputs:
%       theta_closest     - Azimuthal angle of the closest opposing vector
%       phi_closest       - Polar angle of the closest opposing vector
%       index_closest     - Index of the closest opposing vector in the input set
%       distance_closest  - Euclidean distance (or angular distance) to the closest opposing vector
%       angle_deg         - Angle (in degrees) between the input vector and its closest opposing vector
%
%   Author:
%       Eva S Peper (evaspeper@gmail.com)

N = numel(theta);
theta = theta(:);
phi   = phi(:);

% === Step 1: Precompute Cartesian coordinates ===
[x_all, y_all, z_all] = sph2cart(theta, phi, 1);
cart_all = [x_all, y_all, z_all];

% === Step 2: Precompute opposing vectors ===
[tx, ty, tz] = sph2cart(theta + pi, -phi, 1);
cart_opp = [tx, ty, tz];

% === Step 3: Initialize output ===
index_closest    = nan(N,1);
distance_closest = nan(N,1);

% === Step 4: Process hemisphere groups separately ===
idx_north = find(phi > 0);
idx_south = find(phi <= 0);

% --- North hemisphere spokes ---
valid_idx_south = find(phi <= 0 & (1:N)' > 1000);
if ~isempty(valid_idx_south)
    Mdl_south = KDTreeSearcher(cart_all(valid_idx_south,:));
    [idx_nearest, dist_nearest] = knnsearch(Mdl_south, cart_opp(idx_north,:));
    index_closest(idx_north)    = valid_idx_south(idx_nearest);
    distance_closest(idx_north) = dist_nearest;
end

% --- South hemisphere spokes ---
valid_idx_north = find(phi > 0 & (1:N)' > 1000);
if ~isempty(valid_idx_north)
    Mdl_north = KDTreeSearcher(cart_all(valid_idx_north,:));
    [idx_nearest, dist_nearest] = knnsearch(Mdl_north, cart_opp(idx_south,:));
    index_closest(idx_south)    = valid_idx_north(idx_nearest);
    distance_closest(idx_south) = dist_nearest;
end

% === Step 5: Extract corresponding angles ===
theta_closest = theta(index_closest);
phi_closest   = phi(index_closest);

% === Step 6: Compute angular distance (in degrees) ===
dotp = sum(cart_all .* cart_all(index_closest,:), 2);
dotp = min(max(dotp, -1), 1); % numerical safety
angle_deg = 180-real(acosd(dotp)); % distance

end
