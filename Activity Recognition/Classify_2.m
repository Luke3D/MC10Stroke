%% Train classifier based on MC10 data from Phone Labels
% Run after GenerateClips.m
Subj_CrossVal=1;

nTrees=150;
Activities={'Lying' 'Sitting' 'Standing' 'Stairs Up' 'Stairs Down' 'Walking'};

Test=load([dirname 'RawData\ActivityData\TestFeat.mat']);
Train=load([dirname 'RawData\ActivityData\TrainFeat.mat']);

Test=Test.AllFeat;
Train=Train.AllFeat;

if ~Subj_CrossVal
    Feat=[];
    Label={};

    for i=1:length(Test)
        Feat=[Feat; Test(i).Features];
        Label=[Label Test(i).ActivityLabel];
    end

    TestFeat=Feat;
    TestLabel=Label.';

    Feat=[];
    Label={};

    for i=1:length(Train)
        Feat=[Feat; Train(i).Features];
        Label=[Label Train(i).ActivityLabel];
    end

    TrainFeat=Feat;
    TrainLabel=Label.';
    
    RFModel=TreeBagger(nTrees, TrainFeat, TrainLabel);
    [LabelsRF,P_RF] = predict(RFModel,TestFeat);
    ConfMat=confusionmat(TestLabel, LabelsRF);

else
    for indFold=1:length(Test)
        if isempty(Test(indFold).Features)
            continue
        end
        
        temp=Train;
        temp(indFold)=[];
        
        Feat=[];
        Label={};

        for i=1:length(temp)
            Feat=[Feat; temp(i).Features];
            Label=[Label temp(i).ActivityLabel];
        end

        TrainFeat=Feat;
        TrainLabel=Label.';
        
        TestFeat=Test(indFold).Features;
        TestLabel=Test(indFold).ActivityLabel;        
        TestLabel=TestLabel.';
        
        RFModel=TreeBagger(nTrees, TrainFeat, TrainLabel);
        [LabelsRF,P_RF] = predict(RFModel,TestFeat);
        ConfMat(:,:,indFold)=confusionmat(TestLabel, LabelsRF);
    end
end

ConfMatAll=sum(ConfMat,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
set(gca,'XTickLabel',Activities)
set(gca,'YTickLabel',Activities)
set(gca,'XTick',[1 2 3 4 5 6])
set(gca,'YTick',[1 2 3 4 5 6])