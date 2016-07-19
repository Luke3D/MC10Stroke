%load('PatientData.mat')
load('FullPatientData.mat')

N = {'h' 'g'};
n = [15, 27];
nTrees = 50;
y = 1;

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
%         for kk = 1:30
%             if kk ~= jj
%                 trainingData = [trainingData; PatientData.([N{ii}]){kk}];
%                 trainingLabels = [trainingLabels; PatientData.([N{ii} 'Label']){kk}];
%             end
%         end
        tempData = PatientData.([N{ii}]);
        tempLabels = PatientData.([N{ii} 'Label']);
        tempData(jj) = [];
        tempLabels(jj) = [];
        
        parfor kk = 1:length(tempData)
            trainingData=[trainingData; tempData{kk}];
            trainingLabels=[trainingLabels; tempLabels{kk}];
        end
        
        testData = PatientData.([N{ii}]){jj};
        testLabels = PatientData.([N{ii} 'Label']){jj};
        
        RFModel = TreeBagger(nTrees, trainingData, trainingLabels);
        [LabelsRF, P1, RF1] = predict(RFModel, testData);
        
        ConfMat{ii,jj}=confusionmat(testLabels, LabelsRF);
        accuracy(ii,jj) = mean(strcmp(testLabels, LabelsRF));
        
%         testLabels = char(testLabels);
%         testLabels = testLabels(:,1);
%         testLabels = oneHot(testLabels);
%         
%         LabelsRF = char(LabelsRF);
%         LabelsRF = LabelsRF(:,1);
%         LabelsRF = oneHot(LabelsRF);
%         
%         subplot(4,4,y)
%         plotconfusion(testLabels, LabelsRF);

        trainingData = [];
        trainingLabels = [];

        testData = [];
        testLabels = [];
        
        tempData = [];
        tempLabels = [];
     end

     tempMat = zeros(length(ConfMat{ii,jj}));
     
     for jj = 1:n(ii)
         x = unique(LabelsRF);
         
         RealConfMat{ii,jj} = checkLab(x, ConfMat{ii,jj}, num);
         
         for kk = 1:numel(RealConfMat{ii,jj})
             if isnan(RealConfMat{ii,jj}(kk))
                 RealConfMat{ii,jj}(kk) = 0;
             end
         end
     end
     
     for jj = 1:n(ii)
         tempMat = tempMat + RealConfMat{ii,jj};
     end
     
     TrueConf{ii} = tempMat;
     tempMat = zeros(length(ConfMat{ii,jj}));
     
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

H_BagTreeAvg = mean(accuracy(1,1:15));  % Only elements 1-15 have data
G_BagTreeAvg = mean(accuracy(2,:));

BT_Avg = mean([H_BagTreeAvg G_BagTreeAvg]);

fprintf('Bagged Tree Accuracy [Hamstring]: %5.3f%%\n', 100*H_BagTreeAvg)
fprintf('Bagged Tree Accuracy [Gastrocnemius]: %5.3f%%\n', 100*G_BagTreeAvg)

fprintf('------------------------------------------------------------\n')

fprintf('Bagged Tree Model Accuracy: %5.3f%%\n', 100*BT_Avg)