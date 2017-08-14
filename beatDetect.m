%Read in audio file
[x, Fs] = audioread('mydisco.mp3');
x = x(15*Fs:30*Fs, :);
x_mono = 0.5*(x(:,1) + x(:,2));


%STFT
N = 1024; %window size
M = 1024; %hop size
p = N - M; %overlap
w = hamming(N); %window
x_buff = buffer(x_mono, N, p);
x_buff_win = bsxfun(@times, w, x_buff);
X_fm = fft(x_buff_win)/N;

G = asin(abs(X_fm)); %compression function
E = sum(diff(G, 1, 2)); %spectral energy flux

%smoothing and thresholding
L = 10;
h = (1/L)*ones(1,L);
E_avg = filter(h, 1, E);
E = E - E_avg;
E(E<3*mean(E)) = 0;

%peak detection
[Rxx, lags] = xcorr(E);
T = N/Fs; %time between points
[pks, locs] = findpeaks(E);
mu_pkDis = T*mode(diff(locs));

%Compute BPM estimate
BPM_est = 60/mu_pkDis;
if(BPM_est > 200)
    BPM_est = BPM_est/2;
elseif(BPM_est < 60)
    BPM_est = BPM_est*2;
end

