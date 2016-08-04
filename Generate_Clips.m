%% Generate Clips from labeled data
% Uses getFeatures.m for accel features
% Uses getEMGFeatures.m for EMG features
% Generates a structure saving clips of EMG/ACC data
% Generates a structure containing features from those clips

clear all

filenames=rdir('Z:\Stroke MC10\LabeledData\**\*.csv');

clipLength=[1 1]; % Ham/Gas
Fs=250;
clipOverlap=[.9 .9]; % Ham/Gas

for indF=1:length(filenames)
    Data=readtable(filenames(indF).name,'ReadVariableNames',false);
    [savepath,filename,~]=fileparts(['Z:\Stroke MC10\Clips\' filenames(indF).name(31:end)]);
    if ~exist(savepath,'dir')
        mkdir(savepath)
    end
    
    if strfind(filename,'Hamstring')
        indLab=9;
        clipSize=ceil(clipLength(1)*Fs);
        overlapSize=ceil(clipOverlap(1)*clipSize);
    else
        indLab=6;
        clipSize=ceil(clipLength(2)*Fs);
        overlapSize=ceil(clipOverlap(2)*clipSize);
    end
    
    EMG=cell2mat(table2cell(Data(:,2)));
%     ACC=cell2mat(table2cell(Data(:,accLoc:accLoc+2)));
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
        
        SA=sum(cellfun(@(x) strcmp(x,'Spastic Activity'),table2cell(Data(indStart:indEnd,indLab))));
        HA=sum(cellfun(@(x) strcmp(x,'Non-Spastic Activity'),table2cell(Data(indStart:indEnd,indLab))));
        IA=sum(cellfun(@(x) strcmp(x,'Inactive'),table2cell(Data(indStart:indEnd,indLab))));
        M=sum(cellfun(@(x) strcmp(x,'Misc'),table2cell(Data(indStart:indEnd,indLab))))...
            +sum(cellfun(@(x) strcmp(x,'Not labeled'),table2cell(Data(indStart:indEnd,indLab))));
        
        if SA>0
            dummy=1;
        end
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
        
%         Features{indClip}=[getFeatures(ACC(indStart:indEnd,:).') getEMGFeatures(EMG(indStart:indEnd,:).',std(EMG)*.2) getEMGFeatures(EMG_env(indStart:indEnd).',std(EMG)*.2)];
        %combine raw emg features and emg envelope features
%         Features{indClip-skips}=[getEMGFeatures_New(EMG(indStart:indEnd,:).',std(EMG)*.2) getEMGFeatures_New(EMG_env(indStart:indEnd).',std(EMG)*.2)];
        Features{indClip-skips}= getEMGFeatures(EMG(indStart:indEnd,:).');

    end
    Label(cellfun(@isempty,Label)==1)=[];
    EMG_all(cellfun(@isempty,EMG_all)==1)=[];
    Features(cellfun(@isempty,Features)==1)=[];
    % Save data structures
    
    AllClips=struct('SubjID', 'CS001',  'ActivityLabel', Label, ...
        'Emg', EMG_all, 'SamplingT', 1000/Fs, 'ClipDur', clipLength, 'ClipOverlap', clipOverlap, 'RecordingDur', 0);
    
    save([savepath '/' filename(1:end-7) 'Clips.mat'],'AllClips')
    
    AllFeat=struct('SubjID', 'CS001',  'ActivityLabel', Label, 'Features', ...
        Features, 'SamplingT', 1000/Fs, 'ClipDur', clipLength, 'ClipOverlap', clipOverlap, 'RecordingDur', 0);
    
    save([savepath '/' filename(1:end-7) 'Feat.mat'],'AllFeat')
end