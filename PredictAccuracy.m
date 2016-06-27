load('PatientData.mat')
N = {'h' 'g'};
n = [14, 27];
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
        
        parfor kk = 1:length(tempData)
            trainingData=[trainingData; tempData{kk}];
            trainingLabels=[trainingLabels; tempLabels{kk}];
        end
        
        tempData(jj) = [];
        tempLabels(jj) = [];
        
        testData = PatientData.([N{ii}]){jj};
        testLabels = PatientData.([N{ii} 'Label']){jj};
        
        RFModel = TreeBagger(nTrees, trainingData, trainingLabels);
        [LabelsRF, P1, RF1] = predict(RFModel, testData);

        Ensemble = fitensemble(trainingData, trainingLabels, 'RUSBoost', nTrees, 'Tree');
        [LabelsRUS, P2] = predict(Ensemble, testData);
        
        ConfMat1{ii,jj}=confusionmat(testLabels, LabelsRF);
        accuracy1(ii,jj) = mean(strcmp(testLabels, LabelsRF));
        
        ConfMat2{ii,jj}=confusionmat(testLabels, LabelsRUS);
        accuracy2(ii,jj) = mean(strcmp(testLabels, LabelsRUS));
%         C{ii,jj} = unique(trainingData);

        trainingData = [];
        trainingLabels = [];

        testData = [];
        testLabels = [];
        
        tempData = [];
        tempLabels = [];
        
    end
    
end

H_TreeBaggerAvg = mean(accuracy1(1,1:14));  % Only 1-14 has data, rest are 0's from Gastrocnemius sharing same array
H_RUSBoostAvg = mean(accuracy2(1,1:14));
G_TreeBaggerAvg = mean(accuracy1(2,:));
G_RUSBoostAvg = mean(accuracy2(2,:));

fprintf('Tree Bagger Accuracy [Hamstring]: %5.3f%%\n', 100*H_TreeBaggerAvg)
fprintf('Tree Bagger Accuracy [Gastrocnemius]: %5.3f%%\n', 100*G_TreeBaggerAvg)

fprintf('RUS Boost Accuracy [Hamstring]: %5.3f%%\n', 100*H_RUSBoostAvg)
fprintf('RUS Boost Accuracy [Gastrocnemius]: %5.3f%%\n', 100*G_RUSBoostAvg)


