%% Train classifier based on MC10 data from Phone Labels
% Run after GenerateClips.m
Subj_CrossVal=1;

nTrees=150;
Activities={'Lying' 'Sitting' 'Standing' 'Stairs Down' 'Stairs Up' 'Walking'};

dirname = 'Z:\Stroke MC10\Activity Recognition\TrimmedData';

Test=load([dirname '\ActivityData\TestFeat.mat']);
Train=load([dirname '\ActivityData\TrainFeat.mat']);

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
    RealConfMat=confusionmat(TestLabel, LabelsRF);
    
    d = diag(RealConfMat);
    cor = sum(d);
    tot = sum(sum(RealConfMat));

    acy = 100*cor / tot;
    
else
    for indFold=1:length(Test)
        if isempty(Test(indFold).Features) && isempty(Train(indFold).Features)
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
        for i=1:length(Test)
            if i~=indFold
                Feat=[Feat; Test(i).Features];
                Label=[Label Test(i).ActivityLabel];
            end
        end

        TrainFeat=Feat;
        TrainLabel=Label.';
        
        TestFeat=[Test(indFold).Features; Train(indFold).Features];
        TestLabel=[Test(indFold).ActivityLabel Train(indFold).ActivityLabel];        
        TestLabel=TestLabel.';
        
        RFModel=TreeBagger(nTrees, TrainFeat, TrainLabel);
        [LabelsRF,P_RF] = predict(RFModel,TestFeat);
        
        ConfMat{indFold}(:,:) = confusionmat(TestLabel, LabelsRF);

        x = unique(LabelsRF);
        
        RealConfMat(:,:,indFold) = check(x, ConfMat{indFold}(:,:));
        
        d = diag(ConfMat{indFold}(:,:));
        cor = sum(d);
        tot = sum(sum(ConfMat{indFold}(:,:)));
        
        acy(indFold) = 100*cor / tot;
                    
        
%         ConfMat(:,:,indFold)=confusionmat(TestLabel, LabelsRF);
%         ConfMat{indFold}(:,:)=confusionmat(TestLabel, LabelsRF);
        
%         n(1,indFold) = length(unique(TrainLabel));
%         n(2,indFold) = length(unique(TestLabel));
%         n(3,indFold) = length(unique(LabelsRF));
%         n(4,indFold) = length(ConfMat{indFold}(:,:));
    end
end

ConfMatAll=sum(RealConfMat,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 6]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
set(gca,'XTickLabel',Activities)
set(gca,'YTickLabel',Activities)
set(gca,'XTick',[1 2 3 4 5 6])
set(gca,'YTick',[1 2 3 4 5 6])

D = diag(ConfMatAll);
correct = sum(D);
total = sum(sum(ConfMatAll));

mAcy = mean(acy);
Accuracy = 100*correct / total;

fprintf('Model Accuracy: %6.4f%%\n', Accuracy)
fprintf('Mean Model Accuracy: %6.4f%%\n', mAcy)


tempConf = ConfMatAll;

tempPre = diag(tempConf) ./ sum(tempConf,1)';
tempRec = diag(tempConf) ./ sum(tempConf,2);

tempPre(isnan(tempPre)) = 0;
tempRec(isnan(tempRec)) = 0;

Precision = tempPre;
Recall = tempRec;