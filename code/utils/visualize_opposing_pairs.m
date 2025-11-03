function visualize_opposing_pairs(Traj3D, index_closest, n_show)
% VISUALIZE_OPPOSING_PAIRS Plot spokes and opposing spokes. (2025)
%
%   visualize_opposing_pairs(Traj3D, index_closest, n_show)
%
%   Description:
%       Visualizes spokes from a 3D trajectory along with their
%       closest opposing vectors. Useful for inspecting k-space sampling
%       patterns or assessing trajectory symmetry in MRI.
%
%   Inputs:
%       Traj3D        - Nx3 array of Cartesian coordinates of the 3D trajectory
%       index_closest - Indices of the closest opposing vectors corresponding to Traj3D
%       n_show        - Number of vector pairs to display
%
%   Author:
%       Eva S Peper (evaspeper@gmail.com)
%
%   Notes:
%       - Ensure Traj3D and index_closest have consistent dimensions.
%       - The function highlights the first n_show opposing vector pairs.

if nargin < 3
    n_show = 50; % number of pairs to display
end

figure('Color','White','Position',[200 200 590 400]);
title('Opposing Spokes on Unit Sphere');

% Draw sphere outline
[Xs, Ys, Zs] = sphere(40);

for index = 1:n_show

    % Plot starting points of each spoke
    plot_limit = floor(size(Traj3D,1)/3);
    plot3(Traj3D(1:plot_limit,[index,index_closest(index)],1,1),...
        Traj3D(1:plot_limit,[index,index_closest(index)],1,2),...
        Traj3D(1:plot_limit,[index,index_closest(index)],1,3),'LineWidth',3);
    xlim([-.5,.5]); ylim([-.5,.5]); zlim([-.5,.5]);
    hold on;

    % plot full spokes
    plot3(Traj3D(1:size(Traj3D,1),[index,index_closest(index)],1,1),...
        Traj3D(1:size(Traj3D,1),[index,index_closest(index)],1,2),...
        Traj3D(1:size(Traj3D,1),[index,index_closest(index)],1,3),'LineWidth',1,'Color',[0 0 0]);
    surf(Xs/2, Ys/2, Zs/2, 'FaceAlpha', 0.05, 'EdgeColor', [0.7 0.7 0.7]); hold on;
    xlim([-.5,.5]); ylim([-.5,.5]); zlim([-.5,.5]);

    xlabel('kx'); ylabel('ky'); zlabel('kz');
    legend('Spoke','Opposing spoke')
    hold off;
    pause(0.1);
end

end
