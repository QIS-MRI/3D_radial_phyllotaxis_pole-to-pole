% Calculate and plot 3D radial phyllotaxis trajectory
% Author: Eva Peper
% Date: 28/08/2024

%% Initialization
close all;
N           = 128;  % Number of readout points
nshot       = 89;   % Number of shots
nseg        = 200;  % Number of segments
traj_design = 2;    % Trajectory design: 0 = original, 1 = pole-to-pole, 2 = continuous

%% Calculate trajectory
flagSelfNav = 1;

switch traj_design
    case 0
        [polarAngle, azimuthalAngle, vx, vy, vz] = phyllotaxis3D_original(nshot, nseg, flagSelfNav);
    case 1
        [polarAngle, azimuthalAngle, vx, vy, vz] = phyllotaxis3D_poletopole(nshot, nseg, flagSelfNav);
    case 2
        [polarAngle, azimuthalAngle, vx, vy, vz] = phyllotaxis3D_continuous(nshot, nseg, flagSelfNav);
end

% Plot the trajectory
t = figure('Color', 'White', 'Position', [100, 100, 900, 400]);

% Plot the 3D trajectory for 5 interleaves
subplot(1, 2, 1);
for i = 1:5
    plot3(vx(1, (i-1)*nseg+1:i*nseg), vy(1, (i-1)*nseg+1:i*nseg), vz(1, (i-1)*nseg+1:i*nseg), ...
        '.-', 'Markersize', 10, 'LineWidth', 2); grid on;
    hold on;
end
xlabel('x'); ylabel('y'); zlabel('z');
axis([-1 1 -1 1 -1 1])
title('Trajectory for 5 interleaves');

% Plot polar and azimuthal angles for the first interleave
subplot(1, 2, 2);
i = 1;
plot(polarAngle(1, (i-1)*nseg+1:i*nseg), '.-', 'Markersize', 10, 'LineWidth', 2); hold on;
plot(azimuthalAngle(1, (i-1)*nseg+1:i*nseg), '.-', 'Markersize', 10, 'LineWidth', 2); grid on;
legend('Polar angle', 'Azimuthal angle');
xlabel('#Segments'); ylabel('Angle [rad]');
title('Azimuthal and polar angle for one interleave');
exportgraphics(t,[path,'trajectory_continuous.png'],'Resolution',400)

%% Trajectory in k-space convetions for IDEA and MATLAB reconstruction

% Define readout
r = (-0.5 : 1/N : 0.5-(1/N));

% Replicate angles for readout
azimuthal = repmat(azimuthalAngle, [N, 1]);
polar     = repmat(pi/2 - polarAngle, [N, 1]); % is defined like this in IDEA
R         = repmat(r', [1, nshot * nseg]);

% Convert spherical coordinates to Cartesian coordinates
[kx, ky, kz] = sph2cart(azimuthal, polar, R);

% Reshape the coordinates
kx = reshape(kx, [N, nseg, nshot]);
ky = reshape(ky, [N, nseg, nshot]);
kz = reshape(kz, [N, nseg, nshot]);

% Trajectory used for reconstruction
Traj3D   = cat(4, kx, ky, kz);
Traj3D   = reshape(Traj3D,[N, nseg*nshot, 1, 3]);
