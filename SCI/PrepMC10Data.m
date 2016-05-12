%% PrepMC10Data
% Sorts Through Available Subject Data
% Preps EMG and ACC data for labeling
%   -Resamples to 250 Hz
%   -High-pass filter on EMG data
%   -Stores data in PreppedData folder
%   -Includes Gastrocs accel data for both locations (used for labeling)
clear all

Fs=250; % Sampling Frequency of EMG
HPF=3; % Frequency for High-Pass filter on EMG data (Hz)
% Subjects to exclude from loop
RemoveSub={};

dirname='Z:\Stroke MC10\SCI\RawData';
savedirname='Z:\Stroke MC10\SCI';
Locations={'HA','RF','GA','TA','Foot','Heel'};
% Locations={'Medial Chest'};
Segments={'Thigh' 'Shank'};

% Identify Directories with Raw Subject Data
subjnames=dir([dirname '\NST*']);
Directories=cellfun(@(x) x==0, {subjnames.isdir});
subjnames(Directories)=[];
% Remove listed subjects from loop
for i=1:length(RemoveSub)
    ExtraSub=cellfun(@(x) strcmp(x,RemoveSub{i}), {subjnames.name});
    subjnames(ExtraSub)=[];
end

% Loop through subjects and lab sessions
for indDir=1:length(subjnames)
    subject=subjnames(indDir).name;
    days=dir([dirname '\' subject]);
    days(1:2)=[];
    for indDay=1:length(days)
        day=days(indDay).name;
        sensors=['D5LA7WZ6'; 'D5LA7XEW'; 'D5LA7XJP'; 'D5LA7XNA'; 'D14SPK1B'; 'D5LA7XK4'];
        for indSens=4:2:6
            sensor=sensors(indSens,:);

            datafiles=dir([dirname '\' subject '\' day '\' sensor '\*Accel.csv']);
            
            names=cell(length(datafiles));
            events=cell(length(datafiles));
            
            for i=1:length(datafiles)
                names{i}=strsplit(datafiles(i).name,{'_' '.'});
                events{i}=names{i}{1};
            end
            
            for indData=1:length(datafiles)
                name=names{indData};
                ACCdata=table2cell(readtable([dirname '\' subject '\' day '\' sensor ...
                    '\' datafiles(indData).name],'ReadVariableNames',false,'HeaderLines',1));
                ACCdata=cell2mat(ACCdata(:,2:end));
                
                EMGsensor1=sensors(indSens-3,:);
                EMGsensor2=sensors(indSens-2,:);
                
                EMGdata1=table2cell(readtable([dirname '\' subject '\' day '\' EMGsensor1 ...
                    '\' datafiles(indData).name(1:end-9) 'EMG.csv'],...
                    'ReadVariableNames',false,'HeaderLines',1));
                EMGdata1=cell2mat(EMGdata1(:,2:3));
                
                EMGdata2=table2cell(readtable([dirname '\' subject '\' day '\' EMGsensor2 ...
                    '\' datafiles(indData).name(1:end-9) 'EMG.csv'],...
                    'ReadVariableNames',false,'HeaderLines',1));
                EMGdata2=cell2mat(EMGdata2(:,2:3));
                
                event=name{1};
                
                % Check for other files with same event to get an index to
                % Distinguish distinct repititions
                before_matches=strcmp(events(1:indData-1), ...
                    events{indData});
                before_matches=sum(before_matches);
                event_ind=before_matches+1;
                
                if before_matches==0;
                    after_matches=strcmp(events(indData+1:end), ...
                        events{indData});
                    after_matches=sum(after_matches);
                    event_ind=(after_matches>0);
                end
                
                if event_ind
                    event=[event '_' num2str(event_ind)];
                end
                
                dataSavename=[event '.csv'];
                
                % Identify start and end indices in data
                Start=max([EMGdata1(1,1) EMGdata2(1,1) ACCdata(1,1)])/1000;
                Stop=min([EMGdata1(end,1) EMGdata2(end,1) ACCdata(end,1)])/1000;

                % Resample data to 250 Hz
                ACCdata(:,1)=(ACCdata(:,1))/1000;
                EMGdata1(:,1)=(EMGdata1(:,1))/1000;
                EMGdata2(:,1)=(EMGdata2(:,1))/1000;

                t=Start:0.004:Stop;

                ACCdata=spline(ACCdata(:,1).', ACCdata(:,2:end).', t.').';
                EMGdata1=spline(EMGdata1(:,1).', EMGdata1(:,2).', t.');
                EMGdata2=spline(EMGdata2(:,1).', EMGdata2(:,2).', t.');

                [B,A] = butter(1, HPF*2/Fs, 'high');
                EMGdata1=filtfilt(B,A,EMGdata1);
                EMGdata2=filtfilt(B,A,EMGdata2);
                
                Data=[(t-t(1)).' ACCdata EMGdata1 EMGdata2];

                Data=table(Data(:,1), Data(:,2), Data(:,3), Data(:,4), Data(:,5), Data(:,6),'VariableNames',{'Time','xACC','yACC',...
                    'zACC',Locations{indSens-3},Locations{indSens-2}});

                if ~exist([savedirname '\EMGtoLabel\' subject '\' day '\' Segments{indSens/2-1}], 'dir')
                    mkdir([savedirname '\EMGtoLabel\' subject '\' day '\' Segments{indSens/2-1}])
                end

                writetable(Data,[savedirname '\EMGtoLabel\' subject '\' day ...
                    '\' Segments{indSens/2-1} '\' dataSavename])
            end
        end
    end
end