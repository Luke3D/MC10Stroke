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

for ii = 1:15
    if ii == 15
        if strcmp(Ashworth{19}.KE, '1+')
            KElab = [KElab; Ashworth{19}.KE];
            KEval(ii) = 1.5;
        else
            KElab = [KElab; '0' num2str(Ashworth{19}.KE)];
            KEval(ii) = Ashworth{19}.KE;
        end        
    else
        if strcmp(Ashworth{ii}.KE, '1+')
            KElab = [KElab; Ashworth{ii}.KE];
            KEval(ii) = 1.5;
        else
            KElab = [KElab; '0' num2str(Ashworth{ii}.KE)];
            KEval(ii) = Ashworth{ii}.KE;
        end
    end
end

for jj = [1:20 23:29]
    if strcmp(Ashworth{jj}.PF, '1+')
        PFlab = [PFlab; Ashworth{jj}.PF];
        PFval(jj) = 1.5;
    else
        PFlab = [PFlab; '0' num2str(Ashworth{jj}.PF)];
        PFval(jj) = Ashworth{jj}.PF;
    end
end


PFval = PFval([1:20 23:29]);

hamstring_bt = 100*accuracy(1,1:15);
x1 = 1:15;

gastro_bt = 100*accuracy(2,:);
x2 = 1:27;

a1 = mean(hamstring_bt(1:14));
a2 = mean(gastro_bt);

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
text(1:2,A',num2str(A','%0.2f'),... 
'HorizontalAlignment','center', 'VerticalAlignment','middle')

figure
gscatter(KEval, 100*accuracy(1,[1:14 19]), KElab)
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
acy = [100*accuracy(1,[1:14 19]) 100*accuracy(2,:)];
labels = [KElab; PFlab];

p = polyfit(ash, acy, 2);
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
C = ConfMat;  n = max(size(C));

C_H = cell(1,n);    C_G = cell(1,n);
tp1 = 0; tn1 = 0; fp1 = 0; fn1 = 0;
tp2 = 0; tn2 = 0; fp2 = 0; fn2 = 0;

for ii = 1:n
    temp1 = C{1,ii};
    temp2 = C{2,ii};
    mVal1 = max(temp1(:));
    mVal2 = max(temp2(:));
    n1 = numel(temp1);
    n2 = numel(temp2);
    for k1 = 1:n1
        C_H{ii}(k1) = temp1(k1) / mVal1;    % Normalize data
    end
    
    for k2 = 1:n2
        C_G{ii}(k2) = temp2(k2) / mVal2;
    end
end

for i = 1:n
    if C_H{i} == 1
        C_H{i} = [];    % Remove extraneous data (ConfMat = integer)
    end
end
for j = 1:n
    if C_G{j} == 1
        C_G{j} = [];
    end
end

C_H = C_H(~cellfun('isempty',C_H)); % Remove empty cells
C_G = C_G(~cellfun('isempty',C_G));

temp1 = []; temp2 = [];

for ii = 1:length(C_H)
    temp1 = C_H{ii};
    tp1 = temp1(1);   % Gather true positive, false negative, false positive, and true negative per cell
    fn1 = temp1(3);
    fp1 = temp1(2);
    tn1 = temp1(4);
    
    if tp1 == 0
        Precision1(ii) = 0;
        Recall1(ii) = 0;
    else
        Precision1(ii) = tp1 / (tp1 + fp1);
        Recall1(ii) = tp1 / (tp1 + fn1); 
    end
end
for jj = 1:length(C_G)
    temp2 = C_G{jj};
    tp2 = temp2(1);
    fn2 = temp2(3);
    fp2 = temp2(2);
    tn2 = temp2(4);
    
    if tp2 == 0
        Precision2(jj) = 0;
        Recall2(jj) = 0;
    else
        Precision2(jj) = tp2 / (tp2 + fp2);
        Recall2(jj) = tp2 / (tp2 + fn2);
    end
end

Precision1 = 100*Precision1(Precision1~=0);
Precision2 = 100*Precision2(Precision2~=0);
Recall1 = 100*Recall1(Recall1~=0);
Recall2 = 100*Recall2(Recall2~=0);

Precision_H = mean(Precision1);
Precision_G = mean(Precision2);

Recall_H = mean(Recall1);
Recall_G = mean(Recall2);

fprintf('\nHamstring Data\n')
fprintf('Mean Precision: %f\n', Precision_H)
fprintf('Mean Recall:    %f\n', Recall_H)
fprintf('-----------------------------\n')
fprintf('Gastrocnemius Data\n')
fprintf('Mean Precision: %f\n', Precision_G)
fprintf('Mean Recall:    %f\n', Recall_G)

XH = Precision1';   XG = Precision2';
X = [XH; XG];
M1 = repmat('H',1,length(Precision1));
M2 = repmat('G',1,length(Precision2));
M = [M1 M2]';

figure
boxplot(X,M,'Labels',{'Hamstring', 'Gastrocnemius'})
title('Calculated Precision')
xlabel('Muscle')
ylabel('Precision [%]')
ylim([0 105])

XH2 = Recall1';     XG2 = Recall2';
X2 = [XH2; XG2];
Mone = repmat('H',1,length(Recall1));
Mtwo = repmat('G',1,length(Recall2));
Mtot = [Mone Mtwo]';

figure
boxplot(X2,Mtot,'Labels',{'Hamstring', 'Gastrocnemius'})
title('Calculated Recall')
xlabel('Muscle')
ylabel('Recall [%]')
ylim([0 105])