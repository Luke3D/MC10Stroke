% Error Analysis
% Run after running DataProcessing.m

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Patients with an Ashworth Score of 0
% Hamstring:        14
% Gastrocnemius     2-11, 13-15, 20, 29(index of 27)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
n = {[1 2 3 4 5 6 7 8 9 10 12 13 14], [1 2 4 5 6 8 9 10 12 14 16 17 20 24 26]};
location = {'Hamstring', 'Gastrocnemius'};
sub = {'h' 'g'};
index = [];

num_IA = 0; num_SA = 0; num_HA = 0;

for ii = 1:length(n)
    for jj = n{ii}
        tempLabels = PatientData.([sub{ii} 'Label']){jj};
        
        if sum(strcmp(tempLabels, 'SA')) == 0
        else
        
        for kk = 1:length(tempLabels)
            if strcmp(tempLabels(kk), 'IA')
                num_IA = num_IA + 1;
            elseif strcmp(tempLabels(kk), 'SA')
                num_SA = num_SA + 1;
            elseif strcmp(tempLabels(kk), 'HA')
                num_HA = num_HA + 1;
            end
        end
        
        if sum(strcmp(tempLabels, 'SA')) >= 1
            index = [index [ii;jj]];
        end
        
        end
    end
end

if inclInactive
    A = [num_SA, num_HA, num_IA];
    
    figure
    bar([num_SA; num_HA; num_IA])
    set(gca,'XTickLabel',{'Spastic', 'Non-Spastic', 'Inactive'})
    xlabel('Activity')
    ylabel('Instances of Labeled Activity')
    text(1:3,A',num2str(A','%5d'),... 
    'HorizontalAlignment','center', 'VerticalAlignment','top',...
    'Color', 'w')
else
    A = [num_SA, num_HA];
    
    figure
    bar([num_SA; num_HA])
    set(gca,'XTickLabel',{'Spastic', 'Non-Spastic'})
    xlabel('Activity')
    ylabel('Instances of Labeled Activity')
    text(1:2,A',num2str(A','%5d'),... 
    'HorizontalAlignment','center', 'VerticalAlignment','top',...
    'Color', 'w')
end