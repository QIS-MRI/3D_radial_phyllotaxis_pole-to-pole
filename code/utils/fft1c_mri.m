function X=fft1c_mri(x)
X=fftshift(ifft(fftshift(x,1),[],1),1)*sqrt(size(x,1));
