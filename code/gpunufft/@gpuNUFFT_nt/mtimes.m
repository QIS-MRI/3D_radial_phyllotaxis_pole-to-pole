function res = mtimes(a,bb)

% Adapted by Eva S Peper, 2023: 
%     Added nt loop to loop over time points or phase cycles.

if (a.adjoint)
    [~,nc,nt]=size(bb);
    for tt=1:nt
        res(:,:,:,tt) = gpuNUFFT_adj(a.op{tt},bb(:,:,tt)); 
    end
    res=res/a.normsqr;
else
    [nx,ny,nz,nt]=size(bb);
    for tt=1:nt
        res(:,:,tt) = gpuNUFFT_forw(a.op{tt},bb(:,:,:,tt));  
    end
    res=res/a.normsqr;
end

