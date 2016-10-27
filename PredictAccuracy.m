%load('PatientData.mat')
close all
clearvars -except clipLength

RUS=1;
resamp_test=0;
resamp_train=0;

% load('FullPatientData_Norm.mat')
load('FullPatientData.mat')

N = {'h' 'g'};
n = [17, 29];
nTrees = 50;
SAindex = [];
err=cell(2,1);

load('Good_inds.mat')
useinds={1:n(1), 1:n(2)};
useinds{1}(H_good)=[];
useinds{2}(G_good)=[];
% useinds{1}(1:3)=[];
% useinds{2}(1:2)=[];
% useinds{1}=[useinds{1} H_good];
% useinds{2}=[useinds{2} G_good([1 4 6:11])];
% useinds={[H_good 12], G_good};
useinds={};
inclInactive = 0;

if ~inclInactive
    num = 2;
else
    num = 3;
end

trainingData = [];
trainingLabels= [];

testData = [];
testLabels = [];

tempData = [];
tempLabels = [];

if ~isempty(useinds)
    for i=1:2
        for j=1:length(PatientData.(N{i}))
            if ~any(j==useinds{i})
                PatientData.([N{i}]){j}=[];
                PatientData.([N{i} 'Label']){j}=[];
            end
        end
    end
    n=cellfun(@(x) max(x),useinds);
end

if ~inclInactive
    for ii = 1:2
        for jj = 1:n(ii)
            
        tDat = PatientData.([N{ii}]){jj};
        tLab = PatientData.([N{ii} 'Label']){jj};
            
        inds=strcmp('IA',tLab);
        
        tDat(inds,:) = [];
        tLab(inds,:) = [];
        
        PatientData.([N{ii}]){jj} = tDat;
        PatientData.([N{ii} 'Label']){jj} = tLab;
        
        tDat = [];
        tLab = [];
        
        end
    end
end
    
for ii = 1:2
     for jj = 1:n(ii)
         
        tempData = PatientData.([N{ii}]);
        tempLabels = PatientData.([N{ii} 'Label']);
        tempData(jj) = [];
        tempLabels(jj) = [];
        
        for kk = 1:length(tempData)
            if sum(strcmp(tempLabels{kk}, 'SA')) == 0
                continue
            else
                trainingData = [trainingData; tempData{kk}];
                trainingLabels = [trainingLabels; tempLabels{kk}];
            end
            
        end
        
        testData = PatientData.([N{ii}]){jj};
        testLabels = PatientData.([N{ii} 'Label']){jj};
        
        if isempty(testData)
            ConfMat{ii,jj}=[];
            accuracy(ii,jj)=NaN;
            balacc(ii,jj)=NaN;
            continue
        end
        
        % Resample test and train sets to size of smallest set
            % test data
            
            SA=find(cellfun(@(x) strcmp(x,'SA'), testLabels));
            HA=find(cellfun(@(x) strcmp(x,'HA'), testLabels));
            IA=find(cellfun(@(x) strcmp(x,'IA'), testLabels));

            % sort data (use if not resampling test set
            if ~resamp_test
                testData=testData([SA; HA; IA],:);
                testLabels=testLabels([SA; HA; IA],:);
            end
            
            SA_count=length(SA);
            HA_count=length(HA);
            IA_count=length(IA);

            if SA_count==0
                ConfMat{ii,jj}=zeros(num);
                accuracy(ii,jj)=NaN;
                balacc(ii,jj)=NaN;
                continue
            end
            
            if resamp_test
                if IA_count>0
                    resamp_count=min([SA_count HA_count IA_count]);
                    IA_inds=randperm(IA_count,resamp_count);
                else
                    resamp_count=min([SA_count HA_count]);
                    IA_inds=[];
                end

                SA_inds=randperm(SA_count,resamp_count);
                HA_inds=randperm(HA_count,resamp_count);  

                testData=testData([SA(SA_inds); HA(HA_inds); IA(IA_inds)],:);
                testLabels=testLabels([SA(SA_inds); HA(HA_inds); IA(IA_inds)]);
            end
            
            % training data
            if resamp_train
                SA=find(cellfun(@(x) strcmp(x,'SA'), trainingLabels));
                HA=find(cellfun(@(x) strcmp(x,'HA'), trainingLabels));
                IA=find(cellfun(@(x) strcmp(x,'IA'), trainingLabels));

                SA_count=length(SA);
                HA_count=length(HA);
                IA_count=length(IA);

                if IA_count>0
                    resamp_count=min([SA_count HA_count IA_count]);
                    IA_inds=randperm(IA_count,resamp_count);
                else
                    resamp_count=min([SA_count HA_count]);
                    IA_inds=[];
                end

                SA_inds=randperm(SA_count,resamp_count);
                HA_inds=randperm(HA_count,min(resamp_count*3,HA_count));  

                trainingData=trainingData([SA(SA_inds); HA(HA_inds); IA(IA_inds)],:);
                trainingLabels=trainingLabels([SA(SA_inds); HA(HA_inds); IA(IA_inds)]);
            end

        if RUS
            t = templateTree('MinLeafSize',5);
            Model = fitensemble(trainingData(:,2:end), trainingLabels, 'RUSBoost', 50, t,'LearnRate',.1);
%             figure; plot(loss(Model, testData, testLabels,'mode','cumulative'))
        else
            Model = TreeBagger(nTrees, trainingData(:,2:end), trainingLabels, 'OOBVarImp', 'on');
            if isempty(err{ii})
                err{ii}=zeros(size(Model.OOBPermutedVarDeltaError));
            end
            err{ii} = err{ii}+Model.OOBPermutedVarDeltaError;
        end
        
        LabelsRF = predict(Model, testData(:,2:end));
        
        if sum(strcmp(LabelsRF, 'SA')) >= 1
            SAindex = [SAindex [ii;jj]];
        end
        
        ConfMat{ii,jj} = confusionmat(testLabels, LabelsRF);
        
        if isempty(ConfMat{ii,jj})
            ConfMat{ii,jj} = zeros(num);
        end
        
        accuracy(ii,jj) = mean(strcmp(testLabels, 'HA'));
        % Redefined accuracy as accuracy compared to predicting all labels
        % as HA
        
        balacc(ii,jj) = mean(diag(ConfMat{ii,jj})./sum(ConfMat{ii,jj},2));
        
        x = unique([testLabels LabelsRF]);

        if ~isempty(ConfMat{ii,jj})
            RealConfMat(:,:,ii,jj) = checkLab(x, ConfMat{ii,jj}, num);
        else
            RealConfMat(:,:,ii,jj) = zeros(num);
        end

        tempConf = RealConfMat(:,:,ii,jj);
        correctones = sum(tempConf, 2);
        correctones = repmat(correctones, [1 num]);
        RealConfMat(:,:,ii,jj) = tempConf ./ correctones;
        

        trainingData = [];
        trainingLabels = [];

        testData = [];
        testLabels = [];
        
        tempData = [];
        tempLabels = [];
        
     end
end

n1 = length(RealConfMat);

for ii = 1:2
    kk = 1;
    tempMat = [];
    for jj = 1:n1
        temp = RealConfMat(:,:,ii,jj);
        
        if nansum(temp(:)) ~= 0
            tempMat(:,:,kk) = temp;
            kk = kk + 1;
        end
        
    end
    
    TrueConf{ii} = nanmean(tempMat,3);
end

figure
imagesc(TrueConf{1}); colorbar
caxis([0 1])
title('Hamstring Confusion Matrix')
if inclInactive
    set(gca,'XTick', [1 2 3]), set(gca, 'XTickLabels', {'Spastic', 'Non-Spastic', 'Inactive'})
    set(gca,'YTick', [1 2 3]), set(gca, 'YTickLabels', {'Spastic', 'Non-Spastic', 'Inactive'})
else
    set(gca,'XTick', [1 2]), set(gca, 'XTickLabels', {'Spastic', 'Non-Spastic'})
    set(gca,'YTick', [1 2]), set(gca, 'YTickLabels', {'Spastic', 'Non-Spastic'})
%    set(gca,'FontSize', 20)
end

figure
imagesc(TrueConf{2}); colorbar
caxis([0 1])
title('Gastrocnemius Confusion Matrix')
if inclInactive
    set(gca,'XTick', [1 2 3]), set(gca, 'XTickLabels', {'Spastic', 'Non-Spastic', 'Inactive'})
    set(gca,'YTick', [1 2 3]), set(gca, 'YTickLabels', {'Spastic', 'Non-Spastic', 'Inactive'})
else
    set(gca,'XTick', [1 2]), set(gca, 'XTickLabels', {'Spastic', 'Non-Spastic'})
    set(gca,'YTick', [1 2]), set(gca, 'YTickLabels', {'Spastic', 'Non-Spastic'})
%    set(gca,'FontSize', 20)
end

figure; histogram(balacc(1,1:n(1)),10);
title('Hamstring Accuracy Distribution')
xlabel('Accuracy')
ylabel('Number of Subjects')
%set(gca,'FontSize', 20)
figure; histogram(balacc(2,:),10);
title('Gastrocnemius Accuracy Distribution')
xlabel('Accuracy')
ylabel('Number of Subjects')
%set(gca,'FontSize', 20)


%--------------------------------------------------------------------------
% Prints initial results of data analysis
%--------------------------------------------------------------------------

H_BagTreeAvg = nanmean(accuracy(1,1:n(1)));
G_BagTreeAvg = nanmean(accuracy(2,1:n(2)));

bal1 = 100*nanmean(balacc(1,1:n(1)));
bal2 = 100*nanmean(balacc(2,:));

BT_Avg = mean([H_BagTreeAvg G_BagTreeAvg]);

fprintf('All HA Accuracy [Hamstring]: %5.3f%%\n', 100*H_BagTreeAvg)
fprintf('All HA Accuracy [Gastrocnemius]: %5.3f%%\n', 100*G_BagTreeAvg)

fprintf('------------------------------------------------------------\n')

fprintf('Bagged Tree Model Accuracy: %5.3f%%\n', 100*BT_Avg)
fprintf('Balanced Accuracy [Hamstring]: %5.3f%%\n', bal1)
fprintf('Balanced Accuracy [Gastrocnemius]: %5.3f%%\n', bal2)
fprintf('Balanced Accuracy Overall: %5.3f%%\n', nanmean([bal1 bal2]))
