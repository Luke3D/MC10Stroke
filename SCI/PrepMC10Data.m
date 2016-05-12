%% PrepMC10Data
% Preps EMG and ACC data for labeling
%   -Resamples to 250 Hz
%   -High-pass filter on EMG data
%   -Stores data in PreppedData folder
%   -Includes Gastrocs accel data for both locations (used for labeling)
clear all

Fs=250; % Sampling Frequency
HPF=3; % Frequency for High-Pass filter on EMG data
initBuff=3000;
% Subjects to exclude from loop
% RemoveSub={'CS001', 'CS002', 'CS003', 'CS004', 'CS005', 'CS006', 'CS007', 'CS008', 'CS009', 'CS011', 'CS012', 'CS013', 'CS014', 'CS015'};
RemoveSub={};
dirname='Z:\Stroke MC10\SCI\';
Locations={'HAM','RF','GA','TA','Foot','Heel'};
% Locations={'Medial Chest'};

% Identify Directories with Raw Subject Data
filenames=dir([dirname 'CS*']);
NotDirectories=cellfun(@(x) x==0, {filenames.isdir});
filenames(NotDirectories)=[];
% Remove listed subjects from loop
for i=1:length(RemoveSub)
    ExtraSub=cellfun(@(x) strcmp(x,RemoveSub{i}), {filenames.name});
    filenames(ExtraSub)=[];
end

% Loop through subjects and lab sessions
for indDir=1:length(filenames)
    for Day=1:2
        numDay=num2str(Day);
        subject=filenames(indDir).name;
        TimesName=[dirname subject '\Lab Day ' numDay '\' subject '_Day' numDay '_Times.mat'];
        % skip if data missing
        if ~exist(TimesName,'file')
            continue
        end
        load([dirname subject '\Lab Day ' numDay '\' subject '_Day' numDay '_Times.mat'])
    % Loop through activity list in Times
    parfor i=1:height(Times)
        for indLoc=1:length(Locations)
            startStamp=datetime(1970, 1, 1, 0, 0, Times.Start(i)/1000);

            datafiles=dir([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} '\']);
            NotDirectories=cellfun(@(x) strcmp(x(1),'.'), {datafiles.name});
            datafiles(NotDirectories)=[];

            % Get timestamps of recording start from file names
            fileStamp=datetime(zeros(2,3));
            for indData=1:length(datafiles)
                fileTime=datafiles(indData).name;            
                fileStamp(indData)=datetime(str2double(fileTime(1:4)), str2double(fileTime(6:7)), str2double(fileTime(9:10)),...
                    str2double(fileTime(12:13)), str2double(fileTime(15:16)), str2double(fileTime(17:18)));
            end

            % Multiple data recordings may be present
            % Find index of correct recording file
            ind=find(startStamp>fileStamp==0,1);
            if ind>1
                ind=ind-1;
            end
            if isempty(ind)
                ind=length(datafiles);
            end

            % Load EMG data
            afe=xlsread([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} ... 
                '\' datafiles(ind).name '\sensors\afe.csv']);
            % Only load accel data from Gastrocs
            if strcmp(Locations{indLoc},'Gastrocnemius')
                accel=xlsread([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} ... 
                    '\' datafiles(ind).name '\sensors\accel.csv']);
            end
            % Identify start and end indices in data
            [~,Start]=min(abs(afe(:,1)-Times.Start(i)+initBuff));
            [~,Stop]=min(abs(afe(:,1)-Times.End(i)-initBuff));

            if Start-Stop==0
                continue
            end

            EMG=afe(Start:Stop,:);
            
            % Resample EMG to 250 Hz
            EMG(:,1)=(EMG(:,1))/1000;

            t=min(EMG(:,1)):0.004:max(EMG(:,1));
            EMG=spline(EMG(:,1).', EMG(:,2).', t.');
            EMG=[t.' EMG];
            Data=EMG;
                  
            
            if ~strcmp(Locations{indLoc},'Medial Chest')
                [B,A] = butter(1, HPF*2/Fs, 'high');
                EMG(:,2)=filtfilt(B,A,EMG(:,2));

                % Extract Accel data and resample to 250 Hz
                [~,Start]=min(abs(accel(:,1)-Times.Start(i)+initBuff));
                [~,Stop]=min(abs(accel(:,1)-Times.End(i)-initBuff));

                ACC=accel(Start:Stop,:);
                ACC(:,1)=(ACC(:,1))/1000;

                t=min(EMG(:,1)):0.004:max(EMG(:,1));
                ACC=spline(ACC(:,1).', ACC(:,2:end).', t.');
                t=t-t(1);
                ACC=[t.' ACC.'];

                % Store data together
                Data=[ACC EMG(:,2)];
            end
            % Add Hamstring accel data if using Hamstring EMG
            if ~strcmp(Locations{indLoc},'Gastrocnemius')
                ham_acc=xlsread([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} ... 
                    '\' datafiles(ind).name '\sensors\accel.csv']);
                [~,Start]=min(abs(ham_acc(:,1)-Times.Start(i)+initBuff));
                [~,Stop]=min(abs(ham_acc(:,1)-Times.End(i)-initBuff));
                ACC=ham_acc(Start:Stop,:);
                ACC(:,1)=(ACC(:,1))/1000;

                t=min(EMG(:,1)):0.02:max(EMG(:,1));
                ACC=spline(ACC(:,1).', ACC(:,2:end).', t.');
                ACC=[t.' ACC.'];
                if ~strcmp(Locations{indLoc},'Medial Chest')
                    Data=[Data ACC(:,2:end)];
                end
            end
            % Save prepped data
            X=cell2mat(Times.Label(i));

            saveName=[dirname 'PreppedData\' subject '\Lab Day' num2str(Day) '\' Locations{indLoc} ...
                '_' X '_emgData.csv'];
            
            accName=[dirname '6MWT ACC\' subject '_Day' num2str(Day) ...
                '_' X '_accData.csv'];

            if ~exist([dirname 'PreppedData\' subject], 'dir')
                mkdir([dirname 'PreppedData\' subject])
            end
            if ~exist([dirname 'PreppedData\' subject '\Lab Day' num2str(Day)], 'dir')
                mkdir([dirname 'PreppedData\' subject '\Lab Day' num2str(Day)])
            end

            dlmwrite(saveName,Data,'delimiter',',','precision',13)
            dlmwrite(accName,ACC,'delimiter',',','precision',13)
        end
    end
    end
end