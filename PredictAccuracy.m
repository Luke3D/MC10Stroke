load('PatientData.mat')
N = {'h' 'g'};
n = [15, 27];
nTrees = 50;

trainingData = [];
trainingLabels= [];

testData = [];
testLabels = [];

tempData = [];
tempLabels = [];

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
        

        trainingData = [];
        trainingLabels = [];

        testData = [];
        testLabels = [];
        
        tempData = [];
        tempLabels = [];
        
    end
    
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



