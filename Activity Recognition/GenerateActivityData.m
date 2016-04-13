% Generate Activity files from Phone Label Data
clear all

dirname='Z:\Stroke MC10\Activity Recognition\RawData\';
Activities={'Lying' 'Sitting' 'Standing' 'Stairs Up' 'Stairs Down' 'Walking'};

filenames=dir([dirname 'Train\*.csv']);
    
names={filenames.name};
Subj=cell(length(names),1);
for i=1:length(names)
    Subj{i}=names{i}(1:5);
end
Subj=unique(Subj);

for indAct=1:length(Activities)
    for indSub=1:length(Subj)
        filenames=dir([dirname 'Train\' Subj{indSub} '_' Activities{indAct} '*.csv']);
        AllData=[];
        for indFile=1:length(filenames)
            Data=csvread([dirname 'Train\' filenames(indFile).name]);            
            AllData=[AllData; Data];
        end
        csvwrite([dirname 'ActivityData\' Subj{indSub} '_' Activities{indAct} '_Train.csv'], AllData)
    end
end

for indAct=1:length(Activities)
    for indSub=1:length(Subj)
        filenames=dir([dirname 'Test\' Subj{indSub} '_' Activities{indAct} '*.csv']);
        AllData=[];
        for indFile=1:length(filenames)
            Data=csvread([dirname 'Test\' filenames(indFile).name]);            
            AllData=[AllData; Data];
        end
        csvwrite([dirname 'ActivityData\' Subj{indSub} '_' Activities{indAct} '_Test.csv'], AllData)
    end
end