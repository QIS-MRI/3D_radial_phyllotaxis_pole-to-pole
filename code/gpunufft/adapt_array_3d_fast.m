function cmap = adapt_array_3d_fast(yn, rn, normFlag, bz)
% Reconstruction of array data and computation of coil sensitivities based 
% on: a) Adaptive Reconstruction of MRI array data, Walsh et al. Magn Reson
% Med. 2000; 43(5):682-90 and b) Griswold et al. ISMRM 2002: 2410
%-------------------------------------------------------------------------
%	Input:
%	yn: array data to be combined [ny, nx, nc]. 
%	rn: data covariance matrix [nc, nc].
%	norm: =1, normalize image intensity
%
%	Output:
%	recon: reconstructed image [ny, nx].
%	cmap: estimated coil sensitivity maps [ny, nx, nc].
%--------------------------------------------------------------------------
% Author: Ricardo Otazo
% CBI, New York University
%--------------------------------------------------------------------------

% Adapted by Eva S Peper, 2023: 
%     Changed 2D -> 3D
%     Hand over block size bz
%     Use parfor 

if nargin < 3 || isempty(normFlag), normFlag = 0; end
if nargin < 2 || isempty(rn), rn = eye(size(yn, 4)); end

yn = permute(yn, [4,1,2,3]); % [nc, nz, ny, nx]
[nc, nz, ny, nx] = size(yn);

[~, maxcoil] = max(sum(abs(yn(:,:,:,:)), [2 3 4]));

Rinv = inv(rn);  % precompute inverse once

bs = bz; st = 2;
nxS = ceil(nx/st); nyS = ceil(ny/st); nzS = ceil(nz/st);
wsmall   = complex(zeros(nc, nzS, nyS, nxS), 0);
cmapsmall = wsmall;

parfor zIdx = 1:nzS
    z = zIdx * st;
    for yIdx = 1:nyS
        y = yIdx * st;
        for xIdx = 1:nxS
            x = xIdx * st;

            xidx = max(x-bs/2,1):min(x+bs/2,nx);
            yidx = max(y-bs/2,1):min(y+bs/2,ny);
            zidx = max(z-bs/2,1):min(z+bs/2,nz);

            m1 = reshape(yn(:, zidx, yidx, xidx), nc, []);
            m = m1 * m1';  % signal covariance

            [e, v] = eig(rn \ m); 
            [~, ind] = max(real(diag(v)));
            mf = e(:, ind);
            mf = mf / (mf' * Rinv * mf);
            phaseCorr = exp(-1j * angle(mf(maxcoil)));
            mf = mf * phaseCorr;

            wsmall(:, zIdx, yIdx, xIdx)   = mf;
            cmapsmall(:, zIdx, yIdx, xIdx) = mf; % can store normalized version if needed
        end
    end
end

% Interpolate magnitude and phase separately
cmap = complex(zeros(nc, nz, ny, nx), 0);
wfull = cmap;

for i = 1:nc
    absW = abs(squeeze(wsmall(i,:,:,:)));
    angW = angle(squeeze(wsmall(i,:,:,:)));
    absC = abs(squeeze(cmapsmall(i,:,:,:)));
    angC = angle(squeeze(cmapsmall(i,:,:,:)));

    wfull(i,:,:,:) = conj(imresize3(absW,[nz ny nx],'cubic') .* exp(1j*imresize3(angW,[nz ny nx],'nearest')));
    cmap(i,:,:,:)  = imresize3(absC,[nz ny nx],'cubic') .* exp(1j*imresize3(angC,[nz ny nx],'nearest'));
end

recon = squeeze(sum(wfull .* yn));

if normFlag
    recon = recon .* squeeze(sum(abs(cmap))).^2;
end

cmap = permute(cmap, [2,3,4,1]);
end
