%% Split Acc Data into Individual Steps
close all

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
fstepsMax = 1.0;       %Upper bound on Step Freq
fstepsMin = .20;       %Lower bound on Step Freq
if L<250
    [~,is] = max(Pyy(round(fstepsMin*L/Fs):round(fstepsMax*L/Fs))); %approx count of steps per sec 
    Nsteps = f(is+1);
else
    [~,is] = max(Pyy(round(fstepsMin*L/Fs):round(fstepsMax*L/Fs))); %approx count of steps per sec 
    Nsteps = f(is+2);
end
if isempty(Nsteps)  %if # of steps can not be reliably computed
    Nsteps = 0;
end

Stepf=Nsteps;


% phi_lp = -MAS_Data(:,2);
% dPhi = diff(phi_lp);
% signdPhi = [];
% for k=1:length(dPhi)-1
%     signdPhi(k) = dPhi(k)*dPhi(k+1);
% end
% ind0 = find(signdPhi < 0);
% ind0opt = [];
% corr=0;
% 
%  %search in the neighbor of sign inversion
% if ind0(1)==1
%     ind0(1)=2;
% end


% for k=1:length(ind0)
%     [~,ik] = min(dPhi(ind0(k)-1:ind0(k)+1));   
%     ind0opt(k-corr)=ind0(k)+ik-2;
%     if k>1+corr
%         if ind0opt(k-corr)-ind0opt(k-1-corr)<10
%             corr=corr+2;
%         end
%     end
% end
% ind0 = ind0opt; %indices of min and max values of phi
% 
% if ind0(end)<=ind0(end-1)
%     ind0=ind0(1:end-1);
% end
% 
% if ind0(end)==length(dPhi)
%     ind0(end)=ind0(end)-1;
% end
% 
% d2Phi = diff(dPhi);
% d2Phi0 = d2Phi(ind0);
% im = find(d2Phi0 > 0);
% ind0m = ind0(im);   %indices of local minima in phif

intCheck=find(MAS_Data(:,2)>(mean(MAS_Data(:,2))+3*std(MAS_Data(:,2))));
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
    HR_AP=[];
    HR_VT=[];
    HR_ML=[];
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
    
    while x_len(stepInd)-Fs/Stepf<-.05*Fs/Stepf && k<length(ind0m)-added_ints-1
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
plot(sum(xReSamp))

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