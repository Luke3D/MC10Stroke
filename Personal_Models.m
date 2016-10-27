%% Personal Spasticity model
clear all

load FullPatientData

% Ham

for i=1:length(PatientData.h)
    Data=PatientData.h{1,i};
    Labels=PatientData.hLabel{1,i};
    
    if isempty(Data)
        continue
    end
    
    IA_inds=strcmp(Labels,'IA');
    Labels=Labels(~IA_inds);
    Data=Data(~IA_inds,:);
    
    inds_1=Data(:,1)==1;
    inds_2=Data(:,1)==2;
    
    SA_inds=strcmp(Labels,'SA');
    
    if ~any(inds_1 & SA_inds) || ~any(inds_2 & SA_inds)
        continue
    end
    
    HA_inds=strcmp(Labels,'HA');
    
    if ~any(inds_1 & HA_inds) || ~any(inds_2 & HA_inds)
        continue
    end
    
    Train=Data(inds_1,2:end);
    Test=Data(inds_2,2:end);
    
%     Model=TreeBagger(100,Train,Labels(inds_1)');
    t = templateTree('MinLeafSize',5);
    Model = fitensemble(Train, Labels(inds_1), 'RUSBoost', 50, t,'LearnRate',.1);
    figure; plot(loss(Model,Test,Labels(inds_2),'mode','cumulative'))
    predictions=predict(Model,Test);
    ConfMat{1,i}=confusionmat(Labels(inds_2)',predictions,'order',{'SA' 'HA'});
end

%% Gas

for i=1:length(PatientData.h)
    Data=PatientData.g{1,i};
    Labels=PatientData.gLabel{1,i};
    
    if isempty(Data)
        continue
    end
    
    IA_inds=strcmp(Labels,'IA');
    Labels=Labels(~IA_inds);
    Data=Data(~IA_inds,:);
    
    inds_1=Data(:,1)==1;
    inds_2=Data(:,1)==2;
    
    
    SA_inds=strcmp(Labels,'SA');
    
    if ~any(inds_1 & SA_inds) || ~any(inds_2 & SA_inds)
        continue
    end
    
    HA_inds=strcmp(Labels,'HA');
    
    if ~any(inds_1 & HA_inds) || ~any(inds_2 & HA_inds)
        continue
    end
    
    Train=Data(inds_1,2:end);
    Test=Data(inds_2,2:end);
    
%     Model=TreeBagger(100,Train,Labels(inds_1)');
    t = templateTree('MinLeafSize',5);
    Model = fitensemble(Train, Labels(inds_1), 'RUSBoost', 50, t,'LearnRate',.1);
    figure; plot(loss(Model,Test,Labels(inds_2),'mode','cumulative'))
    predictions=predict(Model,Test);
    ConfMat{2,i}=confusionmat(Labels(inds_2)',predictions,'order',{'SA' 'HA'});
end