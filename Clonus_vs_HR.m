% Clonus vs Hyperreflexia classification
clear all
load FullPatientData_HRvC_1s

HyperRData=cell2mat(PatientData.h');
ClonusData=cell2mat(PatientData.g');

HyperRLabels=cell2mat(cellfun(@(x) cell2mat(x),PatientData.hLabel(...
    cellfun(@(x) ~isempty(x),PatientData.hLabel)),'UniformOutput',false)');
HRlengths=cellfun(@(x) size(x,1),PatientData.hLabel);
HSubjs=[];
for i=1:length(HRlengths)
    if HRlengths(i)>0
        HSubjs=[HSubjs; i*ones(HRlengths(i),1)];
    end
end

ClonusLabels=cell2mat(cellfun(@(x) cell2mat(x),PatientData.gLabel(...
    cellfun(@(x) ~isempty(x),PatientData.gLabel)),'UniformOutput',false)');
Clengths=cellfun(@(x) size(x,1),PatientData.gLabel);
CSubjs=[];
for i=1:length(Clengths)
    if Clengths(i)>0
        CSubjs=[CSubjs; i*ones(Clengths(i),1)];
    end
end


Sinds=strcmp('S',mat2cell(HyperRLabels(:,1),ones(sum(HRlengths),1)));
Iinds=strcmp('I',mat2cell(HyperRLabels(:,1),ones(sum(HRlengths),1)));
HyperRLabels=[repmat('R',[sum(Sinds) 1]); repmat('I',[sum(Iinds) 1])];
HyperRData=[[HyperRData(Sinds,:); HyperRData(Iinds,:)] [HSubjs(Sinds); HSubjs(Iinds)]];

Sinds=strcmp('S',mat2cell(ClonusLabels(:,1),ones(sum(Clengths),1)));
Iinds=strcmp('I',mat2cell(ClonusLabels(:,1),ones(sum(Clengths),1)));
ClonusLabels=[repmat('C',[sum(Sinds) 1]); repmat('I',[sum(Iinds) 1])];
ClonusData=[[ClonusData(Sinds,:); ClonusData(Iinds,:)] [CSubjs(Sinds); CSubjs(Iinds)]];

Data=[HyperRData; ClonusData];
Labels=[HyperRLabels; ClonusLabels];

for i=1:length(unique(Data(:,end)))
    if length(unique(Labels(Data(:,end)==i)))<3
        Data(Data(:,end)==i,:)=[];
        Labels(Data(:,end)==i)=[];
    end
end

for indSub=1:length(unique(Data(:,end)))
    Train=Data(Data(:,end)~=indSub,1:end-1);
    TrainLab=Labels(Data(:,end)~=indSub);
    TrainLab=mat2cell(TrainLab,ones(length(TrainLab),1));
    
    Test=Data(Data(:,end)==indSub,1:end-1);
    TestLab=Labels(Data(:,end)==indSub);
    TestLab=mat2cell(TestLab,ones(length(TestLab),1));
    
    if isempty(Test)
        continue
    end
    
%     Model=TreeBagger(50,Train,TrainLab);
    t = templateTree('MinLeafSize',5);
    Model = fitensemble(Train, TrainLab, 'RUSBoost', 50, t,'LearnRate',.1);
%     figure; plot(loss(Model,Test,TestLab,'mode','cumulative'));
    
    RFLabels=predict(Model,Test);
    ConfMat(:,:,indSub)=confusionmat(TestLab,RFLabels,'order',{'I','C','R'});
    
end

%%

for indSub=1:size(ConfMat,3)
%     ConfMatAll=sum(ConfMat,3);
    ConfMatAll=ConfMat(:,:,indSub);
    correctones = sum(ConfMatAll,2);
    correctones = repmat(correctones,[1 3]);
    figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
    set(gca,'XTickLabel',{'I','C','R'})
    set(gca,'YTickLabel',{'I','C','R'})
    set(gca,'XTick',[1 2 3])
    set(gca,'YTick',[1 2 3])
end

ConfMatAll=sum(ConfMat,3);
correctones = sum(ConfMatAll,2);
correctones = repmat(correctones,[1 3]);
figure; imagesc(ConfMatAll./correctones, [0 1]); colorbar
set(gca,'XTickLabel',{'I','C','R'})
set(gca,'YTickLabel',{'I','C','R'})
set(gca,'XTick',[1 2 3])
set(gca,'YTick',[1 2 3])
