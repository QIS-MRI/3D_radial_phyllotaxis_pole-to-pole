function x=ifft1c_mri(X)
x=fftshift(fft(fftshift(X,1),[],1),1)/sqrt(size(X,1));
