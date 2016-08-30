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
    tempHa_good = []; tempHa_bad = [];
    
    % assemble good and bad data for SA and HA conditions
    for j = good;
        SA_inds=find(strcmp(PatientData.([Name{i} 'Label']){j},'SA'));
        tempData_good = [tempData_good; PatientData.([Name{i}]){j}(SA_inds,:)];
        
        HA_inds=find(strcmp(PatientData.([Name{i} 'Label']){j},'HA'));
        tempHa_good = [tempHa_good; PatientData.([Name{i}]){j}(HA_inds,:)];
    end
    
    for j = bad;
        SA_inds=find(strcmp(PatientData.([Name{i} 'Label']){j},'SA'));
        tempData_bad = [tempData_bad; PatientData.([Name{i}]){j}(SA_inds,:)];
        
        HA_inds=find(strcmp(PatientData.([Name{i} 'Label']){j},'HA'));
        tempHa_bad = [tempHa_bad; PatientData.([Name{i}]){j}(HA_inds,:)];
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
    
    uTemp = mean([tempHa_good; tempHa_bad]);
    sTemp = std([tempHa_good; tempHa_bad]);
    
    u = repmat(uTemp, size(tempHa_good,1), 1);
    s = repmat(sTemp, size(tempHa_good,1), 1);
    
    Data.HAgood{i} = (tempHa_good - u) ./ s;
    
    u = []; s = [];
    
    u = repmat(uTemp, size(tempHa_bad,1), 1);
    s = repmat(sTemp, size(tempHa_bad,1), 1);
    
    Data.HAbad{i} = (tempHa_bad - u) ./ s;
    
    
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
figure; hold on
h1 = boxplot(Data.good{1},'colors','b');
h2 = boxplot(Data.bad{1},'colors','r');
hold off
set(h1(7,:),'Visible','off')
set(h2(7,:),'Visible','off')
ylim([-5 5])
title('Hamstring Data [Spastic]')
xlabel('Features')
ylabel('Z-Score')

figure; hold on
h1 = boxplot(Data.good{2},'colors','b');
h2 = boxplot(Data.bad{2},'colors','r');
hold off
set(h1(7,:),'Visible','off')
set(h2(7,:),'Visible','off')
ylim([-5 5])
title('Gastrocnemius Data [Spastic]')
xlabel('Features')
ylabel('Z-Score')

% Plots HA features comparisons
figure; hold on
h1 = boxplot(Data.HAgood{1},'colors','b');
h2 = boxplot(Data.HAbad{1},'colors','r');
hold off
set(h1(7,:),'Visible','off')
set(h2(7,:),'Visible','off')
ylim([-5 5])
title('Hamstring Data [Non-Spastic]')
xlabel('Features')
ylabel('Z-Score')

figure; hold on
h1 = boxplot(Data.HAgood{2},'colors','b');
h2 = boxplot(Data.HAbad{2},'colors','r');
hold off
set(h1(7,:),'Visible','off')
set(h2(7,:),'Visible','off')
ylim([-5 5])
title('Gastrocnemius Data [Non-Spastic]')
xlabel('Features')
ylabel('Z-Score')



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