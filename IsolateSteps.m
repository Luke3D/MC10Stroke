%% Splits walking data into steps to plot average EMG over gait cycle
% store desired data into MAS_Data, nx5 matrix with timestamp, acc (x,y,z),
% EMG at 250 Hz (found in Z:\Stroke MC10)

%% Split Acc Data into Individual Steps
close all

th=2; % threshold (in sd)
tol=.1; % tolerance (in sd)
first=1;
Fs=250;
LPF=15; % Freq for Envelope filter
tReSamp = linspace(0,1,1001);

phi = (180/pi)*atan2(MAS_Data(:,2),MAS_Data(:,3));
ft = 2.0; %cut-off freq
[B,A] = butter(1, 2*ft/Fs);   %1st order, cutoff frequency 7Hz (Normalized by 2*pi*Sf) [rad/s]
phif = filtfilt(B,A,phi);   %the filtered version of the signal
%%

L = length(phif);    %signal length
Y = fft(phif,L);     %to improve DFT alg performance set L = NFFT = 2^nextpow2(L)
Pyy = Y.*conj(Y)/L; %power spectrum
f = Fs/2*linspace(0,1,L/2+1);   %frequency axis
fstepsMax = 1.2;       %Upper bound on Step Freq
fstepsMin = .20;       %Lower bound on Step Freq
[~,is] = max(Pyy(ceil(fstepsMin*L/Fs):floor(fstepsMax*L/Fs))); %approx count of steps per sec 
Nsteps = f(is+ceil(fstepsMin*L/Fs));

Stepf=Nsteps;

intCheck=find(MAS_Data(:,2)>(mean(MAS_Data(:,2))+th*std(MAS_Data(:,2))));
inds=[intCheck(1); intCheck(find(diff(intCheck)~=1))];

ind0m=[];

for i=1:length(inds)-1
    [~, mInd]=max(MAS_Data(inds(i):inds(i+1),2));
    ind0m=[ind0m mInd+inds(i)-1];
end


x = {}; t = {}; k = 1;
if first
    stepInd=1;
    step_ind={};
    xReSamp = [];
    x_len = [];
    first=0;
end

EMG=abs(MAS_Data(:,5));
[B,A] = butter(1, 15*2/Fs, 'low');
EMG=filtfilt(B,A,EMG);

while k<length(ind0m)

    x{stepInd} = phif(ind0m(k):ind0m(k+1));

    step_ind{stepInd} = [ind0m(k) ind0m(k+1)];

    x_len = [x_len,length(x{stepInd})];

    added_ints=0;

    x{stepInd} = EMG(ind0m(k):ind0m(k+added_ints+1));
    step_ind{stepInd} = [ind0m(k) ind0m(k+added_ints+1)];
    x_len(stepInd) = length(x{stepInd});
    temp=phif(ind0m(k):ind0m(k+added_ints+1));
    
    while x_len(stepInd)-Fs/Stepf<-tol*Fs/Stepf && k<length(ind0m)-added_ints-1
        added_ints=added_ints+1;
        x{stepInd} = EMG(ind0m(k):ind0m(k+added_ints+1));
        step_ind{stepInd} = [ind0m(k) ind0m(k+added_ints+1)];
        x_len(stepInd) = length(x{stepInd});
        temp=phif(ind0m(k):ind0m(k+added_ints+1));
    end
    figure
    plot(temp)
    
    x{stepInd} = x{stepInd}-x{stepInd}(1);    %remove amplitude offset

    t{stepInd} = linspace(0,1,length(x{stepInd}));
    %     plot(t{k},x{k})
    %resample to uniform # of points and normalize amplitude
    xnew = interp1(t{stepInd},x{stepInd},tReSamp);
    xnew = xnew./max(abs(xnew));         %normalize amplitude
    xReSamp = [xReSamp;xnew];

    %compute RMSE between 2 consecutive trials
    if stepInd > 1
        RMSE(stepInd-1) = sum( (xReSamp(stepInd-1,:)-xReSamp(stepInd,:)).^2 ) / length(tReSamp);
    end

    %compute max Amplitude and Time where max occurs
    [Amax(stepInd),Tmax1(stepInd)] = max(xReSamp(stepInd,:));
    Tmax(stepInd) = tReSamp(Tmax1(stepInd));

    k=k+1+added_ints;
    stepInd=stepInd+1;
    % input('')

end
figure
plot(mean(xReSamp))

%% Manual Isolation
% Store indices of heel strike events in stepInds matrix

% EMG=abs(MAS_Data(:,5));
% [B,A] = butter(1, 15*2/Fs, 'low');
% EMG=filtfilt(B,A,EMG);
% 
% tReSamp = linspace(0,1,1001);
% x=cell(length(stepInds)-1,1);
% xReSamp=zeros(length(stepInds)-1,1001);
% 
% 
% for i=1:length(stepInds)-1
%     x{i}=EMG(stepInds(i):stepInds(i+1));
%     xReSamp(i,:)=interp1(linspace(0,1,length(x{i})),x{i},tReSamp);
% end