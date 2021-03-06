%% Evaluate Personal Models for Spasticity Recognition
% Currently uses a single subject (CS004)

clear all

nTrees=50;
Activities={'IA', 'HA', 'SA'};
FeatTrain=[];
LabelTrain={};
TrainFiles=rdir('Z:\Stroke MC10\LabeledData\**\Lab Day1\Ham*Feat.mat');

for indTrain=1:length(TrainFiles)
    load(TrainFiles(indTrain).name)

    FeatTrain=[FeatTrain; cell2mat({AllFeat.Features}.')];
    LabelTrain=[LabelTrain; {AllFeat.ActivityLabel}.'];
end

FeatTest=[];
LabelTest={};
TestFiles=rdir('Z:\Stroke MC10\LabeledData\**\Lab Day2\Ham*Feat.mat');

for indTest=1:length(TestFiles)
    load(TestFiles(indTest).name)

    FeatTest=[FeatTest; cell2mat({AllFeat.Features}.')];
    LabelTest=[LabelTest; {AllFeat.ActivityLabel}.'];
end

RFModel=TreeBagger(nTrees, FeatTrain, LabelTrain);
[LabelsRF,P_RF] = predict(RFModel,FeatTest);

TPInd=cellfun(@strcmp, LabelsRF, LabelTest);

ConfMatAll=confusionmat(LabelTest, LabelsRF);

for i=1:3
    precision(i)=ConfMatAll(i,i)/sum(ConfMatAll(:,i));
    recall(i)=ConfMatAll(i,i)/sum(ConfMatAll(i,:));
    F1(i)=2*precision(i)*recall(i)/(precision(i)+recall(i));
end

correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 3]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
set(gca,'XTickLabels',Activities)
set(gca,'YTickLabels',Activities)
set(gca,'XTick',[1 2 3])
set(gca,'YTick',[1 2 3])


WAcc=sum(diag(ConfMatAll))/sum(sum(ConfMatAll));


%Visualize the features
Ytr = zeros(size(LabelTrain));
Yte = zeros(size(LabelTest));

for c = 1:length(unique(Activities))
    indTr = strcmp(LabelTrain,Activities{c});
    indTe = strcmp(LabelTest,Activities{c});
    Ytr(indTr) = c; Yte(indTe) = c;    
end
%Z-score data
FeatTrain = zscore(FeatTrain); 
mu = mean(FeatTrain); sigma = std(FeatTrain);
FeatTest = (FeatTest-repmat(mu,[length(FeatTest) 1]))./repmat(sigma,[length(FeatTest) 1]);
figure, boxplot(FeatTrain)
%Scatter plot of the features
figure, gplotmatrix(FeatTrain(:,[1 4]),FeatTrain(:,[6 7]),Ytr,[],'o',6),
legend(Activities)
figure, gplotmatrix(FeatTest(:,[1 4]),FeatTest(:,[6 7]),Yte,[],'o',6),
legend(Activities)

