% Returns features for EMG data

function [fvec, flab] = getEMGFeatures(emg)

%r - threshold for SampEn

X = emg(1,:); %EMG channels

fvec = []; %stores features
flab = {}; %stores names of features
%axes = {'x','y','z'};
epsthresh = 1E-5;  %threshold to be tuned based on the peak noise amp
Fs = 250;           %Sampling Freq [Hz]

%% Features for Each Channel (Time Domain)
for i=1:size(X,1)
    
    x = X(i,:);
    
    %Mean Absolute value
    fvec = [fvec nanmean(abs(x(i,:)))]; flab = [flab; [num2str(i) '-MeanAbs']];
    
    %Zero Crossings
    diffxk = diff(x(i,:));
    sgnxk = diffxk(1:end-1).*diffxk(2:end);
    ind0 = find(abs(diffxk) > epsthresh & diffxk < 0);
    ZC = length(ind0)/length(x);
    fvec = [fvec ZC]; flab = [flab; [num2str(i) '-ZeroCross']];
    
    %Slope Sign Changes
    xk = x(2:end-1); xkm1 = x(1:end-2); xkp1 = x(3:end);
    SC_a = xk>xkm1 & xk>xkp1;
    SC_b = xk<xkm1 & xk<xkp1;
    SC_c = (abs(xk-xkm1) >= epsthresh) | (abs(xk-xkp1) >= epsthresh);
    SC = find( (SC_a | SC_b) & SC_c);
    SC = length(SC)/length(x);
    fvec = [fvec SC]; flab = [flab; [num2str(i) '-SlopeSignChange']];
    
    %Waveform length
    WL = mean(abs(xk-xkp1));
    fvec = [fvec WL]; flab = [flab; [num2str(i) '-WaveformLength']];
    
    %Willison Amplitude
    f = (abs(xk-xkp1) > epsthresh);
    WAMP = sum(f)/length(x);
    fvec = [fvec WAMP]; flab = [flab; [num2str(i) '-WillisonAmp']];
    
    %RMS
    RMS = sqrt(mean(x.^2));
    fvec = [fvec RMS]; flab = [flab; [num2str(i) '-RMS']];
    
    %Variance
    VAR = var(x);
    fvec = [fvec VAR]; flab = [flab; [num2str(i) '-Variance']];
    
%     %AR coefficients (4th order)
%     AR_model = ar(x,4,'Ts',fs);
%     AR_coeffs = AR_model.a(2:end);
%     fvec = [fvec AR_coeffs];
%     for j = 1:length(AR_Coeffs)
%         flab = [flab; [axes{i} sprintf('-ARCoeff%d',j)]];
%     end
%     
%     %Sample Entropy
    r = 0.5*std(x);    %tolerance = 0.2*std
    fvec = [fvec SampEn(1,r,x.')];
    flab = [flab; '-SampEn'];
%     

%% Freq domain features

    N = length(x);
    xdft = fft(x,2^nextpow2(N));
    xdft = xdft(1:round(N/2)+1);
    psdx = abs(xdft).^2;
    freqx = linspace(0,Fs/2,length(psdx));
    l = length(freqx);
    for k = 1:6
        fint = freqx(round((k-1)*l/6+1):round(k*l/6));
        freqpow(k) = trapz(fint,psdx(round((k-1)*l/6+1):round(k*l/6)))/trapz(freqx,psdx);
        fvec = [fvec freqpow(k)];    flab = [flab; ['-Fpow-', num2str(k*20)]];
    end

    
end


% %% Frequency Domain Processing (High Pass + Power Spectra)
% filtered = cell(1,1);
% PSD_welch = cell(1,1);
% f_welch = cell(1,1);
% fc = 0.2; %cutoff frequency (Hz)
% fs = 250;
% f_nyq = fs/2;
% 
% %High Pass Filter
% 
% [b, a] = butter(2,(fc*pi)/f_nyq,'high');
% filtered{ii} = filter(b,a,x(ii,:));
% 
% 
% %Power Spectra
% 
% win_size = ceil(length(filtered{ii})/2);
% [PSD_welch{ii}, f_welch{ii}] = pwelch(filtered, win_size, [], [], fs);
% 
% 
% %% Features for Each Axis (Frequency Domain)
% 
% %Mean
% fvec = [fvec nanmean(PSD_welch{ii})]; flab = [flab; [axes{ii} '-mean (PSD)']];
% 
% %Std (2nd moment)
% fvec = [fvec nanstd(PSD_welch{ii})];  flab = [flab; [axes{ii} '-std (PSD)']];
% 
% %Skewness + Kurtosis (3rd and 4th moments)
% if nanstd(PSD_welch{ii}) == 0
%     x = PSD_welch{ii}; N = length(x);
%     s = 1/N*sum((x-mean(x)).^3)/( sqrt(1/N*sum((x-mean(x)).^2)) + eps )^3; %skewness
%     k = 1/N*sum((x-mean(x)).^4)/( 1/N*sum((x-mean(x)).^2) + eps )^2; %kurtosis
%     fvec = [fvec s]; flab = [flab; [axes{ii} '-skew (PSD)']];
%     fvec = [fvec k]; flab = [flab; [axes{ii} '-kurt (PSD)']];
% else
%     fvec = [fvec skewness(PSD_welch{ii})]; flab = [flab; [axes{ii} '-skew (PSD)']];
%     fvec = [fvec kurtosis(PSD_welch{ii})]; flab = [flab; [axes{ii} '-kurt (PSD)']];
% end
% 
% %Mean Power for 0.5 Hz Intervals
% bins = [0:5:125]; %0-125 Hz with bins for every 0.5 Hz
% N = length(bins)-1;
% bin_ind = [1; zeros(N,1)];
% %PSD_welch_norm = PSD_welch{ii}/max(PSD_welch{ii});
% PSD_welch_norm = PSD_welch{ii};
% bin_val = zeros(N,1);
% for jj = 1:length(bins) %ignore 0 Hz in bins vector
%     freq_bin = bins(jj);
%     for zz = 1:length(f_welch{ii})
%         if ((f_welch{ii}(max(zz-1,1)) < freq_bin) && (f_welch{ii}(zz) > freq_bin)) || f_welch{ii}(zz) == freq_bin
%             bin_ind(jj) = zz;
%         end
%     end
% end
% 
% for kk = 1:length(bins)
%     bin_val(kk) = mean(PSD_welch_norm(bin_ind(max(kk-1,1)):bin_ind(kk)));
% end
% fvec = [fvec bin_val(1:end)'];
% for jj = 1:length(bin_val)
%     flab = [flab; [axes{ii} sprintf('_bin_%d',bins(jj))]];
% end
% 
% fvec = [fvec sum(bin_val(1:4))/sum(bin_val(5:end))];
% flab = [flab; 'f_ratio'];
% 
% %% Features Across All Axes (Frequency Domain)
% %Sum of std
% 


return