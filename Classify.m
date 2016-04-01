nTrees=50;

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