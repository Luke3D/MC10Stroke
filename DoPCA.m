close all

%subject=([1:20 23:29]).';   % For Hamstring, 15-18 have no hamstring data (6/27/16)
subject=([1:14 19]).'; % Hamstring index
subject=num2str(subject);
if size(subject,2)==1
    subject=[repmat(' ',[length(subject) 1]) subject];
end
for i=1:size(subject,1)
    if strcmp(subject(i,1),' ')
        subject(i,1)='0';
    end
end

location=['Hamstring']; % Use '**' for both
filenames=[];

f=[]; lab=[];

%for n = 1:2
    
for i=1:size(subject,1)
    filenames=[filenames; rdir(['Z:\Stroke MC10\Clips\' subject(i,:) '\**\' location '*F_Feat.mat'])];

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

        f_new=f(:,[1:7 9:14]); %drop Sample Entropy
        inds=strcmp('IA',lab);
        f_new(inds,:)=[];
        lab(inds)=[];

        if strcmp(location, 'Gastrocnemius')
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

        f_new=f(:,[1:7 9:14]); %drop Sample Entropy
        inds=strcmp('IA',lab);
        f_new(inds,:)=[];
        lab(inds)=[];

        if strcmp(location, 'Gastrocnemius')
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
%end

%% PCA
% f_new=f(:,[1:7 9:13]); %drop Sample Entropy
% inds=strcmp('IA',lab);
% f_new(inds,:)=[];
% lab(inds)=[];
% [coeff,score,latent,~,explained] = pca(f_new);
% explained
% figure, gscatter(score(:,1),score(:,2),lab)