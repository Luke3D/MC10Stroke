clearvars -except clipLength

Sub{1}=([1:14 19 24 29]).'; % Hamstring index
Sub{2}=([1:21 23:30]).';


location={'Hamstring' 'Gastrocnemius'};
filenames=[];

f=[]; lab=[];

for n = 1:length(location)
    
filenames=[];
subject=num2str(Sub{n});
if size(subject,2)==1
    subject=[repmat(' ',[length(subject) 1]) subject];
end
for i=1:size(subject,1)
    if strcmp(subject(i,1),' ')
        subject(i,1)='0';
    end
end

for i=1:size(subject,1)
    filenames=[filenames; rdir(['Z:\Stroke MC10\Clips\' subject(i,:) '\**\' location{n} '*F_Feat.mat'])];

    len(i) = length(filenames);
end

for x = 1:size(subject,1)
    if x == 1
        for i = 1:len(1);
            Features = load(filenames(i).name);
            Features = Features.AllFeat;
            f = [f; cell2mat({Features(:).Features}')];
            lab = [lab; {Features(:).ActivityLabel}'];
        end
        
        if isempty(f)
            continue
        end
        
%         f_new=f(:,[1:7 9:14]); %drop Sample Entropy
        f_new=f;
%         inds=strcmp('IA',lab);
%         f_new(inds,:)=[];
%         lab(inds)=[];

        if strcmp(location{n}, 'Gastrocnemius')
            PatientData.g{x} = f_new;
            PatientData.gLabel{x} = lab;
        else
            PatientData.h{x} = f_new;
            PatientData.hLabel{x} = lab;
        end

        f = [];
        lab = [];

    else
        for i = len(x-1) + 1 : len(x)
            Features = load(filenames(i).name);
            Features = Features.AllFeat;
            f = [f; cell2mat({Features(:).Features}')];
            lab = [lab; {Features(:).ActivityLabel}'];
        end
        
        if isempty(f)
            continue
        end
        
        f_new=f;
%         f_new=f(:,[1:7 9:14]); %drop Sample Entropy
%         inds=strcmp('IA',lab);
%         f_new(inds,:)=[];
%         lab(inds)=[];

        if strcmp(location{n}, 'Gastrocnemius')
            PatientData.g{x} = f_new;
            PatientData.gLabel{x} = lab;
        else
            PatientData.h{x} = f_new;
            PatientData.hLabel{x} = lab;
        end

        f = [];
        lab = [];
    end
end
end

% save('PatientData.mat', 'PatientData')
save('FullPatientData_HRvC_1s.mat', 'PatientData')
%end

%% PCA
% f_new=f(:,[1:7 9:13]); %drop Sample Entropy
% inds=strcmp('IA',lab);
% f_new(inds,:)=[];
% lab(inds)=[];
% [coeff,score,latent,~,explained] = pca(f_new);
% explained
% figure, gscatter(score(:,1),score(:,2),lab)