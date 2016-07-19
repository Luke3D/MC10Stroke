% Zero EMG Analysis
% Analyzes EMG activity of patients with an Ashworth Score of 0
% Can be run independently from PredictAccuracy.m, DataProcessing.m, and
% ErrorAnalysis.m
% Can be modified to plot EMG activity of patients with different Ashworth
% scores (1, 1+, 2, 3) Default data set is for 0
%--------------------------------------------------------------------------
load('AshworthScores.mat')
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Patients with an Ashworth Score of 0
% Hamstring:        14
% Gastrocnemius     2-11, 13-15, 20, 29 (index of 27)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Patients with an Ashworth Score of 1
% Hamstring:        1, 3, 4, 9, 11, 13
% Gastrocnemius:    17-19, 25-28
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Patients with an Ashworth Score of 1+
% Hamstring:        2, 6-8, 12, 19 (index of 15)
% Gastrocnemius:    12
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Patients with an Ashworth Score of 2
% Hamstring:        10
% Gastrocnemius:    16
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Patients with an Ashworth Score of 3
% Hamstring:        5
% Gastrocnemius:    1, 23, 24 (index of 21 and 22, respectively)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
dirname = 'Z:\Stroke MC10\PreppedData\CS0';
gEMG = {};  hEMG = {};

% h = ['14'];                  % Ashworth Score of 0
% g = [2:11 13:15 20 29]';    


% h = [1 3 4 9 11 13]';        % Ashworth Score of 1
% g = [17:19 25:28]';

% h = [2 6:8 12 19]';          % Ashworth Score of 1+
% g = ['12'];

% h = ['10'];                  % Ashworth Score of 2
% g = ['16'];

% h = [' 5'];                   % Ashworth Score of 3
% g = [1 23 24]';

% g=([1:20 23:29])'; % Gastrocnemius index
% h=([1:15])'; % Hamstring index

g = [1 29]';
h = [1:15]';

subject1 = num2str(g);
subject2 = num2str(h);

for i=1:size(subject1,1)
    if strcmp(subject1(i,1),' ')
        subject1(i,1)='0';
    end
end

for i=1:size(subject2,1)
    if strcmp(subject2(i,1),' ')
        subject2(i,1)='0';
    end
end

filenames1 = [];
for jj=1:size(subject1,1)
    filenames1 = [filenames1; rdir([dirname subject1(jj,:) '\**\' 'Gastrocnemius*MAS' '*' 'PF_emgData.csv'])];
    len1(jj) = length(filenames1);
end

filenames2 = [];
for i = 1:size(subject2,1);
    filenames2 = [filenames2; rdir([dirname subject2(i,:) '\**\' 'Hamstring*MAS' '*' 'KF_emgData.csv'])];
    len2(i) = length(filenames2);
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% GASTROCNEMIUS DATA COLLECTION
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
EMG_RAW = [];   EMG = [];   temp = [];

for i = 1:length(filenames1)
    [temp, ~, ~] = xlsread(filenames1(i).name);
    EMG_RAW{i}=[temp(:,1) temp(:,5)];
    EMGtemp=abs(EMG_RAW{i}(:,2));
    [B,A] = butter(1, 20/125, 'low');
    EMG{i}=filtfilt(B,A,EMGtemp);
end

emgTime = [];   emgData = [];   emgRaw = [];

% If needed, add code to separate EMG activity and times by day
for x = 1:size(subject1,1)
    if x == 1
        for i = 1:len1(1);
            % = [emgTime; EMG_RAW{i}(:,1)];
            emgData = [emgData; EMG{i}];
            emgRaw = [emgRaw; EMG_RAW{i}(:,2)];
        end
        
        %gEMG{x}(:,1) = emgTime;
        gEMG{x}(:,2) = emgData;
        gEMG{x}(:,3) = emgRaw;
        
        emgTime = [];   emgData = [];   emgRaw = [];

    else
        for i = len1(x-1) + 1 : len1(x)
            %emgTime = [emgTime; EMG_RAW{i}(:,1)];
            emgData = [emgData; EMG{i}];
            emgRaw = [emgRaw; EMG_RAW{i}(:,2)];
        end

        %gEMG{x}(:,1) = emgTime;
        gEMG{x}(:,2) = emgData;
        gEMG{x}(:,3) = emgRaw;
        
        emgTime = [];   emgData = [];   emgRaw = [];
    end
end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% HAMSTRING DATA COLLECTION
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
EMG_RAW = [];   EMG = [];   temp = [];

for i = 1:length(filenames2)
    [temp, ~, ~] = xlsread(filenames2(i).name);
    EMG_RAW{i}=[temp(:,1) temp(:,5)];
    EMGtemp=abs(EMG_RAW{i}(:,2));
    [B,A] = butter(1, 20/125, 'low');
    EMG{i}=filtfilt(B,A,EMGtemp);
end

for x = 1:size(subject2,1)
    if x == 1
        for i = 1:len2(1);
            %emgTime = [emgTime; EMG_RAW{i}(:,1)];
            emgData = [emgData; EMG{i}];
            emgRaw = [emgRaw; EMG_RAW{i}(:,2)];
        end
        
        %hEMG{x}(:,1) = emgTime;
        hEMG{x}(:,2) = emgData;
        hEMG{x}(:,3) = emgRaw;
        
        emgTime = [];   emgData = [];   emgRaw = [];

    else
        for i = len2(x-1) + 1 : len2(x)
            %emgTime = [emgTime; EMG_RAW{i}(:,1)];
            emgData = [emgData; EMG{i}];
            emgRaw = [emgRaw; EMG_RAW{i}(:,2)];
        end

        %hEMG{x}(:,1) = emgTime;
        hEMG{x}(:,2) = emgData;
        hEMG{x}(:,3) = emgRaw;
        
        emgTime = [];   emgData = [];   emgRaw = [];
    end
end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% DATA PLOTTING
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% change subject1 to subject2 for hamstring, or vice versa
for i = 1:size(subject1,1)
        figure
        subplot(2,1,1)
        plot(gEMG{i}(:,2))
        xlabel('Time [ms]')
        ylabel('Voltage [V]')
        title(['CS0' subject1(i,:) ': Filtered EMG Signal'])
        v = axis;

        
        subplot(2,1,2)
        plot(gEMG{i}(:,3))
        xlabel('Time [ms]')
        ylabel('Voltage [V]')
        axis(v)
        title(['CS0' subject1(i,:) ': Raw EMG Signal'])
end