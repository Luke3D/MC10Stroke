clear all

Fs=50; % Sampling Frequency

clipDur=5;
clipLen=clipDur*Fs;
clipOverlap=.5;
clipOverlapLen=ceil(clipOverlap*clipLen);

Train=readtable('CS002_Day1labeled.csv','ReadVariableNames',false);
Test=readtable('CS002_Day2labeled.csv','ReadVariableNames',false);

Activities={'Lying', 'Sitting', 'Standing', 'Walking', 'Stairs Dw', 'Stairs Up'};
actCounts=zeros(1,length(Activities));

%% Train Data

numClips=floor((height(Train)-clipOverlapLen)/(clipLen-clipOverlapLen));

gas=[Train.Var2 Train.Var3 Train.Var4];
ham=[Train.Var5 Train.Var6 Train.Var7];
ind=1;

for indClip=1:numClips
    data=table2cell(Train((indClip-1)*(clipLen-clipOverlapLen)+1:(indClip-1)*(clipLen-clipOverlapLen)+clipLen,:));
    for i=1:length(Activities)
        act=Activities{i};
        actCounts(i)=sum(cellfun(@(x) strcmp(act,x),{data{:,8}}));
    end
    indCheck=actCounts>clipLen/2;
    if sum(indCheck)<1
        continue
    else
        indCheck=actCounts>clipLen/2;
        Label=Activities{indCheck};
    end
    
    Features=getFeatures(gas((indClip-1)*(clipLen-clipOverlapLen)+1:(indClip-1)*(clipLen-clipOverlapLen)+clipLen,:).');
    
%     Features=[getFeatures(gas((indClip-1)*(clipLen-clipOverlapLen)+1:(indClip-1)*(clipLen-clipOverlapLen)+clipLen,:).')...
%         getFeatures(ham((indClip-1)*(clipLen-clipOverlapLen)+1:(indClip-1)*(clipLen-clipOverlapLen)+clipLen,:).')];
    
    TrainLabels{ind}=Label;
    TrainFeatures(ind,:)=Features;
    ind=ind+1;
end
    
%% Test Data
numClips=floor((height(Test)-clipOverlapLen)/(clipLen-clipOverlapLen));

gas=[Test.Var2 Test.Var3 Test.Var4];
ham=[Test.Var5 Test.Var6 Test.Var7];
ind=1;

for indClip=1:numClips
    data=table2cell(Test((indClip-1)*(clipLen-clipOverlapLen)+1:(indClip-1)*(clipLen-clipOverlapLen)+clipLen,:));
    for i=1:length(Activities)
        act=Activities{i};
        actCounts(i)=sum(cellfun(@(x) strcmp(act,x),{data{:,8}}));
    end
    indCheck=actCounts>clipLen/2;
    if sum(indCheck)<1
        continue
    else
        indCheck=actCounts>clipLen/2;
        Label=Activities{indCheck};
    end
    
    Features=getFeatures(gas((indClip-1)*(clipLen-clipOverlapLen)+1:(indClip-1)*(clipLen-clipOverlapLen)+clipLen,:).');
    
%     Features=[getFeatures(gas((indClip-1)*(clipLen-clipOverlapLen)+1:(indClip-1)*(clipLen-clipOverlapLen)+clipLen,:).')...
%         getFeatures(ham((indClip-1)*(clipLen-clipOverlapLen)+1:(indClip-1)*(clipLen-clipOverlapLen)+clipLen,:).')];
    
    TestLabels{ind}=Label;
    TestFeatures(ind,:)=Features;
    ind=ind+1;
end
    