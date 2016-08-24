% Error Analysis
% Run after running DataProcessing.m

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Patients with an Ashworth Score of 0
% Hamstring:        14
% Gastrocnemius     2-11, 13-15, 20, 29(index of 27)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
n = [17 29];
location = {'Hamstring', 'Gastrocnemius'};
sub = {'h' 'g'};
EMGindexSA = []; EMGindexHA = [];

num_IA = 0; num_SA = 0; num_HA = 0;

for ii = 1:length(n)
    for jj = 1:n(ii)
        tempLabels = PatientData.([sub{ii} 'Label']){jj};
        
%         if sum(strcmp(tempLabels, 'SA')) == 0
%             continue
%         else
        
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
            EMGindexSA = [EMGindexSA [ii;jj]];
            labEMG(jj,ii) = 1;
        else
            EMGindexHA = [EMGindexHA [ii;jj]];
            labEMG(jj,ii) = 0;
        end
        
    end
end

[C1, order1] = confusionmat(labASH(1:17,1), labEMG(1:17,1));
correctones = sum(C1,2);
correctones = repmat(correctones,[1 2]);
C1 = C1 ./ correctones;
figure
imagesc(C1); colorbar
caxis([0 1])
title('Hamstring Spasticity Confusion Matrix')
set(gca,'XTick', [1 2]), set(gca, 'XTickLabels', {'Non-Spastic', 'Spastic'})
set(gca,'YTick', [1 2]), set(gca, 'YTickLabels', {'Non-Spastic', 'Spastic'})


[C2, order2] = confusionmat(labEMG(:,2), labASH(:,2));
correctones = sum(C2,2);
correctones = repmat(correctones,[1 2]);
C2 = C2 ./ correctones;
figure
imagesc(C2); colorbar
caxis([0 1])
title('Gastrocnemius Spasticity Confusion Matrix')
set(gca,'XTick', [1 2]), set(gca, 'XTickLabels', {'Non-Spastic', 'Spastic'})
set(gca,'YTick', [1 2]), set(gca, 'YTickLabels', {'Non-Spastic', 'Spastic'})

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