%% Extract Activity Data using Phone Labels
% finds MC10 data for each phone label and identifies the subject
% interpolates data to 50 Hz and saves gastrocnemius and hamstring acc data

clear all

load 'Z:\Stroke MC10\MC10Sessions.mat'

Act_Labels=readtable('Z:\Stroke MC10\Activity Recognition\Labels_stroke.csv', 'ReadVariableNames', false, 'Delimiter', ',');
% gasFilenames=rdir('Z:\Stroke MC10\CS*\**\Gastrocnemius\**\accel.csv');
% gasFilenames={gasFilenames.name}.';
% hamFilenames=rdir('Z:\Stroke MC10\CS*\**\Hamstring\**\accel.csv');
% hamFilenames={hamFilenames.name}.';

for indLab=1122:height(Act_Labels)
    
    startStamp=datetime(1970, 1, 1, 0, 0, Act_Labels.Var3(indLab)/1000);
    
    indM=1;
    stop1=0;
    while (startStamp<Subject_IDs{indM,2} || startStamp>Subject_IDs{indM,3}) && ~stop1
        indM=indM+1;
        if indM>size(Subject_IDs,1)
            stop1=1;
            indM=indM-1;
        end
    end 
    stop2=0;
    Day='Lab Day 1';
    if stop1
        Day='Lab Day 2';
        indM=1;
        while (startStamp<Subject_IDs{indM,5} || startStamp>Subject_IDs{indM,6}) && ~stop2
            indM=indM+1;
            if indM>size(Subject_IDs,1)
                stop2=1;
                indM=indM-1;
            end
        end
    end
    
    if stop2
        continue
    end
    
    if indM>28
        continue
    end
    
    Subj=Subject_IDs{indM,1};
    
    gasFilenames=rdir(['Z:\Stroke MC10\' Subj '\' Day '\Gastrocnemius\**\accel.csv']);
    gasFilenames={gasFilenames.name}.';
    hamFilenames=rdir(['Z:\Stroke MC10\' Subj '\' Day '\Hamstring\**\accel.csv']);
    hamFilenames={hamFilenames.name}.';

    gasDateTime=zeros(length(gasFilenames),6);

    for indFile=1:length(gasFilenames)

        file=gasFilenames{indFile};
        gasDateTime(indFile,:)=[str2double(file(46:49)) str2double(file(51:52)) ...
            str2double(file(54:55)) str2double(file(57:58)) ...
            str2double(file(60:61)) str2double(file(63:64))];
    end

    gasDateTime=datetime(gasDateTime);
    [gasDateTime, gasI]=sort(gasDateTime);

    hamDateTime=zeros(length(hamFilenames),6);

    for indFile=1:length(hamFilenames)

        file=hamFilenames{indFile};
        hamDateTime(indFile,:)=[str2double(file(42:45)) str2double(file(47:48)) ...
            str2double(file(50:51)) str2double(file(53:54)) ...
            str2double(file(56:57)) str2double(file(59:60))];
    end

    hamDateTime=datetime(hamDateTime);
    [hamDateTime, hamI]=sort(hamDateTime);
    
    if isempty(gasDateTime) || isempty(hamDateTime)
        continue
    end
    
    ind=find(startStamp>gasDateTime==0,1);
    if ind>1
        ind=ind-1;
    end
    if isempty(ind)
        ind=length(gasFilenames);
    end
    
    gasData=csvread(gasFilenames{gasI(ind)},1,0);
    if exist([gasFilenames{gasI(ind)}(1:end-9) 'afe.csv'],'file')
        gasEMG=csvread([gasFilenames{gasI(ind)}(1:end-9) 'afe.csv'],1,0);
    else
        gasEMG=csvread([gasFilenames{gasI(ind)}(1:end-9) 'emg.csv'],1,0);
    end
    
    if gasEMG(end,1)-Act_Labels.Var3(indLab)<0
        if ind<length(gasFilenames)
            ind=ind+1;
        end
        gasData=csvread(gasFilenames{gasI(ind)},1,0);
        if exist([gasFilenames{gasI(ind)}(1:end-9) 'afe.csv'],'file')
            gasEMG=csvread([gasFilenames{gasI(ind)}(1:end-9) 'afe.csv'],1,0);
        else
            gasEMG=csvread([gasFilenames{gasI(ind)}(1:end-9) 'emg.csv'],1,0);
        end
    end
    
    name=gasFilenames{ind};
    if str2double(name(30))==1
        Day='Train';
    else
        Day='Test';
    end
    
    Subj=name(16:20);
    
    [~,Start]=min(abs(gasData(:,1)-Act_Labels.Var3(indLab)));
    [~,Stop]=min(abs(gasData(:,1)-Act_Labels.Var4(indLab)));

    if Start-Stop==0
        continue
    end
    
    [~,Start_EMG]=min(abs(gasEMG(:,1)-Act_Labels.Var3(indLab)));
    [~,Stop_EMG]=min(abs(gasEMG(:,1)-Act_Labels.Var4(indLab)));

    if Start_EMG-Stop_EMG==0
        continue
    end
    
    gasData=gasData(Start:Stop,:);
    gasEMG=gasEMG(Start_EMG:Stop_EMG,:);
    
    ind=find(startStamp>hamDateTime==0,1);
    if ind>1
        ind=ind-1;
    end
    if isempty(ind)
        ind=length(hamFilenames);
    end
    
    hamData=csvread(hamFilenames{hamI(ind)},1,0);
    if exist([hamFilenames{hamI(ind)}(1:end-9) 'afe.csv'],'file')
        hamEMG=csvread([hamFilenames{hamI(ind)}(1:end-9) 'afe.csv'],1,0);
    else
        hamEMG=csvread([hamFilenames{hamI(ind)}(1:end-9) 'emg.csv'],1,0);
    end
    
    if hamEMG(end,1)-Act_Labels.Var3(indLab)<0
        if ind<length(hamFilenames)
            ind=ind+1;
        end
        hamData=csvread(hamFilenames{hamI(ind)},1,0);
        if exist([hamFilenames{hamI(ind)}(1:end-9) 'afe.csv'],'file')
            hamEMG=csvread([hamFilenames{hamI(ind)}(1:end-9) 'afe.csv'],1,0);
        else
            hamEMG=csvread([hamFilenames{hamI(ind)}(1:end-9) 'emg.csv'],1,0);
        end
    end
    
    [~,Start]=min(abs(hamData(:,1)-Act_Labels.Var3(indLab)));
    [~,Stop]=min(abs(hamData(:,1)-Act_Labels.Var4(indLab)));

    if Start-Stop==0
        continue
    end
    
    [~,Start_EMG]=min(abs(hamEMG(:,1)-Act_Labels.Var3(indLab)));
    [~,Stop_EMG]=min(abs(hamEMG(:,1)-Act_Labels.Var4(indLab)));

    if Start_EMG-Stop_EMG==0
        continue
    end
    
    hamData=hamData(Start:Stop,:);
    hamEMG=hamEMG(Start_EMG:Stop_EMG,:);
    
    if hamData(1,1)<gasData(1,1)
        tStart=gasData(1,1);
    else
        tStart=hamData(1,1);
    end
    
    if hamData(end,1)>gasData(end,1)
        tEnd=gasData(end,1);
    else
        tEnd=hamData(end,1);
    end
    
    if hamEMG(1,1)<gasEMG(1,1)
        tStart_EMG=gasEMG(1,1);
    else
        tStart_EMG=hamEMG(1,1);
    end
    
    if hamEMG(end,1)>gasEMG(end,1)
        tEnd_EMG=gasEMG(end,1);
    else
        tEnd_EMG=hamEMG(end,1);
    end
    
    if tEnd_EMG<tEnd
        tStart=tStart_EMG;
    else
        tStart_EMG=tStart;
    end
    
    if tEnd_EMG<tEnd
        tEnd=tEnd_EMG;
    else
        tEnd_EMG=tEnd;
    end
    
    % Resample to 50 Hz to time normalize
    gasData=[tStart:1000/50:tEnd; spline(gasData(:,1).',gasData(:,2:end).',tStart:1000/50:tEnd)].';
    hamData=[tStart:1000/50:tEnd; spline(hamData(:,1).',hamData(:,2:end).',tStart:1000/50:tEnd)].';
    
    gasEMG=[tStart_EMG:1000/250:tEnd_EMG; spline(gasEMG(:,1).',gasEMG(:,2:end).',tStart_EMG:1000/250:tEnd_EMG)].';
    hamEMG=[tStart_EMG:1000/250:tEnd_EMG; spline(hamEMG(:,1).',hamEMG(:,2:end).',tStart_EMG:1000/250:tEnd_EMG)].';
    
    Data=[gasData hamData(:,2:end)];
    EMG=[gasEMG hamEMG(:,2)];
    
    Act=Act_Labels.Var5(indLab);
    num=Act_Labels.Var1(indLab);
    
    dlmwrite(['Z:\Stroke MC10\Activity Recognition\RawData\' Day '\ACC\' Subj '_' Act{1} '_' num2str(num) '.csv'], Data, 'Precision', 14)
    dlmwrite(['Z:\Stroke MC10\Activity Recognition\RawData\' Day '\EMG\' Subj '_' Act{1} '_' num2str(num) '_EMG.csv'], EMG, 'Precision', 14)
end
  
    