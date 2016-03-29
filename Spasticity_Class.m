%% Evaluate Personal Models for Spasticity Recognition
% Currently uses a single subject (CS004)

clear all

nTrees=300;
Activities={'IA', 'HA', 'SA'};

load('Z:\Stroke MC10\LabeledData\CS004\Lab Day1\Gastrocnemius_6MWT_Feat.mat')

FeatTrain=cell2mat({AllFeat.Features}.');
LabelTrain={AllFeat.ActivityLabel}.';

load('Z:\Stroke MC10\LabeledData\CS004\Lab Day2\Gastrocnemius_10mWT_SS1_Feat.mat')

FeatTest=cell2mat({AllFeat.Features}.');
LabelTest={AllFeat.ActivityLabel}.';

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
