%% Generate Clips from labeled data
% Uses getFeatures.m for accel features
% Uses getEMGFeatures.m for EMG features
% Generates a structure saving clips of EMG/ACC data
% Generates a structure containing features from those clips

clear all

filenames=rdir('Z:\Stroke MC10\LabeledData\**\Gas*.csv');

clipLength=.25;
Fs=250;
clipOverlap=.75;

clipSize=ceil(clipLength*Fs);
overlapSize=ceil(clipOverlap*clipSize);


for indFile=1:length(filenames)
    Data=readtable(filenames(indFile).name,'ReadVariableNames',false);
    
    EMG=cell2mat(table2cell(Data(:,5)));
    ACC=cell2mat(table2cell(Data(:,2:4)));
    EMG_env=abs(EMG);
    [B,A] = butter(1, 5/125, 'low');
    EMG_env=filtfilt(B,A,EMG_env);
    
    Label=cell(numClips,1);
    EMG_all=cell(numClips,1);
    ACC_all=cell(numClips,1);
    Features=cell(numClips,1);
    
    numClips=floor((height(Data)-overlapSize)/(clipSize-overlapSize));
    
    for indClip=1:numClips
        
        indStart=(indClip-1)*(clipSize-overlapSize)+1;
        indEnd=(indClip-1)*(clipSize-overlapSize)+clipSize;
        
        SA=sum(cellfun(@(x) strcmp(x,'Spastic Activity'),table2cell(Data(indStart:indEnd,6))));
        HA=sum(cellfun(@(x) strcmp(x,'Non-Spastic Activity'),table2cell(Data(indStart:indEnd,6))));
        IA=sum(cellfun(@(x) strcmp(x,'Inactive'),table2cell(Data(indStart:indEnd,6))));
        
        % Assign most common label to clip
        if SA>HA && SA>IA
            Label{indClip}='SA';
        elseif HA>IA
            Label{indClip}='HA';
        else
            Label{indClip}='IA';
        end
        
        EMG_all{indClip}=EMG(indStart:indEnd,:);
        ACC_all{indClip}=ACC(indStart:indEnd,:);
        
        Features{indClip}=[getFeatures(ACC(indStart:indEnd,:).') getEMGFeatures(EMG(indStart:indEnd,:).',std(EMG)*.2) getEMGFeatures(EMG_env(indStart:indEnd).',std(EMG)*.2)];
        
    end
    
    % Save data structures
    
    AllClips=struct('SubjID', 'CS004',  'ActivityLabel', Label, 'Acc', ACC_all, ...
        'Emg', EMG_all, 'SamplingT', 1000/Fs, 'ClipDur', clipLength, 'ClipOverlap', clipOverlap, 'RecordingDur', 0);
    
    save([filenames(indFile).name(1:end-11) 'Clips.mat'],'AllClips')
    
    AllFeat=struct('SubjID', 'CS004',  'ActivityLabel', Label, 'Features', ...
        Features, 'SamplingT', 1000/Fs, 'ClipDur', clipLength, 'ClipOverlap', clipOverlap, 'RecordingDur', 0);
    
    save([filenames(indFile).name(1:end-11) 'Feat.mat'],'AllFeat')
    
end