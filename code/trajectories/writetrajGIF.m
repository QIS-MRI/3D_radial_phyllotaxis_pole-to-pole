%% Calculate phyllotaxis trajectory
%
%   Description:
%       Write GIFs for different phyllotaxis trajectories for visualization. (2024)
%
%   Authors:
%       Eva S Peper: Write GIF for different trajectories (evaspeper@gmail.com)

%% Initialization
clear; clc;
close all;
nshot       = 89;   % Number of nshot
nseg        = 200;  % Number of nsegs
sgflag      = 1;    % Self gating flag
nx          = 160;  % Points on readout
traj_design = 1;    % Trajectory design: 0 = original, 1 = pole-to-pole, 2 = continuous

[kx, ky, kz, azimuthal, polar, R] = ...
    computePhyllotaxis(nx, nseg, nshot, sgflag, traj_design);
Traj3D = cat(4, kx, ky, kz);
Traj3D = reshape(Traj3D,[nx, nseg*nshot, 1, 3]);

%% plot trajectory and write GIF

% plotting features
nshot_plot = 4;
skip_lines = 2;

colors = [
    0,       0.4470, 0.7410;
    0.9290,  0.6940, 0.1250;
    0.4940,  0.1840, 0.5560;
    0.4660,  0.6740, 0.1880;
    0.8500,  0.3250, 0.0980;
    0.3010,  0.7450, 0.9330;
    0.6350,  0.0780, 0.1840
    ];

if traj_design == 0
    name = 'original';
elseif traj_design == 1
    name = 'pole-to-pole';
elseif traj_design == 2
    name = 'continuous';
end

filename = ['trajectory_',num2str(name),'_nSeg',num2str(nseg),'_nShot',num2str(nshot),'.gif'];

f = figure('Position', [100 100 650 800], 'Color', 'White');

pause(0.025);

for w = 1:nshot_plot

    X = kx(:,:,w);
    Y = ky(:,:,w);
    Z = kz(:,:,w);

    axis([-0.6 0.6 -0.6 0.6 -0.6 0.6])

    for i = 1:skip_lines:nseg
        plot3(X(:, i), Y(:, i), Z(:, i), 'LineWidth', 3, 'Color', colors(w, :));
        view([-39 15])

        hold on;
        plot3(X(end, i), Y(end, i), Z(end, i), '.', 'MarkerSize', 25, 'Color', 'r');
        axis([-0.6 0.6 -0.6 0.6 -0.6 0.6])

        if i > 1
            plot3([X(end, i - 1), X(end, i)], [Y(end, i - 1), Y(end, i)], [Z(end, i - 1), Z(end, i)], '-r', 'LineWidth', 3);
            axis([-0.6 0.6 -0.6 0.6 -0.6 0.6])
        end

        xlabel('kx');
        ylabel('ky');
        zlabel('kz');
        set(gca, 'FontSize', 12);
        set(gca, 'LineWidth', 2);

        title([num2str(name),' phyllotaxis'], ...
            [num2str(nseg),' nsegs, ',num2str(nshot),' nshot'], 'FontSize', 12)
        grid on;

        % Capture the frame
        frame = getframe(f);
        im = frame2im(frame);
        [imind, cm] = rgb2ind(im, 256);
        axis([-0.6 0.6 -0.6 0.6 -0.6 0.6])

        % Write to the GIF file
        if  w == 1 && i==1
            imwrite(imind, cm, filename, 'gif', 'LoopCount', Inf, 'DelayTime', 0.1);
        else
            imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
        end
        pause(0.025);
    end

end

close(f);
