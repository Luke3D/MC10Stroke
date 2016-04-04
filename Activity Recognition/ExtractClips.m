clear all

Fs=50; % Sampling Frequency

clipDur=5;
clipLen=clipDur*Fs;
clipOverlap=.9;
clipOverlapLen=ceil(clipOverlap*clipLen);

Subs={'2', '3', '5'};

AllFeat=[];
AllLabels={};
TestAllFeat=[];
TestAllLabels={};

for j=1:length(Subs)
    
Train=readtable(['CS00' Subs{j} '_Day1labeled.csv'],'ReadVariableNames',false);
Test=readtable(['CS00' Subs{j} '_Day2labeled.csv'],'ReadVariableNames',false);

Activities={'Lying', 'Sitting', 'Standing', 'Walking', 'Stairs Dw', 'Stairs Up'};
actCounts=zeros(1,length(Activities));

%% Train Data

numClips=floor((height(Train)-clipOverlapLen)/(clipLen-clipOverlapLen));

gas=[Train.Var2 Train.Var3 Train.Var4];
ham=[Train.Var5 Train.Var6 Train.Var7];
ind=1;
TrainLabels={};
TrainFeatures=[];

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
    
    gas_Clip=gas((indClip-1)*(clipLen-clipOverlapLen)+1:(indClip-1)*(clipLen-clipOverlapLen)+clipLen,:);
    ham_Clip=ham((indClip-1)*(clipLen-clipOverlapLen)+1:(indClip-1)*(clipLen-clipOverlapLen)+clipLen,:);
    
    X=zeros(1,3);
    for i=1:length(gas_Clip)
        X=X+cross(gas_Clip(i,:),ham_Clip(i,:));
    end
    X=X./norm(X)^.5;
    
    Features=[getFeatures(gas_Clip.') getFeatures(ham_Clip.') X(1) X(2) X(3)];
    
    TrainLabels{ind}=Label;
    TrainFeatures(ind,:)=Features;
    ind=ind+1;
end

AllFeat=[AllFeat; TrainFeatures];
AllLabels=[AllLabels TrainLabels];

%% Test Data
numClips=floor((height(Test)-clipOverlapLen)/(clipLen-clipOverlapLen));

gas=[Test.Var2 Test.Var3 Test.Var4];
ham=[Test.Var5 Test.Var6 Test.Var7];
ind=1;

TestLabels={};
TestFeatures=[];

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
    
%     Features=getFeatures(gas((indClip-1)*(clipLen-clipOverlapLen)+1:(indClip-1)*(clipLen-clipOverlapLen)+clipLen,:).');
    
    gas_Clip=gas((indClip-1)*(clipLen-clipOverlapLen)+1:(indClip-1)*(clipLen-clipOverlapLen)+clipLen,:);
    ham_Clip=ham((indClip-1)*(clipLen-clipOverlapLen)+1:(indClip-1)*(clipLen-clipOverlapLen)+clipLen,:);
    
    X=zeros(1,3);
    for i=1:length(gas_Clip)
        X=X+cross(gas_Clip(i,:),ham_Clip(i,:));
    end
    X=X./norm(X)^.5;
    
    Features=[getFeatures(gas_Clip.') getFeatures(ham_Clip.') X(1) X(2) X(3)];
    
    TestLabels{ind}=Label;
    TestFeatures(ind,:)=Features;
    ind=ind+1;
end

TestAllFeat=[TestAllFeat; TestFeatures];
TestAllLabels=[TestAllLabels TestLabels];

save(['CS00' Subs{j} '.mat'], 'TrainLabels', 'TrainFeatures', 'TestLabels', 'TestFeatures')
end
    