%% EMG Analysis
% Preps EMG and ACC data for labeling
%   -Resamples to 250 Hz
%   -High-pass filter on EMG data
%   -Stores data in LabeledData folder
clear all

Fs=250;
HPF=5; % Frequency for High-Pass filter on EMG data
Envelope=1;
% Subjects to exclude from loop
RemoveSub={};
% RemoveSub={'CS003', 'CS004', 'CS005', 'CS006', 'CS007'};
dirname='Z:\Stroke MC10\';

filenames=dir([dirname 'CS*']);
NotDirectories=cellfun(@(x) x==0, {filenames.isdir});
filenames(NotDirectories)=[];
for i=1:length(RemoveSub)
    ExtraSub=cellfun(@(x) strcmp(x,RemoveSub{i}), {filenames.name});
    filenames(ExtraSub)=[];
end

Locations={'Gastrocnemius' 'Hamstring'};
for indDir=1:length(filenames)
    for Day=1:2
        numDay=num2str(Day);
        subject=filenames(indDir).name;
        TimesName=[dirname subject '\Lab Day ' numDay '\' subject '_Day' numDay '_Times.mat'];
        if ~exist(TimesName,'file')
            continue
        end
        load([dirname subject '\Lab Day ' numDay '\' subject '_Day' numDay '_Times.mat'])
    parfor i=1:height(Times)
        for indLoc=1:length(Locations)
            startStamp=datetime(1970, 1, 1, 0, 0, Times.Start(i)/1000);

            datafiles=dir([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} '\']);
            NotDirectories=cellfun(@(x) strcmp(x(1),'.'), {datafiles.name});
            datafiles(NotDirectories)=[];

            fileStamp=datetime(zeros(2,3));

            for indData=1:length(datafiles)
                fileTime=datafiles(indData).name;            
                fileStamp(indData)=datetime(str2double(fileTime(1:4)), str2double(fileTime(6:7)), str2double(fileTime(9:10)),...
                    str2double(fileTime(12:13)), str2double(fileTime(15:16)), str2double(fileTime(17:18)));
            end

            % Find index of correct file
            ind=find(startStamp>fileStamp==0,1);
            if ind>1
                ind=ind-1;
            end
            if isempty(ind)
                ind=length(datafiles);
            end

            afe=xlsread([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} ... 
                '\' datafiles(ind).name '\sensors\afe.csv']);
            % Only load accel data from Gastrocs
            if strcmp(Locations{indLoc},'Gastrocnemius')
                accel=xlsread([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} ... 
                    '\' datafiles(ind).name '\sensors\accel.csv']);
            end
            [~,Start]=min(abs(afe(:,1)-Times.Start(i)));
            [~,Stop]=min(abs(afe(:,1)-Times.End(i)));

            if Start-Stop==0
                continue
            end

            EMG=afe(Start:Stop,:);
            
            EMG(:,1)=(EMG(:,1))/1000;

            t=min(EMG(:,1)):0.004:max(EMG(:,1));
            EMG=spline(EMG(:,1).', EMG(:,2).', t.');
            EMG=[t.' EMG];

            [B,A] = butter(1, HPF/125, 'high');
            EMG(:,2)=filtfilt(B,A,EMG(:,2));

            [~,Start]=min(abs(accel(:,1)-Times.Start(i)));
            [~,Stop]=min(abs(accel(:,1)-Times.End(i)));
            
            ACC=accel(Start:Stop,:);
            ACC(:,1)=(ACC(:,1))/1000;

            t=min(EMG(:,1)):0.004:max(EMG(:,1));
            ACC=spline(ACC(:,1).', ACC(:,2:end).', t.');
            ACC=[t.' ACC.'];
            
            Data=[ACC EMG(:,2)];
            
            if ~strcmp(Locations{indLoc},'Gastrocnemius')
                ham_acc=xlsread([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} ... 
                    '\' datafiles(ind).name '\sensors\accel.csv']);
                [~,Start]=min(abs(ham_acc(:,1)-Times.Start(i)));
                [~,Stop]=min(abs(ham_acc(:,1)-Times.End(i)));
                HAM=accel(Start:Stop,:);
                HAM(:,1)=(HAM(:,1))/1000;

                t=min(EMG(:,1)):0.004:max(EMG(:,1));
                HAM=spline(HAM(:,1).', HAM(:,2:end).', t.');
                HAM=[t.' HAM.'];
                Data=[Data HAM(:,2:end)];
            end
            X=cell2mat(Times.Label(i));

            saveName=[dirname 'PreppedData\' subject '\Lab Day' num2str(Day) '\' Locations{indLoc} ...
                '_' X '_emgData.csv'];

            if ~exist([dirname 'PreppedData\' subject], 'dir')
                mkdir([dirname 'PreppedData\' subject])
            end
            if ~exist([dirname 'PreppedData\' subject '\Lab Day' num2str(Day)], 'dir')
                mkdir([dirname 'PreppedData\' subject '\Lab Day' num2str(Day)])
            end

            dlmwrite(saveName,Data,'delimiter',',','precision',13)
%             dlmwrite(saveName,EMG,'-append','delimiter',',','precision',13)
        end
    end
    end
end

%% Plot Acc and EMG to find spasticity
% Envelope=1;
% 
% EMG=afe;
% EMG(:,1)=(EMG(:,1))/1000;
% 
% t=min(EMG(:,1)):0.004:max(EMG(:,1));
% EMG=spline(EMG(:,1).', EMG(:,2).', t.');
% EMG=[t.' EMG];
% 
% [B,A] = butter(1, 20/125, 'high');
% EMG(:,2)=filtfilt(B,A,EMG(:,2));
% 
% % Create Envelope
% if Envelope
%     EMG(:,2)=abs(EMG(:,2));
%     [B,A] = butter(1, 5/125, 'low');
%     EMG(:,2)=filtfilt(B,A,EMG(:,2));
% end
% 
% 
% ACC=accel;
% ACC(:,1)=(ACC(:,1))/1000;
% 
% t=min(ACC(:,1)):0.020:max(ACC(:,1));
% ACC=spline(ACC(:,1).', ACC(:,2:end).', t.');
% ACC=[t.' ACC.'];
% 
% figure; plot(ACC(:,1),ACC(:,2)+2,EMG(:,1),EMG(:,2)*10000-2)
% 
% dlmwrite('.\TestFormat2.csv',ACC,'delimiter',',','precision',13)
% dlmwrite('.\TestFormat2.csv',EMG,'-append','delimiter',',','precision',13)
%% Delsys analysis

% Delsys=Delsys1;
% DelsysNew=spline(Delsys(:,1).', Delsys(:,2).', t.');
% DelsysNew=[t.' DelsysNew];
% 
% figure;
% plot(EMG(:,1), EMG(:,2), DelsysNew(:,1), DelsysNew(:,2))
% figure; plot(EMG(:,1), EMG(:,2))
% figure; plot(DelsysNew(:,1), DelsysNew(:,2))
% 
% phi=EMG(:,2);
Y=fft(phi);
P2=abs(Y/length(phi));
L=length(phi);
P1=P2(1:L/2+1);
P1(2:end-1)=2*P1(2:end-1);
f=Fs*(0:(L/2))/L;
[B,A] = butter(1, .25/L*125, 'low');
% P1=filtfilt(B,A,P1);
% figure;
plot(f,P1)
% 
% %%
% phi=DelsysPower(:,2);
% Y=fft(phi);
% P2=abs(Y/length(phi));
% L=length(phi);
% P1=P2(1:L/2+1);
% P1(2:end-1)=2*P1(2:end-1);
% f=Fs*(0:(L/2))/L;
% figure;
% plot(f,P1)