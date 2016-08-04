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
        if accuracy(i,j) < 0.6
            bad = [bad j];
        else
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
group1 = [repmat('hg', size(Ash.good{1},2), 1); repmat('hb', size(Ash.bad{1},2),1)];
group2 = [repmat('gg', size(Ash.good{2},2), 1); repmat('gb', size(Ash.bad{2},2),1)];

figure
boxplot([Ash.good{1} Ash.bad{1}]', group1)
ax = gca;
ax.YTick = [0 1 1.5 2 3];
ax.YTickLabel = {'0', '1', '1+', '2', '3'};
ax.XTick = [1 2];
ax.XTickLabel = {'Good Data', 'Bad Data'};
legend(ax,'off')
title('Hamstring Accuracy')
xlabel('Classification Ability')
ylabel('Ashworth Score')

figure
boxplot([Ash.good{2} Ash.bad{2}]', group2)
ax = gca;
ax.YTick = [0 1 1.5 2 3];
ax.YTickLabel = {'0', '1', '1+', '2', '3'};
ax.XTick = [1 2];
ax.XTickLabel = {'Good Data', 'Bad Data'};
legend(ax,'off')
title('Gastrocnemius Accuracy')
xlabel('Classification Ability')
ylabel('Ashworth Score')