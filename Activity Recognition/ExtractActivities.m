%% Extract Activity Data using Phone Labels

clear all

Act_Labels=readtable('Z:\Stroke MC10\Activity Recognition\Labels.csv', 'ReadVariableNames', false, 'Delimiter', '\t');
gasFilenames=rdir('Z:\Stroke MC10\CS*\**\Gastrocnemius\**\accel.csv');
gasFilenames={gasFilenames.name}.';
hamFilenames=rdir('Z:\Stroke MC10\CS*\**\Hamstring\**\accel.csv');
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

for indLab=1:height(Act_Labels)
    
    startStamp=datetime(1970, 1, 1, 0, 0, Act_Labels.Var3(indLab)/1000);
    ind=find(startStamp>gasDateTime==0,1);
    if ind>1
        ind=ind-1;
    end
    if isempty(ind)
        ind=length(gasFilenames);
    end
    
    gasData=csvread(gasFilenames{gasI(ind)},1,0);
    
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
    
    gasData=gasData(Start:Stop,:);
    
    ind=find(startStamp>hamDateTime==0,1);
    if ind>1
        ind=ind-1;
    end
    if isempty(ind)
        ind=length(hamFilenames);
    end
    
    hamData=csvread(hamFilenames{hamI(ind)},1,0);
    
    [~,Start]=min(abs(hamData(:,1)-Act_Labels.Var3(indLab)));
    [~,Stop]=min(abs(hamData(:,1)-Act_Labels.Var4(indLab)));

    if Start-Stop==0
        continue
    end
    
    hamData=hamData(Start:Stop,:);
    
    if hamData(1,1)<gasData(1,1)
        tStart=gasData(1,1);
    else
        tStart=hamData(1,1);
    end
    
    if hamData(end,1)<gasData(end,1)
        tEnd=gasData(end,1);
    else
        tEnd=hamData(end,1);
    end
    
    gasData=spline(gasData(:,1).',gasData(:,2:end).',tStart:1000/50:tEnd).';
    hamData=spline(hamData(:,1).',hamData(:,2:end).',tStart:1000/50:tEnd).';
    
    Data=[gasData hamData];
    
    Act=Act_Labels.Var5(indLab);
    
    csvwrite(['Z:\Stroke MC10\Activity Recognition\RawData\' Day '\' Subj '_' Act{1} '_' num2str(indLab) '.csv'], Data)
end
  
    