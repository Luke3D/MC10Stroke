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

%--------------------------------------------------------------------------
% Prints results of data analysis
%--------------------------------------------------------------------------

H_TreeBaggerAvg = mean(accuracy1(1,1:15));  % Only 1-14 has data, rest are 0's from Gastrocnemius sharing same array
H_RUSBoostAvg = mean(accuracy2(1,1:15));
G_TreeBaggerAvg = mean(accuracy1(2,:));
G_RUSBoostAvg = mean(accuracy2(2,:));

Hamstring_Avg = mean([H_TreeBaggerAvg H_RUSBoostAvg]);
Gastro_Avg = mean([G_TreeBaggerAvg G_RUSBoostAvg]);

BT_Avg = mean([H_TreeBaggerAvg G_TreeBaggerAvg]);
RS_Avg = mean([H_RUSBoostAvg G_RUSBoostAvg]);

fprintf('Tree Bagger Accuracy [Hamstring]: %5.3f%%\n', 100*H_TreeBaggerAvg)
fprintf('Tree Bagger Accuracy [Gastrocnemius]: %5.3f%%\n', 100*G_TreeBaggerAvg)

fprintf('RUS Boost Accuracy [Hamstring]: %5.3f%%\n', 100*H_RUSBoostAvg)
fprintf('RUS Boost Accuracy [Gastrocnemius]: %5.3f%%\n', 100*G_RUSBoostAvg)

fprintf('\n------------------------------------------------------------\n')

fprintf('\nHamstring Accuracy: %5.3f%%\n', 100*Hamstring_Avg)
fprintf('\nGastrocnemius Accuracy: %5.3f%%\n', 100*Gastro_Avg)

fprintf('\nBaggedTrees Accuracy: %5.3f%%\n', 100*BT_Avg)
fprintf('\nRUSBoosted Trees Accuracy: %5.3f%%\n', 100*RS_Avg)

%--------------------------------------------------------------------------
% Plots Collected Data in Graphs
%--------------------------------------------------------------------------
hamstring_bt = 100*accuracy1(1,1:15);
x1 = 1:15;

gastro_bt = 100*accuracy1(2,:);
x2 = 1:27;

a1 = mean(hamstring_bt);
a2 = mean(gastro_bt);

A = [a1 a2];

M = [hamstring_bt gastro_bt]';
m1 = repmat('H_BT',size(hamstring_bt,2),1);
m2 = repmat('G_BT',size(gastro_bt,2),1);

m = [m1; m2];

figure(1)
boxplot(M,m,'Labels',{'Hamstring','Gastrocnemius'})
% set(gca,'FontSize',10,'XTickLabelRotation',45)
title('Accuracy Comparison of Muscles [Bagged Trees]')
xlabel('Muscle Activity')
ylabel('Accuracy [%]')
text(1:2,A',num2str(A','%0.2f'),... 
'HorizontalAlignment','center', 'VerticalAlignment','middle')
