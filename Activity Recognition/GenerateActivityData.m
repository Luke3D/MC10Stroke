% Generate Activity files for MC10 Data from Phone Labels
% Resulting files contain trimmed label data placed stitched together
clear all

% Carried over from previous version: this function is now performed by 
% TrimLabeledData.m
windowLength=0; % Amount to remove from both sides of data
dirname='Z:\Stroke MC10\Activity Recognition\TrimmedData\';
Activities={'Lying' 'Sitting' 'Standing' 'Stairs Up' 'Stairs Down' 'Walking'};

filenames=dir([dirname 'Train\ACC\*.csv']);
    
names={filenames.name};
Subj=cell(length(names),1);
for i=1:length(names)
    Subj{i}=names{i}(1:5);
end
Subj=unique(Subj);

for indAct=1:length(Activities)
    for indSub=1:length(Subj)
        filenames=dir([dirname 'Train\ACC\' Subj{indSub} '_' Activities{indAct} '*.csv']);
        AllData=[];
        for indFile=1:length(filenames)
            Data=csvread([dirname 'Train\ACC\' filenames(indFile).name]);
            % remove extraneous zeros
            zinds=max(abs(Data),[],2)==0;
            Data(zinds,:)=[];
            AllData=[AllData; Data(windowLength*50+1:end-windowLength*50,:)];
        end
        csvwrite([dirname 'ActivityData\ACC\' Subj{indSub} '_' Activities{indAct} '_Train.csv'], AllData)
    end
end

for indAct=1:length(Activities)
    for indSub=1:length(Subj)
        filenames=dir([dirname 'Test\ACC\' Subj{indSub} '_' Activities{indAct} '*.csv']);
        AllData=[];
        for indFile=1:length(filenames)
            Data=csvread([dirname 'Test\ACC\' filenames(indFile).name]);
            % remove extraneous zeros
            zinds=max(abs(Data),[],2)==0;
            Data(zinds,:)=[];
            AllData=[AllData; Data(windowLength*50+1:end-windowLength*50,:)];
        end
        csvwrite([dirname 'ActivityData\ACC\' Subj{indSub} '_' Activities{indAct} '_Test.csv'], AllData)
    end
end

for indAct=1:length(Activities)
    for indSub=1:length(Subj)
        filenames=dir([dirname 'Train\EMG\' Subj{indSub} '_' Activities{indAct} '*.csv']);
        AllData=[];
        for indFile=1:length(filenames)
            Data=csvread([dirname 'Train\EMG\' filenames(indFile).name]);
            % remove extraneous zeros
            zinds=max(abs(Data),[],2)==0;
            Data(zinds,:)=[];
            AllData=[AllData; Data(windowLength*50+1:end-windowLength*50,:)];
        end
        csvwrite([dirname 'ActivityData\EMG\' Subj{indSub} '_' Activities{indAct} '_Train.csv'], AllData)
    end
end

for indAct=1:length(Activities)
    for indSub=1:length(Subj)
        filenames=dir([dirname 'Test\EMG\' Subj{indSub} '_' Activities{indAct} '*.csv']);
        AllData=[];
        for indFile=1:length(filenames)
            Data=csvread([dirname 'Test\EMG\' filenames(indFile).name]);
            % remove extraneous zeros
            zinds=max(abs(Data),[],2)==0;
            Data(zinds,:)=[];
            AllData=[AllData; Data(windowLength*50+1:end-windowLength*50,:)];
        end
        csvwrite([dirname 'ActivityData\EMG\' Subj{indSub} '_' Activities{indAct} '_Test.csv'], AllData)
    end
end