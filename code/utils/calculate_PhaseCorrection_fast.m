function [phaseRamp] = calculate_PhaseCorrection_fast(kdata_phasecor, nx, nAcq, index_closest)
% CALCULATE_PHASECORRECTION_FAST Calculates a phase ramp for each spoke of a pole-to-pole Phyllotaxis trajectory for gradient delay correction. (2025)
%
%   [phaseRamp] = calculate_PhaseCorrection_fast(kdata_phasecor, nx, nAcq, index_closest)
%
%   Description:
%       Computes a phase ramp from k-space data by comparing spokes with their
%       closest opposing vectors. Useful for correcting phase inconsistencies
%       in 3D pole-to-pole phyllotaxis acquisitions.
%
%   Inputs:
%       kdata_phasecor - k-space data used for phase correction [kx, spokes, coils]
%       nx             - Number of readout points per spoke
%       nAcq           - Number of spokes
%       index_closest  - Indices of closest opposing spokes (from find_closest_opposing_vectors.m)
%
%   Outputs:
%       phaseRamp      - Computed phase ramp for phase correction of kdata_phasecor
%
%   Authors:
%       Joseph Woods and Eva S. Peper (evaspeper@gmail.com)
%
%   Notes:
%       - Ensure kdata_phasecor and index_closest dimensions are consistent.
%       - The function assumes steady-state conditions for accurate phase correction.

% iFFT
kdata_phasecor_iFFT = ifft1c_mri(kdata_phasecor);

% Precompute x-axis and valid indices
x = linspace(-nx/2, nx/2, nx)';
ind_center = abs(x) == min(abs(x));

phaseRamp = zeros(nx, nAcq, 'like', kdata_phasecor_iFFT);

for indAcq = 1:nAcq

    % Define spokes
    dataPos = kdata_phasecor_iFFT(:, indAcq, :, :, :);
    dataNeg = kdata_phasecor_iFFT(end:-1:1, index_closest(indAcq), :, :, :);

    % Conjugate phase difference and coil combination
    data_conjDiff = double(squeeze(sum(dataPos .* conj(dataNeg), 5)));
    phase = angle(data_conjDiff); % phase difference

    theta = unwrap(phase, 3*pi/2, 1); % unwrapped phase difference
    theta = theta - mean(theta(ind_center,:),1) + mean(phase(ind_center,:),1); % shift phase
    theta = theta / 2;

    % Weighted normalization
    mag = sqrt(abs(data_conjDiff)); % mean magnitude
    mag = mag ./ prctile(mag, 95, 1); % normalize

    % Vectorized robust linear fit using weighted least squares
    w = mag(:,1);
    w(w < 0.01) = 0; % apply exclusion threshold on magnitude images for fitting
    wx = w .* x;
    W = sum(w);
    x_mean = sum(wx) / W;
    theta_mean = sum(w .* theta(:,1)) / W;
    slope = sum(w .* (x - x_mean) .* (theta(:,1) - theta_mean)) / sum(w .* (x - x_mean).^2);
    intercept = theta_mean - slope * x_mean;

    % Phase ramp
    phaseRamp(:, indAcq) = slope * x + intercept;
    % phaseRamp(:, indAcq) = slope * x; % use slope only
    % phaseRamp(:, indAcq) = intercept; % use intercept only

end
end
