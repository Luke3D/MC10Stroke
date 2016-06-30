%% PrepMC10Data
% Preps EMG and ACC data for labeling
%   -Resamples to 250 Hz
%   -High-pass filter on EMG data
%   -Stores data in PreppedData folder
%   -Includes Gastrocs accel data for both locations (used for labeling)
clear all

Fs=250; % Sampling Frequency
HPF=10; % Frequency for High-Pass filter on EMG data
initBuff=3000;
% Subjects to exclude from loop
% RemoveSub={'CS001', 'CS002', 'CS003', 'CS004', 'CS005', 'CS006', 'CS007', 'CS008', 'CS009', 'CS011', 'CS012'};
RemoveSub={};
dirname='Z:\Stroke MC10\';
Locations={'Medial Chest'};

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
    for i=1:height(Times)
        for indLoc=1:length(Locations)
            if isempty(strmatch(Times.Label{i},'6MWT'))
                continue
            end
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
            if ind==0
                continue
            end            
            
            % Load EMG data
            if exist([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} ... 
                '\' datafiles(ind).name '\sensors\afe.csv'],'file')
                afe=xlsread([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} ... 
                    '\' datafiles(ind).name '\sensors\afe.csv']);
            else
                afe=xlsread([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} ... 
                    '\' datafiles(ind).name '\sensors\ecg.csv']);               
            end
            % load accel data
            accel=xlsread([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} ... 
                '\' datafiles(ind).name '\sensors\accel.csv']);
            
            if afe(end,1)-Times.Start(i)<0;            
                ind=ind+1;
                if exist([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} ... 
                    '\' datafiles(ind).name '\sensors\afe.csv'],'file')
                    afe=xlsread([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} ... 
                        '\' datafiles(ind).name '\sensors\afe.csv']);
                else
                    afe=xlsread([dirname subject '\Lab Day ' numDay '\' Locations{indLoc} ... 
                        '\' datafiles(ind).name '\sensors\ecg.csv']);               
                end
                % load accel data
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

            % Extract Accel data and resample to 250 Hz
            [~,Start]=min(abs(accel(:,1)-Times.Start(i)+initBuff));
            [~,Stop]=min(abs(accel(:,1)-Times.End(i)-initBuff));

            ACC=accel(Start:Stop,:);
            ACC(:,1)=(ACC(:,1))/1000;

            t=min(EMG(:,1)):0.02:max(EMG(:,1));
            ACC=spline(ACC(:,1).', ACC(:,2:end).', t.');
            t=t-t(1);
            ACC=[t.' ACC.'];
            
            % Save prepped data
            X=cell2mat(Times.Label(i));

            saveName=[dirname '6MWT ECG\' subject '_Day' num2str(Day) '_' X ...
                '_ecgData.csv'];
            
            accName=[dirname '6MWT ACC\' subject '_Day' num2str(Day) ...
                '_' X '_accData.csv'];


            dlmwrite(saveName,EMG,'delimiter',',','precision',13)
            dlmwrite(accName,ACC,'delimiter',',','precision',13)
        end
    end
    end
end