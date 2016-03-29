function [fvec, flab] = getFeatures(acc,r)
% INPUT acc - 3 x n vector: 1-3 are xyz accelerations for n data points
%       r - threshold for SampEn

S = acc(1,:); %matrix of xyz acceleration data (excludes time data)

fvec = []; %stores features
flab = {}; %stores names of features
axes = {'x','y','z'};

%% Features for Each Axis (Time Domain)
for i=1:size(S,1)
    %Mean 
    fvec = [fvec nanmean(S(i,:))]; flab = [flab; [axes{i} '-mean']];

    %Range of values
    fvec = [fvec range(S(i,:))]; flab = [flab; [axes{i} '-range']];
    
    %Interquartile Range
    fvec = [fvec iqr(S(i,:))]; flab = [flab; [axes{i} '-IQR']];    
    
    %Histogram of the z-score values
    zvals = -2:1:2;
    histvec = histc((S(i,:)-nanmean(S(i,:))/nanstd(S(i,:))),zvals);
    histvec = histvec(1:end-1); % removing the last data point which counts how many values match exactly 3. (nonsense)
    fvec = [fvec histvec]; 
    for j=1:length(histvec),
        flab = [flab; [axes{i} sprintf('-hist%d',zvals(j))]];
    end
    
    %Std (2nd moment)
    fvec = [fvec nanstd(S(i,:))];  flab = [flab; [axes{i} '-std']];
    
    %Skewness + Kurtosis (3rd and 4th moments)
    if nanstd(S(i,:)) == 0
        X = S(i,:); N = length(X);
        s = 1/N*sum((X-mean(X)).^3)/( sqrt(1/N*sum((X-mean(X)).^2)) + eps )^3; %skewness
        k = 1/N*sum((X-mean(X)).^4)/( 1/N*sum((X-mean(X)).^2) + eps )^2; %kurtosis
        fvec = [fvec s]; flab = [flab; [axes{i} '-skew']];
        fvec = [fvec k]; flab = [flab; [axes{i} '-kurt']];
    else
        fvec = [fvec skewness(S(i,:))]; flab = [flab; [axes{i} '-skew']];
        fvec = [fvec kurtosis(S(i,:))]; flab = [flab; [axes{i} '-kurt']];
    end
     
    %Mean of differences
    fvec = [fvec nanmean(diff(S(i,:)))]; flab = [flab; [axes{i} '-mean diff']];
    
    %Std of differences (2nd moment)
    fvec = [fvec nanstd(diff(S(i,:)))]; flab = [flab; [axes{i} '-std diff']];
    
    %Skewness + Kurtosis of differences (3rd and 4th moments)
    if nanstd(diff(S(i,:))) == 0
        X = diff(S(i,:)); N = length(X);
        s = 1/N*sum((X-mean(X)).^3)/( sqrt(1/N*sum((X-mean(X)).^2)) + eps )^3; %skewness
        k = 1/N*sum((X-mean(X)).^4)/( 1/N*sum((X-mean(X)).^2) + eps )^2; %kurtosis 
        fvec = [fvec s]; flab = [flab; [axes{i} '-skew diff']];
        fvec = [fvec k]; flab = [flab; [axes{i} '-kurt diff']];
    else
        fvec = [fvec skewness(diff(S(i,:)))]; flab = [flab; [axes{i} '-skew diff']];
        fvec = [fvec kurtosis(diff(S(i,:)))]; flab = [flab; [axes{i} '-kurt diff']];
    end
end

%% Features Across All Axes (Time Domain)
%Mean of squares
fvec = [fvec nanmean(nanmean(S.^2))];
flab = [flab; 'mean of squares'];

%% Frequency Domain Processing (High Pass + Power Spectra)
filtered = cell(1,1);
PSD_welch = cell(1,1);
f_welch = cell(1,1);
fc = 0.2; %cutoff frequency (Hz)
fs = 30;
f_nyq = fs/2;

%High Pass Filter
for ii = 1:1
    [b, a] = butter(2,(fc*pi)/f_nyq,'high');
    filtered{ii} = filter(b,a,S(ii,:)); 
end

%Power Spectra
for ii = 1:1
    win_size = ceil(length(filtered{ii})/2);
    [PSD_welch{ii}, f_welch{ii}] = pwelch(filtered, win_size, [], [], fs);
end

%% Features for Each Axis (Frequency Domain)
for ii = 1:1
    %Mean 
    fvec = [fvec nanmean(PSD_welch{ii})]; flab = [flab; [axes{ii} '-mean (PSD)']];
    
    %Std (2nd moment)
    fvec = [fvec nanstd(PSD_welch{ii})];  flab = [flab; [axes{ii} '-std (PSD)']];
    
    %Skewness + Kurtosis (3rd and 4th moments)
    if nanstd(PSD_welch{ii}) == 0
        X = PSD_welch{ii}; N = length(X);
        s = 1/N*sum((X-mean(X)).^3)/( sqrt(1/N*sum((X-mean(X)).^2)) + eps )^3; %skewness
        k = 1/N*sum((X-mean(X)).^4)/( 1/N*sum((X-mean(X)).^2) + eps )^2; %kurtosis
        fvec = [fvec s]; flab = [flab; [axes{ii} '-skew (PSD)']];
        fvec = [fvec k]; flab = [flab; [axes{ii} '-kurt (PSD)']];
    else
        fvec = [fvec skewness(PSD_welch{ii})]; flab = [flab; [axes{ii} '-skew (PSD)']];
        fvec = [fvec kurtosis(PSD_welch{ii})]; flab = [flab; [axes{ii} '-kurt (PSD)']];
    end
    
    %Mean Power for 0.5 Hz Intervals
    bins = [0:0.5:10]; %0-10 Hz with bins for every 0.5 Hz
    N = length(bins)-1;
    bin_ind = [1; zeros(N,1)];
    %PSD_welch_norm = PSD_welch{ii}/max(PSD_welch{ii});
    PSD_welch_norm = PSD_welch{ii};
    bin_val = zeros(N,1);
    for jj = 2:length(bins) %ignore 0 Hz in bins vector
        freq_bin = bins(jj);
        for zz = 2:length(f_welch{ii})
           if ((f_welch{ii}(zz-1) < freq_bin) && (f_welch{ii}(zz) > freq_bin)) || f_welch{ii}(zz) == freq_bin
               bin_ind(jj) = zz;
           end
        end
    end

    for kk = 2:length(bins)
        bin_val(kk) = mean(PSD_welch_norm(bin_ind(kk-1):bin_ind(kk)));
    end
    fvec = [fvec bin_val(2:end)'];
    for jj = 2:length(bin_val)
        flab = [flab; [axes{ii} sprintf('_bin_%d',bins(jj))]];
    end
end
return

%% Features Across All Axes (Frequency Domain)
%Sum of std
fvec = [fvec sum([std(PSD_welch{1}) std(PSD_welch{2}) std(PSD_welch{3})])]; flab = [flab; 'std_sum'];

fvec = [fvec SampEn(0,r,S)];
flab = [flab; 'SampEn'];