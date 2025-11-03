%% GPUNUFFT Reconstruction Code for 3D Radial MRI Data
%
%   Description:
%       Reconstructs and analyzes MRI images from raw data acquired with
%       3D phyllotaxis trajectories, as described in Peper et al., MRM 2025.
%
%   Inputs:
%       Siemens raw (.dat) data acquired with a 3D radial trajectory, for
%       example using Pulseq and the corresponding .seq file provided in
%       this repository under: /sequences/
%
%   Requirements:
%       K-space data can be loaded and visualized. Image reconstruction
%       requires installation and compilation of the gpuNUFFT toolbox
%       (https://github.com/andyschwarzl/gpuNUFFT).
%       Precompiled gpuNUFFT .mex files for Linux are available in:
%       /gpunufft/@gpuNUFFT_nt/private/
%
%   Authors:
%       Li Feng: Original 3D radial gpuNUFFT implementation
%       Eva S Peper: Extended implementation for sorting and reconstructing
%                    phase-cycled bSSFP data, including rejection of
%                    non–steady-state spokes, and development of pole-to-pole
%                    and continuous phyllotaxis trajectory designs.
%                    Added correction methods using opposing spokes.
%                    (evaspeper@gmail.com)
%       Joseph Woods: Work on calculate_PhaseCorrection_fast.m
%
%   Citation:
%       When using this code, please cite:
%           Peper et al., MRM 2025
%           Schwarzl et al., gpuNUFFT toolbox

clear; clc; close all;

%% Add paths for GPUNUFFT and ORACLE

% add gpunufft paths 
% https://cai2r.net/resources/gpunufft-an-open-source-gpu-library-for-3d-gridding-with-direct-matlab-interface/
addpath('/gpuNUFFT-master/CUDA/bin');
addpath(genpath('/gpuNUFFT-master/gpuNUFFT/'));

% add code paths
addpath(genpath(pwd));

%% Select raw data file

startPath = '/datapath/';   % dowlnload on https://zenodo.org/uploads/17428583
[file, path] = uigetfile('*.dat','Select raw .dat file',startPath);

%% Reconstruction flags

% settings for Recon Experiment 1.1 - Recon Experiment 2.2
path = '/datapath/'      % dowlnload on https://zenodo.org/uploads/17428583
file = 'Scan02_Original_200x89_1389BW_TRA.dat'
cc                  = 1;  % coil compression = 1, coil selection = 0
ncc                 = 12;  % number of compressed or selected coils
nPC                 = 1;  % number of phase-cycles
traj_design         = 1;  % trajectory mode: 0 = original phyllotaxis, 1 = pole-to-pole phyllotaxis, 2 = continuous phyllotaxis
sgflag              = 1;  % included SI projection during acquisitison
phase_correction    = 0;  % phase corrections 
experiment          = 0;  % which recon experiment: 0 = nothing additional, 2 = devide into hemispheres, 3 = four repetitions
spokes_to_keep      = 0;  % for experiment 2: 0 = keep top spokes, 1 = keep bottom spokes
GD_correction       = 0;  % apply gradient delay correcton

% % settings for Recon Experiment 2.3
% path = '/datapath/'     % dowlnload on https://zenodo.org/uploads/17428583
% file = 'Scan07_PoleToPole_200x89_1389BW_TRA.dat'
% cc                = 1;  % coil compression = 1, coil selection = 0
% ncc               = 12; % # compressed or selected coils
% nPC               = 1;  % number of phase-cycles
% traj_design       = 1;  % trajectory mode: 0 = original phyllotaxis, 1 = pole-to-pole phyllotaxis, 2 = continuous phyllotaxis
% sgflag            = 1;  % include SI projection
% phase_correction  = 0;  % phase correction 
% experiment        = 2;  % which recon experiment: 0 = nothing additional, 2 = devide into hemispheres, 3 = four repetitions
% spokes_to_keep    = 0;  % for experiment 2: 0 = keep top spokes, 1 = keep bottom spokes
% GD_correction     = 1;  % apply gradient delay correcton

% % settings for Experiment 2.4
% path = '/datapath/'     % dowlnload on https://zenodo.org/uploads/17428583
% file = 'Scan17_PoleToPole_200x89_1389BW_TRA_4Repetitions.dat'
% cc                = 1;  % coil compression = 1, coil selection = 0
% ncc               = 12; % # compressed or selected coils
% nPC               = 1;  % number of phase-cycles
% traj_design       = 1;  % trajectory mode: 0 = original phyllotaxis, 1 = pole-to-pole phyllotaxis, 2 = continuous phyllotaxis
% sgflag            = 1;  % include SI projection
% phase_correction  = 0;  % phase correction 
% experiment        = 3;  % which recon experiment: 0 = nothing additional, 2 = devide into hemispheres, 3 = four repetitions
% spokes_to_keep    = 0;  % for experiment 2: 0 = keep top spokes, 1 = keep bottom spokes
% GD_correction     = 0;  % apply gradient delay correcton

%% Read raw data

data = mapVBVD([path file]);
if iscell(data)
    image_obj = data{end}.image;
else
    image_obj = data.image;
end
if length(image_obj) > 1
    image_obj = image_obj{end};
end

%% Get k-space data

nshot = image_obj.NSeg;
kdata = permute(image_obj.unsorted(), [1,3,2]);  % [readout, spokes, coils]
[nx, ntviews, nc] = size(kdata);

%% EXPERIMENT 2.4: Repeated spokes (nrep=4, select every 4th spoke)

if experiment == 3

    % reconstruct for each repetition (1 to 4) seperately
    nrep = 4;
    kdata_P1 = kdata(:, 1:nrep:end, :);
    kdata_P2 = kdata(:, 2:nrep:end, :);
    kdata_P3 = kdata(:, 3:nrep:end, :);
    kdata_P4 = kdata(:, 4:nrep:end, :);

    kdata = kdata_P1; % reconstruct first set
    [nx, ntviews, nc] = size(kdata);

end

%% nseg and recon resolution

nseg = ntviews / nshot / nPC;
N = [nx nx nx];

%% Compute phyllotaxis trajectory

if nPC>1

    % compute the phyllotaxis trajectory - for phase-cycling update the polar angle between nPCs
    [kx, ky, kz, azimuthal, polar, R] = ...
        computePhyllotaxis_angleUpdate (nx, nseg, nshot, sgflag, traj_design, nPC);
    Traj3D   = cat(5, kx, ky, kz);
    Traj3D   = reshape(Traj3D,[nx, nseg*nshot*nPC, 1, 3]);

else

    % compute the phyllotaxis trajectory
    [kx, ky, kz, azimuthal, polar, R] = ...
        computePhyllotaxis(nx, nseg, nshot, sgflag, traj_design);
    Traj3D = cat(4, kx, ky, kz);
    Traj3D = repmat(reshape(Traj3D,[nx, nseg*nshot, 1, 3]), [1 nPC 1 1]);

end

%% CORRECTION METHODS

%% simple phase correction

if phase_correction == 1

    kdata_cor = zeros(size(kdata));
    center   = size(kdata,1)/2 + 1;

    if 0 % apply conjugate phase for each spoke (cannot be used for quantitative mapping)

        for c = 1:size(kdata,3)
            ref_phase = angle(kdata(center,:,c));
            kdata_cor(:,:,c) = kdata(:,:,c) .* exp(-1i * ref_phase);
        end

    else % apply conjugate phase of opposing spoke

        do_plot_spokes = 1;

        % find closest opposing spoke
        for pc = 1:nPC
            [~, ~, index_closest(:,pc), ~, ang_deg(:,pc)] = find_closest_opposing_vectors((azimuthal(1,:,pc)), (polar(1,:,pc)));
        end
        index_closest = reshape(index_closest,[ntviews,1]);

        % mean distance between spokes (should be close to zero)
        fprintf('Mean angular distance: %.3f°\n', mean(ang_deg(:)));

        if do_plot_spokes
            visualize_opposing_pairs(Traj3D,index_closest,10)
        end

        % create fake, opposing kspace
        kdata_opposing = conj(kdata(:,index_closest,:));

        % phase correction
        for c = 1:size(kdata,3)
            ref_phase = angle(kdata_opposing(center,:,c));
            kdata_cor(:,:,c) = kdata(:,:,c) .* exp(-1i * ref_phase);
        end
    end

    % continue with corrected data
    kdata = kdata_cor;

end

%% Gradient delay (GD) correction
% adaped from Block and Uecker: Simple Method for Adaptive Gradient-Delay Compensation in Radial MRI. Proc. Intl. Soc. Mag. Reson. Med., 2011

if GD_correction

    do_plot_spokes = 1;

    % find closest opposing spoke
    for pc = 1:nPC
        [~, ~, index_closest(:,pc), ~, ang_deg(:,pc)] = find_closest_opposing_vectors((azimuthal(1,:,pc)), (polar(1,:,pc)));
    end
    index_closest = reshape(index_closest,[ntviews,1]);

    % mean distance between spokes (should be close to zero)
    fprintf('Mean angular distance: %.3f°\n', mean(ang_deg(:)));

    if do_plot_spokes
        visualize_opposing_pairs(Traj3D,index_closest,10)
    end

    % Compute phase ramp for each spoke
    phaseRamp = calculate_PhaseCorrection_fast(permute(kdata,[1 2 4 5 3]), nx, ntviews, index_closest);

    % apply phase correction as phase ramp in image space
    kdata = ifft1c_mri(ifft1c_mri(kdata) .* exp(-1i*phaseRamp)); 

end

%% Coil compression / selection

[nx,ntviews,nc]=size(kdata);
if nc > ncc && cc

    % coil compression
    D=reshape(kdata,nx*ntviews,nc); clear kdata
    [U,S,V]=svd(D,'econ'); clear U
    kdata=reshape(D*V(:,1:ncc),nx,ntviews,ncc); clear D V S
    nc = ncc;

elseif nc > ncc

    % select a set of coils
    selected_coils = [1,2,4,5,6:2:size(kdata,3)];
    kdata = kdata(:,:,selected_coils);
    nc = size(kdata,3);

end

%% EXPERIMENT 2.3 - remove half of the spokes (one hemisphere)

if experiment == 2

    if traj_design == 2 && spokes_to_keep == 0 % continuous phyllotaxis: keep TOP

        % continuous phyllotaxis: keep spokes that start at the TOP half of the sphere
        nseg_orig = nseg;
        nseg = nseg/4;
        kx(:,nseg+1:nseg*3,:) = [];
        ky(:,nseg+1:nseg*3,:) = [];
        kz(:,nseg+1:nseg*3,:) = [];
        kdata= reshape(kdata,[nx,nseg_orig,nshot,ncc]);
        kdata(:,nseg+1:nseg*3,:,:) = [];
        nseg = nseg_orig/2;
        kdata = reshape(kdata,[nx,nseg*nshot,ncc]);
        ntviews = nseg*nshot;

    elseif traj_design == 2 && spokes_to_keep == 1 % continuous phyllotaxis: keep BOTTOM

        % continuous phyllotaxis: keep spokes that start at BOTTOM half of the sphere
        nseg_orig = nseg;
        nseg = nseg/4;
        kx(:,1:nseg,:) = []; kx(:,(end-nseg)+1:end,:) = [];
        ky(:,1:nseg,:) = []; ky(:,(end-nseg)+1:end,:) = [];
        kz(:,1:nseg,:) = []; kz(:,(end-nseg)+1:end,:) = [];
        kdata = reshape(kdata,[nx,nseg_orig,nshot,ncc]);
        kdata(:,1:nseg,:,:) = []; kdata(:,(end-nseg)+1:end,:) = [];
        nseg = nseg_orig/2;
        kdata = reshape(kdata,[nx,nseg*nshot,ncc]);
        ntviews = nseg*nshot;

    elseif traj_design == 1 && spokes_to_keep == 0 % pole-to-pole phyllotaxis: keep TOP

        % pole-to-pole phyllotaxis: keep spokes that start at the TOP half of the sphere
        nseg_orig = nseg;
        nseg = nseg/2;
        kx(:,nseg+1:end,:) = [];
        ky(:,nseg+1:end,:) = [];
        kz(:,nseg+1:end,:) = [];
        kdata = reshape(kdata,[nx,nseg_orig,nshot,ncc]);
        kdata(:,nseg+1:end,:,:) = [];
        kdata = reshape(kdata,[nx,nseg*nshot,ncc]);
        ntviews = nseg*nshot;

    elseif traj_design == 1 && spokes_to_keep == 1 % pole-to-pole phyllotaxis: keep BOTTOM

        % pole-to-pole phyllotaxis: keep spokes that start at the BOTTOM half of the sphere
        nseg_orig = nseg;
        nseg = nseg/2;
        kx(:,1:nseg,:) = [];
        ky(:,1:nseg,:) = [];
        kz(:,1:nseg,:) = [];
        kdata = reshape(kdata,[nx,nseg_orig,nshot,ncc]);
        kdata(:,1:nseg,:,:) = [];
        kdata = reshape(kdata,[nx,nseg*nshot,ncc]);
        ntviews = nseg*nshot;
    end

    % define modified Traj3D
    Traj3D = cat(4, kx, ky, kz);
    Traj3D = repmat(reshape(Traj3D,[nx, nseg*nshot, 1, 3]), [1 nPC 1 1]);

end

%% IMAGE RECONSTRUCTION USING GPUNUFFT

%% Density compensation

filterFactor = 1;
[wcut, ~] = dcf3Dradial(nx, nseg*nshot*nPC, filterFactor);
DensityCompen3D = repmat(wcut(:), [1 nseg*nshot*nPC]);

%% Remove SI projections (first spoke of each interleave)

Traj3D(:,1:nseg:end,:) = [];
DensityCompen3D(:,1:nseg:end) = [];
kdata(:,1:nseg:end,:) = [];

%% Reject non-steady-state spokes

% Find non-steady-state spokes
[nx, ntviews, nc] = size(kdata);
kdata = reshape(kdata, [nx, ntviews/nPC, nPC, nc]);
Traj3D   = reshape(Traj3D, [nx, ntviews/nPC, nPC, 3]);
DensityCompen3D = reshape(DensityCompen3D,[nx, ntviews/nPC, nPC]);
[~, accepted] = reject_nonsteadystate(kdata,nPC,0.1);

% Trim rejected spokes
kdata(:,[1:min(accepted) max(accepted):end],:,:) = [];
Traj3D(:,[1:min(accepted) max(accepted):end],:,:) = [];
DensityCompen3D(:,[1:min(accepted) max(accepted):end],:) = [];

% Reshape back
[nx,ntviews,nPC,nc] = size(kdata);
kdata = reshape(kdata,[nx ntviews*nPC nc]);
Traj3D = reshape(Traj3D,[nx ntviews*nPC 3]);
DensityCompen3D = reshape(DensityCompen3D,[nx ntviews*nPC]);

%% NUFFT reconstruction without sensemaps

% Apply density compensation
kdata = kdata .* repmat(sqrt(DensityCompen3D),[1,1,nc]);

% Apply Kaiser filter on data for sensitivity map estimation only (kdata_b1)
filter = kaiser(nx,8);
kdata_b1 = kdata .* repmat(filter,[1,ntviews*nPC,nc]);

% Reshape data for gpuNUFFT
Traj3D = reshape(Traj3D,[nx*ntviews*nPC,3]);
DensityCompen3D = reshape(DensityCompen3D,[nx*ntviews*nPC,1]);
kdata = reshape(kdata,[nx*ntviews*nPC,nc]);
kdata_b1 = reshape(kdata_b1,[nx*ntviews*nPC,nc]);

% Apply gpuNUFFT on low resolution data for sensitivity map estimation
osf=2; wg=3; sw=8;
E = gpuNUFFT_nt(Traj3D,DensityCompen3D,osf,wg,sw,N);
ref = zeros([N nc],'single');
for ch=1:nc
    ref(:,:,:,ch) = E' * kdata_b1(:,ch);
end
ref = ref / max(abs(ref(:)));

%% Sensitivity map estimation

bz = 8; % block size for sensitivity map estiamtion
if 0
    b1 = adapt_array_3d(ref,[],[],bz);
else
    b1 = adapt_array_3d_fast(ref,[],[],bz); % using parpool
end
b1 = b1 / max(abs(b1(:)));

%% NUFFT reconstruction with sensitivity maps

% Apply gpuNUFFT on kdata using estimated sensitivity maps b1
E = gpuNUFFT_nt(Traj3D,DensityCompen3D,osf,wg,sw,N,b1);
recon = E' * kdata;
recon = recon / max(recon(:));

%% Display example slice

figure('Color','White','Position',[200 200 800 500]);
rotangle = 90;
scm = 0.6;
sc = 3;
zo = 1.3;

subplot(2,3,1)
imagesc(imrotate(squeeze(abs(recon(N(1)/2+1,:,:))),rotangle),[0 scm]); colormap gray; axis off; zoom(zo);
subplot(2,3,2)
imagesc(imrotate(squeeze(abs(recon(:,N(1)/2+1,:))),rotangle),[0 scm]); colormap gray; axis off; zoom(zo);
subplot(2,3,3)
imagesc(imrotate(squeeze(abs(recon(:,:,N(1)/2+1))),rotangle),[0 scm]); colormap gray; axis off; zoom(zo);

subplot(2,3,4)
imagesc(imrotate(squeeze(angle(recon(N(1)/2+1,:,:))),rotangle),[-pi/sc pi/sc]); colormap gray; axis off; zoom(zo);
subplot(2,3,5)
imagesc(imrotate(squeeze(angle(recon(:,N(1)/2+1,:))),rotangle),[-pi/sc pi/sc]); colormap gray; axis off; zoom(zo);
subplot(2,3,6)
imagesc(imrotate(squeeze(angle(recon(:,:,N(1)/2+1))),rotangle),[-pi/sc pi/sc]); colormap gray; axis off; zoom(zo);

%% ONLY FOR PHASE-CYCLED DATA

if nPC>1

    % NUFFT reconstruction with sensitivity maps for nPC
    kdata = reshape(kdata, [nx, ntviews, nPC, nc]);
    kdata = reshape(kdata,[nx*ntviews,nPC,nc]);
    kdata = permute(kdata,[1 3 2]);

    Traj3D = reshape(Traj3D, [nx, ntviews, nPC, 3]);
    Traj3D = reshape(Traj3D,[nx*ntviews, nPC,3]);
    Traj3D = permute(Traj3D,[1 3 2]);

    DensityCompen3D = reshape(DensityCompen3D,[nx, ntviews, nPC]);
    DensityCompen3D = reshape(DensityCompen3D,[nx*ntviews, nPC]);

    % gpuNUFFT recon
    param.y = kdata;
    param.E = gpuNUFFT_nt(permute(single(Traj3D),[2 1 3]),permute(single(DensityCompen3D),[1 2]),osf,wg,sw,N,b1); % including b1 map
    recon_nPC = param.E'*param.y;
    recon_nPC = recon_nPC/max(abs(recon_nPC(:)));
    recon = sum(recon_nPC,4); % complex sum images
    recon = recon/max(abs(recon(:)));

    % T1 and T2 map calculation using ORACLE
    clear T1w_map T2w_map off M0
    TR = 5; alpha = 20;
    for i=1:size(recon_nPC,1)
        for ii=1:size(recon_nPC,2)
            for iii=1:size(recon_nPC,3)
                [T1w_map(i,ii,iii),T2w_map(i,ii,iii), off(i,ii,iii), M0(i,ii,iii)] = ORACLE(recon_nPC(i,ii,iii,:),TR,deg2rad(alpha),-1);
            end
        end
    end

    % Plot T1 T2
    zo=0;
    sc_m=0.25;
    sc_p=1;
    pc = 1;
    figure('Color','White','Position',[300 300 1200 600]);

    loLevT1 = 0.0;
    upLevT1 = 2000.0;
    loLevT2 = 0.0;
    upLevT2 = 200.0;
    axx=subplot(2,3,1)
    tmp = T1w_map;
    tmp = squeeze(tmp(round(size(tmp,1)/2),:,:));

    tmp = imrotate(tmp, rotangle);
    [imClip, rgb_vec] = relaxationColorMap('T1', tmp, loLevT1, upLevT1);
    imagesc(squeeze((imClip)),[loLevT1, upLevT1]);axis equal; axis off; zoom(zo);
    colormap(axx,rgb_vec);
    title('',' T1 map [ms]')

    axx=subplot(2,3,2)
    tmp = T1w_map;
    tmp = squeeze(tmp(:,round(size(tmp,2)/2),:));
    tmp = imrotate(tmp, rotangle);
    [imClip, rgb_vec] = relaxationColorMap('T1', tmp, loLevT1, upLevT1);
    imagesc(squeeze((imClip)),[loLevT1, upLevT1]);axis equal; axis off; zoom(zo);
    colormap(axx,rgb_vec);
    title('',' T1 map [ms]')

    axx=subplot(2,3,3)
    tmp = T1w_map;
    tmp = squeeze(tmp(:,:,round(size(tmp,3)/2)));
    tmp = imrotate(tmp, rotangle);
    [imClip, rgb_vec] = relaxationColorMap('T1', tmp, loLevT1, upLevT1);
    imagesc(squeeze((imClip)),[loLevT1, upLevT1]);axis equal; axis off; zoom(zo);
    colormap(axx,rgb_vec);
    title('',' T1 map [ms]')

    ax=subplot(2,3,4)
    tmp = T2w_map;
    tmp = squeeze(tmp(round(size(tmp,1)/2),:,:));
    tmp = imrotate(tmp, rotangle);
    [imClip, rgb_vec] = relaxationColorMap('T2', tmp, loLevT2, upLevT2);
    imagesc(squeeze((imClip)),[loLevT2, upLevT2]);axis equal; axis off; zoom(zo);
    colormap(ax,rgb_vec);
    title('',' T2 map [ms]')

    ax=subplot(2,3,5)
    tmp = T2w_map;
    tmp = squeeze(tmp(:,round(size(tmp,2)/2),:));
    tmp = imrotate(tmp, rotangle);
    [imClip, rgb_vec] = relaxationColorMap('T2', tmp, loLevT2, upLevT2);
    imagesc(squeeze((imClip)),[loLevT2, upLevT2]);axis equal; axis off; zoom(zo);
    colormap(ax,rgb_vec);
    title('',' T2 map [ms]')

    ax=subplot(2,3,6);
    tmp = T2w_map;
    tmp = squeeze(tmp(:,:,round(size(tmp,3)/2)));
    tmp = imrotate(tmp, rotangle);
    [imClip, rgb_vec] = relaxationColorMap('T2', tmp, loLevT2, upLevT2);
    imagesc(squeeze((imClip)),[loLevT2, upLevT2]);axis equal; axis off; zoom(zo);
    colormap(ax,rgb_vec);
    title('',' T2 map [ms]')

end