% Generate Clips for MC10 data from Phone Labels
% Run after GenerateActivityData.m
clear all

clipLength=5;
Fs=50;
clipOverlap=.5;

clipSize=ceil(clipLength*Fs);
overlapSize=ceil(clipOverlap*clipSize);

dirname='Z:\Stroke MC10\Activity Recognition\TrimmedData';
Activities={'Lying' 'Sitting' 'Standing' 'Stairs Up' 'Stairs Down' 'Walking'};

filenames=dir([dirname '\ActivityData\ACC\*.csv']);
names={filenames.name};
Subj=cell(length(names),1);
for i=1:length(names)
    Subj{i}=names{i}(1:5);
end
Subj=unique(Subj);

AllFeat=struct('SubjID', '',  'ActivityLabel', Subj, 'Features', [], ...
    'SamplingT', 20, 'ClipDur', clipLength, 'ClipOverlap', clipOverlap, 'RecordingDur', 0);

for indSub=1:length(Subj)
    Label={};
    SubjFeat=[];
    for indAct=1:length(Activities)
        Data=readtable([dirname '\ActivityData\ACC\' Subj{indSub} '_' Activities{indAct} '_train.csv'],...
            'ReadVariableNames',false);
        EMG=readtable([dirname '\ActivityData\EMG\' Subj{indSub} '_' Activities{indAct} '_train.csv'],...
            'ReadVariableNames',false);
        numClips=floor((height(Data)-overlapSize)/(clipSize-overlapSize));
        
        for indClip=1:numClips
            clip=cell2mat(table2cell(Data(...
                (indClip-1)*(clipSize-overlapSize)+1:(indClip-1)*(clipSize-overlapSize)+clipSize,:)));
            EMG_clip=cell2mat(table2cell(EMG(...
                5*(indClip-1)*(clipSize-overlapSize)+1:5*(indClip-1)*(clipSize-overlapSize)+clipSize,:)));
            X=mean(cross(clip(:,1:3),clip(:,4:6)));
            Feat=[getFeatures(clip(:,1:3).') getFeatures(clip(:,4:6).') X/norm(X) ...
                getEMGFeatures(EMG_clip(:,1).') getEMGFeatures(EMG_clip(:,2).')];
            SubjFeat=[SubjFeat; Feat];
            Label{end+1}=Activities{indAct};
        end
    end
    SubjFeatures=struct('SubjID', Subj{indSub},  'ActivityLabel', {Label}, 'Features', SubjFeat, ...
        'SamplingT', 20, 'ClipDur', clipLength, 'ClipOverlap', clipOverlap, 'RecordingDur', 0);    

    AllFeat(indSub)=SubjFeatures;
end
save([dirname '\ActivityData\TrainFeat.mat'], 'AllFeat')
        
for indSub=1:length(Subj)
    Label={};
    SubjFeat=[];
    for indAct=1:length(Activities)
        Data=readtable([dirname '\ActivityData\ACC\' Subj{indSub} '_' Activities{indAct} '_test.csv'],...
            'ReadVariableNames',false);
        EMG=readtable([dirname '\ActivityData\EMG\' Subj{indSub} '_' Activities{indAct} '_test.csv'],...
            'ReadVariableNames',false);
        numClips=floor((height(Data)-overlapSize)/(clipSize-overlapSize));
        
        for indClip=1:numClips
            clip=cell2mat(table2cell(Data(...
                (indClip-1)*(clipSize-overlapSize)+1:(indClip-1)*(clipSize-overlapSize)+clipSize,:)));
            EMG_clip=cell2mat(table2cell(EMG(...
                5*(indClip-1)*(clipSize-overlapSize)+1:5*(indClip-1)*(clipSize-overlapSize)+clipSize,:)));
            X=mean(cross(clip(:,1:3),clip(:,4:6)));
            Feat=[getFeatures(clip(:,1:3).') getFeatures(clip(:,4:6).') X/norm(X) ...
                getEMGFeatures(EMG_clip(:,1).') getEMGFeatures(EMG_clip(:,2).')];
            SubjFeat=[SubjFeat; Feat];
            Label{end+1}=Activities{indAct};
        end
    end
    SubjFeatures=struct('SubjID', Subj{indSub},  'ActivityLabel', {Label}, 'Features', SubjFeat, ...
        'SamplingT', 20, 'ClipDur', clipLength, 'ClipOverlap', clipOverlap, 'RecordingDur', 0);    

    AllFeat(indSub)=SubjFeatures;
end
save([dirname '\ActivityData\TestFeat.mat'], 'AllFeat')
