% Data Processing
% Analyzes resulst from PredictAccuracy.m, only run after running Predict
% Accuracy.m

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Calculation of relationship between Ashworth Scores and Model Accuracy
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
load('AshworthScores.mat')

KElab = []; PFlab = [];
KEval = []; PFval = [];

for ii = [1:14 19 24 29]
        if strcmp(Ashworth{ii}.KE, '1+')
            KElab = [KElab; Ashworth{ii}.KE];
            KEval = [KEval 1.5];
        else
            KElab = [KElab; '0' num2str(Ashworth{ii}.KE)];
            KEval = [KEval Ashworth{ii}.KE];
        end
end

for jj = [1:21 23:30]
    if strcmp(Ashworth{jj}.PF, '1+')
        PFlab = [PFlab; Ashworth{jj}.PF];
        PFval = [PFval 1.5];
    else
        PFlab = [PFlab; '0' num2str(Ashworth{jj}.PF)];
        PFval = [PFval Ashworth{jj}.PF];
    end
end

hamstring_bt = 100*accuracy(1,1:17);
x1 = 1:17;

gastro_bt = 100*accuracy(2,:);
x2 = 1:29;

a1 = nanmean(hamstring_bt);
a2 = nanmean(gastro_bt);

A = [a1 a2];

M = [hamstring_bt gastro_bt]';
m1 = repmat('H_BT',size(hamstring_bt,2),1);
m2 = repmat('G_BT',size(gastro_bt,2),1);

m = [m1; m2];

figure
boxplot(M,m,'Labels',{'Hamstring','Gastrocnemius'})
title('Accuracy Comparison of Muscles [Bagged Trees]')
xlabel('Muscle Activity')
ylabel('Accuracy [%]')
text(1:2,A',num2str(A','%4.2f'),... 
'HorizontalAlignment','center', 'VerticalAlignment','middle')

figure
gscatter(KEval, 100*accuracy(1,1:17), KElab)
ax = gca;
ax.XTick = [0 1 1.5 2 3];
ax.XTickLabel = {'0', '1', '1+', '2', '3'};
legend(ax,'off')
title('Ashworth Scores vs. Model Accuracy [Hamstring]')
xlabel('Asworth Scores')
ylabel('Model Accuracy [%]')

figure
gscatter(PFval, 100*accuracy(2,:), PFlab)
ax = gca;
ax.XTick = [0 1 1.5 2 3];
ax.XTickLabel = {'0', '1', '1+', '2', '3'};
legend(ax,'off')
title('Ashworth Scores vs. Model Accuracy [Gastrocnemius]')
xlabel('Asworth Scores')
ylabel('Model Accuracy [%]')

ash = [KEval PFval];
acy = [100*accuracy(1,1:17) 100*accuracy(2,:)];
labels = [KElab; PFlab];

p = polyfit(ash(~isnan(acy)), acy(~isnan(acy)), 2);
f = polyval(p, ash);
t = 0:3/41:3;
ft = polyval(p, t);

figure
gscatter(ash, acy, labels)
ax = gca;
ax.XTick = [0 1 1.5 2 3];
ax.XTickLabel = {'0', '1', '1+', '2', '3'};
legend(ax,'off')
title('Ashworth Scores vs. Model Accuracy [Both Muscles]')
xlabel('Asworth Scores')
ylabel('Model Accuracy [%]')
hold on
plot(ash, f, '*k')
plot(t, ft, '.-k')
hold off

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Precision and Recall Calculations
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

Precision = [];
Recall = [];

for i = 1:2
    temp = TrueConf{i};

    tempPre = diag(temp) ./ sum(temp,1)';
    tempRec = diag(temp) ./ sum(temp,2);
    
    tempPre(isnan(tempPre)) = 0;
    tempRec(isnan(tempRec)) = 0;
    
    Precision(:,i) = tempPre;
    Recall(:,i) = tempRec;
    
end