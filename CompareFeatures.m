% CompareFeatures.m
%
% Run after PredictAccuracy.m and DataProcessing.m

% Sub{1}=([1:14 19 24 29]).'; % Hamstring index
% Sub{2}=([1:21 23:30]).';
%load('AshworthScores.mat')
Data = {};  Ash_good = [];  Ash_bad = [];

Sub = [17 29];
Name = {'h' 'g'};

for i = 1:length(Sub)
    good = []; bad = [];
    
    for j = 1:Sub(i)
        if (balacc(i,j) < 0.7) && ~isnan(balacc(i,j))
            bad = [bad j];
        elseif (balacc(i,j) >= 0.7) && ~isnan(balacc(i,j))
            good = [good j];
        end
    end
    
    tempData_good = []; tempData_bad = []; u = []; s = [];
    
    for j = good;
        tempData_good = [tempData_good; PatientData.([Name{i}]){j}];
    end
    
    for j = bad;
        tempData_bad = [tempData_bad; PatientData.([Name{i}]){j}];
    end
    
    uTemp = mean([tempData_good; tempData_bad]);
    sTemp = std([tempData_good; tempData_bad]);
    
    u = repmat(uTemp, size(tempData_good,1), 1);
    s = repmat(sTemp, size(tempData_good,1), 1);
    
    Data.good{i} = (tempData_good - u) ./ s;
    
    u = []; s = [];
    
    u = repmat(uTemp, size(tempData_bad,1), 1);
    s = repmat(sTemp, size(tempData_bad,1), 1);
    
    Data.bad{i} = (tempData_bad - u) ./ s;
    
    if i == 1
        Ash.good{i} = KEval(good);
        Ash.bad{i} = KEval(bad);
    else
        Ash.good{i} = PFval(good);
        Ash.bad{i} = PFval(bad);
    end
    Subjects{i} = [good bad];
    good = []; bad = [];
end


% Plots features comparisons
figure
subplot(2,1,1)
h = boxplot(Data.good{1});
set(h(7,:),'Visible','off')
ylim([-5 5])
title('Good Hamstring Data')
xlabel('Features')
ylabel('Z-Score')

subplot(2,1,2)
h = boxplot(Data.bad{1});
set(h(7,:),'Visible','off')
ylim([-5 5])
title('Bad Hamstring Data')
xlabel('Features')
ylabel('Z-Score')

figure
subplot(2,1,1)
h = boxplot(Data.good{2});
set(h(7,:),'Visible','off')
ylim([-5 5])
title('Good Gastrocnemius Data')
xlabel('Features')
ylabel('Z-Score')

subplot(2,1,2)
h = boxplot(Data.bad{2});
set(h(7,:),'Visible','off')
ylim([-5 5])
title('Bad Gastrocnemius Data')
xlabel('Features')
ylabel('Z-Score')


% Plots Ashworth Score Relationship, needs variables and values from
% DataProcessing.m
% group1 = [repmat('hg', size(Ash.good{1},2), 1); repmat('hb', size(Ash.bad{1},2),1)];
% group2 = [repmat('gg', size(Ash.good{2},2), 1); repmat('gb', size(Ash.bad{2},2),1)];

figure
h1 = histogram(Ash.good{1}, length(Ash.good{1}), 'BinWidth', 0.25);
hold on;
h2 = histogram(Ash.bad{1}, length(Ash.bad{1}), 'BinWidth', 0.25);
ax = gca;
ax.XTick = [0 1 1.5 2 3];
ax.XTickLabel = {'0', '1', '1+', '2', '3'};
legend('Good Data', 'Bad Data')
title('Hamstring Ashworth Score Distributions')
xlabel('Ashworth Score')
ylabel('Number of Subjects')
hold off;

figure
h3 = histogram(Ash.good{2}, length(Ash.good{2}), 'BinWidth', 0.25);
hold on;
h4 = histogram(Ash.bad{2}, length(Ash.bad{2}), 'BinWidth', 0.25);
ax = gca;
ax.XTick = [0 1 1.5 2 3];
ax.XTickLabel = {'0', '1', '1+', '2', '3'};
legend('Good Data', 'Bad Data')
title('Gastrocnemius Ashworth Score Distributions')
xlabel('Ashworth Score')
ylabel('Number of Subjects')
hold off;