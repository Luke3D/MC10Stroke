%% Generate Clips from labeled data
% Uses getFeatures.m for accel features
% Uses getEMGFeatures.m for EMG features
% Generates a structure saving clips of EMG/ACC data
% Generates a structure containing features from those clips

clear all

Loc='Ham';

filenames=rdir(['Z:\Stroke MC10\LabeledData\**\' Loc '*.csv']);
if strcmp(Loc,'Ham')
    activityLoc=9;
    accLoc=6;
end
if strcmp(Loc,'Gas')
    activityLoc=6;
    accLoc=2;
end

clipLength=.5;
Fs=250;
clipOverlap=.75;

clipSize=ceil(clipLength*Fs);
overlapSize=ceil(clipOverlap*clipSize);


for indFile=1:length(filenames)
    Data=readtable(filenames(indFile).name,'ReadVariableNames',false);
    
    EMG=cell2mat(table2cell(Data(:,5)));
    ACC=cell2mat(table2cell(Data(:,accLoc:accLoc+2)));
    EMG_env=abs(EMG);
    [B,A] = butter(1, 15/125, 'low');
    EMG_env=filtfilt(B,A,EMG_env);
    
    numClips=floor((height(Data)-overlapSize)/(clipSize-overlapSize));
    
    Label=cell(numClips,1);
    EMG_all=cell(numClips,1);
    ACC_all=cell(numClips,1);
    Features=cell(numClips,1);  
    
    skips=0;
    for indClip=1:numClips
        
        indStart=(indClip-1)*(clipSize-overlapSize)+1;
        indEnd=(indClip-1)*(clipSize-overlapSize)+clipSize;
        
        SA=sum(cellfun(@(x) strcmp(x,'Spastic Activity'),table2cell(Data(indStart:indEnd,activityLoc))));
        HA=sum(cellfun(@(x) strcmp(x,'Non-Spastic Activity'),table2cell(Data(indStart:indEnd,activityLoc))));
        IA=sum(cellfun(@(x) strcmp(x,'Inactive'),table2cell(Data(indStart:indEnd,activityLoc))));
        M=sum(cellfun(@(x) strcmp(x,'Misc'),table2cell(Data(indStart:indEnd,activityLoc))));
        
        % Assign most common label to clip
        if M>0
            skips=skips+1;
            continue
        end
        
        if SA>HA && SA>IA
            Label{indClip-skips}='SA';
        elseif HA>IA
            Label{indClip-skips}='HA';
        else
            Label{indClip-skips}='IA';
        end
        
        EMG_all{indClip-skips}=EMG(indStart:indEnd,:);
        ACC_all{indClip-skips}=ACC(indStart:indEnd,:);
        
%         Features{indClip}=[getFeatures(ACC(indStart:indEnd,:).') getEMGFeatures(EMG(indStart:indEnd,:).',std(EMG)*.2) getEMGFeatures(EMG_env(indStart:indEnd).',std(EMG)*.2)];
        %combine raw emg features and emg envelope features
%         Features{indClip-skips}=[getEMGFeatures_New(EMG(indStart:indEnd,:).',std(EMG)*.2) getEMGFeatures_New(EMG_env(indStart:indEnd).',std(EMG)*.2)];
        Features{indClip-skips}= getEMGFeatures(EMG(indStart:indEnd,:).');

    end
    Label(cellfun(@isempty,Label)==1)=[];
    ACC_all(cellfun(@isempty,ACC_all)==1)=[];
    EMG_all(cellfun(@isempty,EMG_all)==1)=[];
    Features(cellfun(@isempty,Features)==1)=[];
    % Save data structures
    
    AllClips=struct('SubjID', 'CS004',  'ActivityLabel', Label, 'Acc', ACC_all, ...
        'Emg', EMG_all, 'SamplingT', 1000/Fs, 'ClipDur', clipLength, 'ClipOverlap', clipOverlap, 'RecordingDur', 0);
    
    save([filenames(indFile).name(1:end-11) 'Clips.mat'],'AllClips')
    
    AllFeat=struct('SubjID', 'CS004',  'ActivityLabel', Label, 'Features', ...
        Features, 'SamplingT', 1000/Fs, 'ClipDur', clipLength, 'ClipOverlap', clipOverlap, 'RecordingDur', 0);
    
    save([filenames(indFile).name(1:end-11) 'Feat.mat'],'AllFeat')
    
end