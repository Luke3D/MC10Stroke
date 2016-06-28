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
% Prints results of data analysis
%--------------------------------------------------------------------------

H_BagTreeAvg = mean(accuracy(1,1:15));  % Only elements 1-15 have data
G_BagTreeAvg = mean(accuracy(2,:));

BT_Avg = mean([H_BagTreeAvg G_BagTreeAvg]);

fprintf('Bagged Tree Accuracy [Hamstring]: %5.3f%%\n', 100*H_BagTreeAvg)
fprintf('Bagged Tree Accuracy [Gastrocnemius]: %5.3f%%\n', 100*G_BagTreeAvg)

fprintf('------------------------------------------------------------\n')

fprintf('Bagged Tree Model Accuracy: %5.3f%%\n', 100*BT_Avg)

%--------------------------------------------------------------------------
% Plots Collected Data in Graphs
%--------------------------------------------------------------------------
hamstring_bt = 100*accuracy(1,1:15);
x1 = 1:15;

gastro_bt = 100*accuracy(2,:);
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
