% Error Analysis
% Run after running DataProcessing.m

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Patients with an Ashworth Score of 0
% Hamstring:        14
% Gastrocnemius     2-11, 13-15, 20, 29(index of 27)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
ratio_h = [];   ratio_g = [];         % Actual Ratio Values
r_h = [];       r_g = [];             % Row 1: # SA, Row 2: # HA
ash_h = KEval;  ash_g = PFval;
h_label = KElab;   g_label = PFlab;

scr_0 = []; scr_1 = []; scr_1plus = []; scr_2 = []; scr_3 = [];
ind_0 = []; ind_1 = []; ind_1plus = []; ind_2 = []; ind_3 = [];

n1 = 1;     n2 = 1;     n3 = 1;         n4 = 1;     n5 = 1;

for i = 1:length(PatientData.hLabel)
    temp1 = PatientData.hLabel{i};
    temp1 = cell2mat(temp1);
    sa = 0; ha = 0;
    
    for j = 1:length(temp1)
        if strcmp(temp1(j,:), 'HA')
            ha = ha + 1;
        else
            sa = sa + 1;
        end
    end
    
    r_h(1,i) = sa;
    r_h(2,i) = ha;
    temp1 = [];
    
    if strcmp(h_label(i,:), '00')
        scr_0 = [scr_0; sa / ha];
        ind_0(n1) = i;
        n1 = n1 + 1;
        
    elseif strcmp(h_label(i,:), '01')
        scr_1 = [scr_1; sa / ha];
        ind_1(n2) = i;
        n2 = n2 + 1;
        
    elseif strcmp(h_label(i,:), '1+')
        scr_1plus = [scr_1plus; sa / ha];
        ind_1plus(n3) = i;
        n3 = n3 + 1;
        
    elseif strcmp(h_label(i,:), '02')
        scr_2 = [scr_2; sa / ha];
        ind_2(n4) = i;
        n4 = n4 + 1;
        
    else
        scr_3 = [scr_3; sa / ha];
        ind_3(n5) = i;
        n5 = n5 + 1;
    end
end

for ii = 1:length(PatientData.gLabel)
    temp2 = PatientData.gLabel{ii};
    temp2 = cell2mat(temp2);
    sa = 0; ha = 0;
    
    for jj = 1:length(temp2)
        if strcmp(temp2(jj,:), 'HA')
            ha = ha + 1;
        else
            sa = sa + 1;
        end
    end
    
    r_g(1,ii) = sa;
    r_g(2,ii) = ha;
    temp2 = [];
    
    if strcmp(g_label(ii,:), '00')
        scr_0 = [scr_0; sa / ha];
        ind_0(n1) = ii;
        n1 = n1 + 1;
        
    elseif strcmp(g_label(ii,:), '01')
        scr_1 = [scr_1; sa / ha];
        ind_1(n2) = ii;
        n2 = n2 + 1;
        
    elseif strcmp(g_label(ii,:), '1+')
        scr_1plus = [scr_1plus; sa / ha];
        ind_1plus(n3) = ii;
        n3 = n3 + 1;
        
    elseif strcmp(g_label(ii,:), '02')
        scr_2 = [scr_2; sa / ha];
        ind_2(n4) = ii;
        n4 = n4 + 1;
        
    else
        scr_3 = [scr_3; sa / ha];
        ind_3(n5) = ii;
        n5 = n5 + 1;
    end
end

ratio_h = r_h(1,:) ./ r_h(2,:); % Ratio of SA / HA
ratio_g = r_g(1,:) ./ r_g(2,:);


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Plots
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
figure
gscatter(ash_h, ratio_h, h_label)
ax = gca;
ax.XTick = [0 1 1.5 2 3];
ax.XTickLabel = {'0', '1', '1+', '2', '3'};
legend(ax,'off')
title('Ashworth Scores vs. SA/HA Ratio [Hamstring]')
xlabel('Asworth Scores')
ylabel('SA/HA Ratio')

figure
gscatter(ash_g, ratio_g, g_label)
ax = gca;
ax.XTick = [0 1 1.5 2 3];
ax.XTickLabel = {'0', '1', '1+', '2', '3'};
legend(ax,'off')
title('Ashworth Scores vs. SA/HA Ratio [Gastrocnemius]')
xlabel('Asworth Scores')
ylabel('SA/HA Ratio')

figure
gscatter([ash_h ash_g], [ratio_h ratio_g], [h_label; g_label])
ax = gca;
ax.XTick = [0 1 1.5 2 3];
ax.XTickLabel = {'0', '1', '1+', '2', '3'};
legend(ax,'off')
title('Ashworth Scores vs. SA/HA Ratio')
xlabel('Asworth Scores')
ylabel('SA/HA Ratio')

figure
subplot(3,2,1)
hist(scr_0)
xlabel('SA/HA Ratio')
ylabel('Number of Patients')
title('Ashworth Score: 0')

subplot(3,2,2)
hist(scr_1)
xlabel('SA/HA Ratio')
ylabel('Number of Patients')
title('Ashworth Score: 1')

subplot(3,2,3)
hist(scr_1plus)
xlabel('SA/HA Ratio')
ylabel('Number of Patients')
title('Ashwoth Score: 1+')

subplot(3,2,4)
hist(scr_2)
xlabel('SA/HA Ratio')
ylabel('Number of Patients')
title('Ashworth Score: 2')

subplot(3,2,5)
hist(scr_3)
xlabel('SA/HA Ratio')
ylabel('Number of Patients')
title('Ashworth Score: 3')

scr_all = [scr_0; scr_1; scr_1plus; scr_2; scr_3];

subplot(3,2,6)
hist(scr_all)
xlabel('SA/HA Ratio')
ylabel('Number of Patients')
title('Histogram of all Ashworth Scores')