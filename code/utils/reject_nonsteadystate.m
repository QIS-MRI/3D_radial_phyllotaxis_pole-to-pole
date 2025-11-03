function [kdata, accepted] = reject_nonsteadystate(kdata, nPC, plotflag)
% REJECT_NONSTEADYSTATE Rejects spokes that are not yet in steady state. (2025)
%
%   [kdata, accepted] = reject_nonsteadystate(kdata, nPC, plotflag)
%
%   Description:
%       Identifies and rejects non-steady-state spokes for each phase cycle
%       based on the k-space center magnitude and a standard deviation
%       threshold. Useful for improving bSSFP reconstruction quality by
%       removing inconsistent acquisitions.
%
%   Inputs:
%       kdata    - k-space data array [kx, spokes, phase cycles, coils]
%       nPC      - Number of phase cycles
%       plotflag - Set to 1 to display plots
%
%   Outputs:
%       kdata    - Original k-space data (unchanged, retained for compatibility)
%       accepted - Indices of spokes accepted as steady-state
%
%   Author:
%       Eva S Peper (evaspeper@gmail.com)
%
%   Notes:
%       - Ensure the kdata array dimensions match [kx, spokes, phase cycles, coils].
%       - Plots help visualize which spokes were rejected.

%% Default arguments
if nargin < 3
    plotflag = 1;
end

ntviews = size(kdata, 2);
rejected = ones(ntviews, nPC); % initialize rejection mask

if plotflag
    figure('Color','w','Position',[100 100 1300 400]);
    subplot(1,2,1);
end

%% Process each phase cycle
exclude_end = 100; % exclude end spokes for STD calculation
last_frac   = 0.8; % fraction of spokes to consider for mean/STD

for n = 1:nPC

    % Extract and smooth k-space center for this phase-cycle using one coil
    kc = abs(kdata(size(kdata,1)/2+1, :, n, 1));
    sm_data = smoothdata(kc, 'gaussian', 10);

    % Define range for statistics (last 20% excluding end spokes)
    idx = ntviews - round(last_frac*ntviews) + 1 : ntviews - exclude_end;

    % Use STD of the first PC (n=1) to threshold all PCs
    m1(n) = std(sm_data(idx));
    m2(n) = max(sm_data(idx)) + m1(1);
    m3(n) = min(sm_data(idx)) - m1(1);

    % Plot STD calculation
    if plotflag && n==1 % only first PC
        plot(1:numel(kc), kc,'.-'); hold on;
        ylabel('magnitude [a.u.]'); xlabel('spokes');
        title('spokes for STD calculation');
    end

    if plotflag && n==1 % only first PC
        plot(1:size(sm_data,2), sm_data,'.-'); hold on;
        yline(m2(n)); hold on;
        yline(m3(n)); hold on;
        legend('raw k-space center', 'smoothed k-space center','+1 STD','-1 STD');
        axis([1 size(sm_data,2) min(sm_data(:)) max(sm_data(:))])
    end

    % Reject data outside bounds
    rejected(sm_data > m2(n), n) = 0;
    rejected(sm_data < m3(n), n) = 0;

    % Find last index where array is 0
    lastZero = find(rejected == 0, 1, 'last');
    if ~isempty(lastZero)
        rejected(1:lastZero)=0;
    end

    sm_data_tmp(:,n) = sm_data;
end

%% Align thresholds for plotting
ind    = 1:nPC;
tmp2   = reshape(repmat(m2, [1 1 ntviews]), [1 nPC*ntviews]);
tmp3   = reshape(repmat(m3, [1 1 ntviews]), [1 nPC*ntviews]);
tmpind = reshape(repmat(ind,[1 1 ntviews]), [1 nPC*ntviews]);
[~, b] = sortrows(tmpind', 'ascend');
m2     = tmp2(b);
m3     = tmp3(b);

sm_data_plot = reshape(sm_data_tmp, [1 nPC*ntviews]);

%% Find accepted spokes for multiple phase-cycles
rejected_tmp = ones(size(sm_data_plot));
rejected_tmp(sm_data_plot > m2) = 0;
rejected_tmp(sm_data_plot < m3) = 0;
rejected_tmp = reshape(rejected_tmp, [ntviews nPC]);

% Find last index where array is 0 for each phase-cycle
for n = 1:nPC
    lastZero = find(rejected_tmp(:,n) == 0, 1, 'last');

    if ~isempty(lastZero)
        rejected_tmp(1:lastZero,n)=0;
    end
end

% crop to shortest as all phase-cycles need the same amount of spokes
rejected_tmp = sum(rejected_tmp, 2);
accepted = find(rejected_tmp == max(rejected_tmp));

%% Plot results
if plotflag
    subplot(1,2,2);
    for n = 1 % only first PC
        plot(1:size(sm_data_tmp,1), sm_data_tmp(:,n), '.-'); hold on;
        plot(accepted, sm_data_tmp(accepted,n), '.-');
        axis([1 size(sm_data_tmp,1) min(sm_data_tmp(:,n)) max(sm_data_tmp(:,n))])
    end
    legend('smoothed k-space center', 'accepted spokes');
    ylabel('magnitude [a.u.]'); xlabel('spokes');
    title('accepted data');
end

end
