function [res] = gpuNUFFT_nt(k,w,osf,wg,sw,imageDim,sens,varargin)

% function m = gpuNUFFT(k,w,osf,wg,sw,imageDim,sens,varargin)
%
%     k -- k-trajectory, scaled -0.5 to 0.5
%          dims: 2 (3) ... x y (z)
%                N ... # sample points
%                nt ...# time points
%     w -- k-space weighting, density compensation
%     osf -- oversampling factor (usually between 1 and 2)
%     wg -- interpolation kernel width (usually 3 to 7)
%     sw -- sector width to use
%     imageDim -- image dimensions [n n n]
%     sens -- coil sensitivity data
%     varargin
%        opt  -- true/false for atomic operation (default true)
%             -- true/false for using textures on gpu (default true)
%             -- true/false for balanced operation (default true)
%
%  res -- gpuNUFFT operator
%
% Authors:
% A. Schwarzl, Graz University of Technology
% F. Knoll, NYU School of Medicine
%
% Adapted by Eva S Peper, 2023:
%     Added nt loop to loop over time points or phase cycles.

res.normsqr = 10;

atomic = true;
use_textures = true;
balance_workload = true;

if nargin < 7
    sens = [];
end
if nargin >= 8
    atomic = varargin{1};
    if nargin >= 9
        use_textures = varargin{2};
        if nargin >= 10
            balance_workload = varargin{3};
        end
    end
end

if ~atomic
    error('gpuNUFFT:usage:atomic','Coarse code path is not supported anymore. Please choose the atomic code path.');
end

% check types of
if ~islogical(atomic)
    error('gpuNUFFT:usage:atomic','Argument 8 (atomic) has to be of logical type.');
end

if ~islogical(use_textures)
    error('gpuNUFFT:usage:use_textures','Argument 9 (textures) has to be of logical type.');
end

if ~islogical(balance_workload)
    error('gpuNUFFT:usage:balance_workload','Argument 10 (balance_workload) has to be of logical type.');
end

% check input size of imageDims
if (length(imageDim) > 3)
    error('gpuNUFFT:init:imageDims','Image dimensions too large. Currently supported: 2d, 3d');
end

% ESP add nt loop
[~,~,nt]=size(k);

for tt=1:nt
    tt

    is2Dprocessing = false;
    if (length(imageDim) < 3)
        imageDim(3) = 0;
        is2Dprocessing = true;
    end

    res.adjoint = 0;
    res.imageDim = imageDim;

    % adapt k space data dimension
    % transpose to 2 (3) x N
    kDims = size(k(:,:,tt));
    if (kDims(1) ~= 2 && is2Dprocessing) || ...
            (kDims(1) ~= 3 && ~is2Dprocessing)
        warning('gpuNUFFT:init:kspace','k space data passed in wrong dimensions. Expected dimensions are 2(3) x N - automatic transposing is applied');
        ktmp = k(:,:,tt)'; clear k;
        k(:,:,tt) = ktmp; clear ktmp;
    end

    wt = w(:,tt);

    % convert to single col
    wt = wt(:);
    if size(wt,1) ~= size(k(:,:,tt),2)
        warning('gpuNUFFT:init:density','density compensation dim does not match k space data dim. k: %s w: %s',num2str(size(k)),num2str(size(w)));
    end

    % check that sector width fits inside oversampled grid
    if (sum(mod(imageDim*osf,sw))~=0)
        warning('gpuNUFFT:init:oversampling','GRID width [%.1f,%.1f,%.1f] (image width * OSR) is no integer multiple of sector width %d.\nTry to use integer multiples for best performance.',imageDim(1)*osf,imageDim(2)*osf,imageDim(3)*osf,sw)
    end

    res.op{tt}.params.img_dims = uint32(imageDim);
    res.op{tt}.params.osr = single(osf);
    res.op{tt}.params.kernel_width = uint32(wg);
    res.op{tt}.params.sector_width = uint32(sw);
    res.op{tt}.params.trajectory_length = uint32(size(k,2));
    res.op{tt}.params.use_textures = use_textures;
    res.op{tt}.params.balance_workload = balance_workload;
    res.op{tt}.params.is2d_processing = imageDim(3) == 0;

    [res.op{tt}.dataIndices,res.op{tt}.sectorDataCount,res.op{tt}.densSorted,res.op{tt}.coords,res.op{tt}.sectorCenters,res.op{tt}.sectorProcessingOrder,res.op{tt}.deapoFunction] = mex_gpuNUFFT_precomp_f(single(k(:,:,tt))',single(wt)',res.op{tt}.params);
    res.op{tt}.atomic = atomic;
    res.op{tt}.verbose = false;

    res.op{tt}.w = w(:,tt);

    if ~isempty(sens)
        if (res.op{tt}.params.is2d_processing)
            res.op{tt}.sensChn = size(sens,3);
        else
            res.op{tt}.sensChn = size(sens,4);
        end
        res.op{tt}.sens = [real(sens(:))'; imag(sens(:))'];
        res.op{tt}.sens = reshape(res.op{tt}.sens,[2 imageDim(1)*imageDim(2)*max(1,imageDim(3)) res.op{tt}.sensChn]);
    else
        res.op{tt}.sens = sens;
        res.op{tt}.sensChn = 0;
    end

    if res.op{tt}.verbose
        test = res.op{tt}.sectorDataCount;
        test_cnt = test(2:end)-test(1:end-1);
        test_order = res.op{tt}.sectorProcessingOrder;
        figure;
        bar(test_cnt,'DisplayName','Workload per Sector');
        figure;
        bar(test_cnt(test_order(1,:)+1),'DisplayName','Workload per Sector ordered');figure(gcf)
    end

end % end nt loop


res = class(res,'gpuNUFFT_nt');
