%load('PatientData.mat')
clear all

RUS=0;
resamp_test=0;
resamp_train=0;

load('FullPatientData.mat')

N = {'h' 'g'};
n = [17, 29];
nTrees = 50;
index = [];

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
                ConfMat{ii,jj}=[];
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
            Model = fitensemble(trainingData, trainingLabels, 'RUSBoost', 1000,t,'LearnRate',.1);
        else
            Model = TreeBagger(nTrees, trainingData, trainingLabels);
        end
        
%         [LabelsRF, P1, RF1] = predict(Model, testData);
        LabelsRF = predict(Model, testData);
        
        ConfMat{ii,jj} = confusionmat(testLabels, LabelsRF);
        accuracy(ii,jj) = mean(strcmp(testLabels, LabelsRF));
        balacc(ii,jj) = mean(diag(ConfMat{ii,jj})./sum(ConfMat{ii,jj},2));

        trainingData = [];
        trainingLabels = [];

        testData = [];
        testLabels = [];
        
        tempData = [];
        tempLabels = [];
     end
     
     for jj = 1:n(ii)
         x = unique(LabelsRF);
         
         if ~isempty(ConfMat{ii,jj})
             RealConfMat{ii,jj} = checkLab(x, ConfMat{ii,jj}, num);
         else    
             RealConfMat{ii,jj} = zeros(2);
         end
         
         for kk = 1:numel(RealConfMat{ii,jj})
             if isnan(RealConfMat{ii,jj}(kk))
                 RealConfMat{ii,jj}(kk) = 0;
             end
         end
     end
     
     tempMat = zeros(length(RealConfMat{ii,jj}));
     
     for jj = 1:n(ii)
         tempMat = tempMat + RealConfMat{ii,jj};
     end
     
     TrueConf{ii} = tempMat;
     tempMat = zeros(length(RealConfMat{ii,jj}));
     
end


for ii = 1:2
    tempConf = TrueConf{ii};
    correctones = sum(tempConf,2);
    correctones = repmat(correctones,[1 num]);
    TrueConf{ii} = tempConf ./ correctones;
end

figure
imagesc(TrueConf{1}); colorbar
caxis([0 1])
title('Hamstring Confusion Matrix')
if inclInactive
    set(gca,'XTick', [1 2 3]), set(gca, 'XTickLabels', {'Inactive', 'Spastic', 'Non-Spastic'})
    set(gca,'YTick', [1 2 3]), set(gca, 'YTickLabels', {'Inactive', 'Spastic', 'Non-Spastic'})
else
    set(gca,'XTick', [1 2]), set(gca, 'XTickLabels', {'Spastic', 'Non-Spastic'})
    set(gca,'YTick', [1 2]), set(gca, 'YTickLabels', {'Spastic', 'Non-Spastic'})
end

figure
imagesc(TrueConf{2}); colorbar
caxis([0 1])
title('Gastrocnemius Confusion Matrix')
if inclInactive
    set(gca,'XTick', [1 2 3]), set(gca, 'XTickLabels', {'Inactive', 'Spastic', 'Non-Spastic'})
    set(gca,'YTick', [1 2 3]), set(gca, 'YTickLabels', {'Inactive', 'Spastic', 'Non-Spastic'})
else
    set(gca,'XTick', [1 2]), set(gca, 'XTickLabels', {'Spastic', 'Non-Spastic'})
    set(gca,'YTick', [1 2]), set(gca, 'YTickLabels', {'Spastic', 'Non-Spastic'})
end

%--------------------------------------------------------------------------
% Prints initial results of data analysis
%--------------------------------------------------------------------------

H_BagTreeAvg = nanmean(accuracy(1,1:n(1)));
G_BagTreeAvg = nanmean(accuracy(2,1:n(2)));

BT_Avg = mean([H_BagTreeAvg G_BagTreeAvg]);

fprintf('Bagged Tree Accuracy [Hamstring]: %5.3f%%\n', 100*H_BagTreeAvg)
fprintf('Bagged Tree Accuracy [Gastrocnemius]: %5.3f%%\n', 100*G_BagTreeAvg)

fprintf('------------------------------------------------------------\n')

fprintf('Bagged Tree Model Accuracy: %5.3f%%\n', 100*BT_Avg)