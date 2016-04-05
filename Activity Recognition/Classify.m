clear all

nTrees=250;
Activities={'Lying', 'Sitting', 'Standing', 'Walking', 'Stairs Dw', 'Stairs Up'};
% useAll=1; % Set to one to train on all data
% 
% if useAll
%     % Use all data
%     load 'Z:\Stroke MC10\Activity Recognition\All_ClassifierData.mat'
%     TrainFeatures=AllFeat;
%     TrainLabels=AllLabels;
%     TestFeatures=TestAllFeat;
%     TestLabels=TestAllLabels;
% else
%     % Test One Subject
%     num='7';
%     load(['Z:\Stroke MC10\Activity Recognition\CS00' num '.mat'])
% end
% 
Subs={'2','3','5','6','7'};

for i=1:length(Subs)
    data(i)=load(['Z:\Stroke MC10\Activity Recognition\CS00' Subs{i} '.mat']);
end

for indFold=1:length(Subs)
    inds=[];
    for i=1:length(Subs)
        if i==indFold
            continue
        end
        inds=[inds i];
    end
    
    TrainFeatures=[data(inds(1)).TrainFeatures; data(inds(2)).TrainFeatures; ...
        data(inds(3)).TrainFeatures; data(inds(4)).TrainFeatures];
    TrainLabels=[data(inds(1)).TrainLabels data(inds(2)).TrainLabels ...
        data(inds(3)).TrainLabels data(inds(4)).TrainLabels];
    TestFeatures=[data(inds(1)).TestFeatures; data(inds(2)).TestFeatures; ...
        data(inds(3)).TestFeatures; data(inds(4)).TestFeatures];
    TestLabels=[data(inds(1)).TestLabels data(inds(2)).TestLabels ...
        data(inds(3)).TestLabels data(inds(4)).TestLabels];
    
    RFModel=TreeBagger(nTrees, TrainFeatures, TrainLabels.');
    [LabelsRF,P_RF] = predict(RFModel,TestFeatures);
    ConfMat(:,:,indFold)=confusionmat(TestLabels.', LabelsRF);
end
ConfMatAll=sum(ConfMat,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
set(gca,'XTickLabel',Activities)
set(gca,'YTickLabel',Activities)
set(gca,'XTick',[1 2 3 4 5 6])
set(gca,'YTick',[1 2 3 4 5 6])