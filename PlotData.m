% Plots Collected Data in Graphs
% Run after PredictAccuracy.m or after loading FinalDataSet.mat

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
