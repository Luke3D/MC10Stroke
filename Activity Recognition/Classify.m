nTrees=50;
useAll=0; % Set to one to train on all data

if useAll
    % Use all data
    load 'Z:\Stroke MC10\Activity Recognition\All_ClassifierData.mat'
    TrainFeatures=AllFeat;
    TrainLabels=AllLabels;
    TestFeatures=TestAllFeat;
    TestLabels=TestAllLabels;
else
    % Test One Subject
    num='3';
    load(['Z:\Stroke MC10\Activity Recognition\CS00' num '.mat'])
end

RFModel=TreeBagger(nTrees, TrainFeatures, TrainLabels.');
[LabelsRF,P_RF] = predict(RFModel,TestFeatures);
ConfMatAll=confusionmat(TestLabels.', LabelsRF);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
set(gca,'XTickLabel',Activities)
set(gca,'YTickLabel',Activities)
set(gca,'XTick',[1 2 3 4 5 6])
set(gca,'YTick',[1 2 3 4 5 6])