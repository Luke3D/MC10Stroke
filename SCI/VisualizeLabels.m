%% Viusualize Labeled Data
colors = {'g','r','y','k'};
Labels={'Non-Spastic Activity', 'Spastic Activity', 'Inactive', 'Misc'};
useStitched=1; % flag to use stitched data

[filename,pathname] = uigetfile('Z:\Stroke MC10\SCI\LabeledEMG\*.csv');

Data=table2cell(readtable([pathname filename])); %EMG data High-pass filtered at 3Hz
longestchunk = cell(1,length(Labels));

figure; hold on

for indLab=1:length(Labels)
    inds=strcmp(Labels{indLab},Data(:,end-1));
    labelData=cell2mat(Data(inds,[1 2]));
    if isempty(labelData)
        continue
    end
    sepInds=[0; find(round(diff(labelData(:,1)*10000))~=40)];
    for i=1:length(sepInds)
        if isempty(sepInds)
            temp=LabelData;
        elseif i==length(sepInds)
            temp=labelData(sepInds(i)+1:end,:);
        else
            temp=labelData(sepInds(i)+1:sepInds(i+1),:);
        end
        plot(temp(:,1),temp(:,2),colors{indLab});
    end
    if ~isempty(sepInds)
        sepInds = [sepInds; length(labelData)];
        %save each longest record of labeled data for analysis
        [~,indlongest] = max(diff(sepInds));
        longestchunk{indLab} = labelData(sepInds(indlongest)+1:sepInds(indlongest+1),:);
    end
    stitched=[];
    for i=1:length(sepInds)-1
        stitched=[stitched; labelData(sepInds(i)+1:sepInds(i+1),:)];
    end
    if useStitched
        longestchunk{indLab}=stitched;
    end
end

%% show the Power Spectrum for each chunk
Fs = 250;   %sampling frew
for c = 1:length(longestchunk)
    if isempty(longestchunk{c})
        continue
    end
    x = longestchunk{c}(:,2);
    N = length(x);
    
    %periodogram in db/Hz
    %     xdft = fft(x);
    %     xdft = xdft(1:N/2+1);
    %     psdx = (1/(Fs*N)) * abs(xdft).^2;
    %     psdx(2:end-1) = 2*psdx(2:end-1);
    %     freq = 0:Fs/length(x):Fs/2;
    %     figure,
    %     subplot(211), hold on, title(Labels{c}), plot(x,colors{indLab})
    %     subplot(212), hold on
    %     plot(freq,10*log10(psdx))
    %     grid on
    %     title('Periodogram Using FFT')
    %     xlabel('Frequency (Hz)')
    %     ylabel('Power/Frequency (dB/Hz)')
    
    
    %Periodogram
%     xdft = fft(x,2^nextpow2(N));
%     xdft = xdft(1:N/2+1);
%     psdx = (abs(xdft).^2)/N;
%     freqx = 0:Fs/length(x):Fs/2;
    psdx = pwelch(x);
    freqx = linspace(0,Fs/2,length(psdx));
    
    figure,
    subplot(411), hold on, title(Labels{c}),
    t = 0:1/Fs:length(x)/Fs-1/Fs; plot(t,x,colors{indLab}), xlabel('Time [s]')
    ylim([-1E-4 1E-4]), ylabel('EMG [V]')
    subplot(412), hold on
    plot(freqx,psdx/trapz(freqx,psdx))
    grid on
    title('PSD')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
    
    trapz(freqx(1:20/125*length(psdx)),psdx(1:20/125*length(psdx))/trapz(freqx,psdx))
    
    %envelope
    Env =abs(x); Env = Env-mean(Env);
    [B,A] = butter(1, [2/Fs/2 15/Fs/2], 'bandpass');
    Env=filtfilt(B,A,Env);
    
    %Periodogram
    %     Envdft = fft(Env,2^nextpow2(length(Env)));
    %     Envdft = Envdft(1:N/2+1);
    %     psdEnv = (abs(Envdft).^2)/length(Env);
    psdEnv = pwelch(Env,250,125);
    freq = linspace(0,Fs/2,length(psdEnv));
    
    subplot(413), hold on, title('Envelope'),
    t = 0:1/Fs:length(x)/Fs-1/Fs; plot(t,Env,colors{indLab}), xlabel('Time [s]')
    subplot(414), hold on, title('PSD')
    plot(freq,psdEnv), xlim([0 15])
    grid on
    title('PSD')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
    
    %scale PSD by fund freq of envelope
%     indf = find(freq > 1,1);
%     [~,fundfreq] = max(psdEnv(indf+1:end)); fundfreq = freq(fundfreq+indf);
%     figure
%     xscaled = freqx/fundfreq;
%     plot(xscaled,psdx);
    
end

%% Extract Clips and features from data

 
