close all

subject=(5:5).';
subject=num2str(subject);
if size(subject,2)==1
    subject=[repmat(' ',[length(subject) 1]) subject];
end
for i=1:size(subject,1)
    if strcmp(subject(i,1),' ')
        subject(i,1)='0';
    end
end

location='**'; % Use '**' for both
filenames=[];

for i=1:size(subject,1)
    filenames=[filenames; rdir(['Z:\Stroke MC10\Clips\' subject(i,:) '\**\' location '*F_Feat.mat'])];
end

f=[]; lab=[];

for i=1:length(filenames)
    Features = load(filenames(i).name);
    Features = Features.AllFeat;
    f = [f; cell2mat({Features(:).Features}')];
    lab = [lab;{Features(:).ActivityLabel}'];
end

%% PCA
f_new=f(:,[1:7 9:13]); %drop Sample Entropy
inds=strcmp('IA',lab);
f_new(inds,:)=[];
lab(inds)=[];
[coeff,score,latent,~,explained] = pca(f_new);
explained
figure, gscatter(score(:,1),score(:,2),lab)