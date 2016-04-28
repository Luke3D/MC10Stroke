%% 
close all
clear all

Cliplen=100;
ClipOverlap=.5;
ax=2;
dirname='Z:\Stroke MC10\Activity Recognition\';
Activities={'Lying' 'Sitting' 'Standing' 'Stairs Up' 'Stairs Down' 'Walking'};
Set={'Train' 'Test'};
for indSet=1:length(Set)
    
    filenames=dir([dirname 'RawData\' Set{indSet} '\*.csv']);

    for indFile=1:length(filenames)
        Data=csvread([dirname 'RawData\' Set{indSet} '\' filenames(indFile).name]);
        name=strsplit(filenames(indFile).name,'_');
        Activity=name{2};  
        ind=find(strcmp(Activity,Activities)==1);
        if isempty(ind)
            continue
        end

        numClips=(length(Data)-(Cliplen*ClipOverlap))/(Cliplen*(1-ClipOverlap));
        numClips=floor(numClips);
        if numClips<3
            continue
        end

    %     r=.2*std(Data(:,ax));

        % Treats sedentary and ambulatory activities separately
        if ind<4
            r=.05;

            s=zeros(numClips,1);

            for i=1:numClips
                d=Data((i-1)*Cliplen*(1-ClipOverlap)+1:(i-1)*Cliplen*(1-ClipOverlap)+Cliplen,ax);

                s(i)=SampEn(5,r,d);
            end

            [val,X]=findpeaks(s);
            rmvinds=find(val<.05);
            X(rmvinds)=[];

            if isempty(X)
                newData=Data;
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\' filenames(indFile).name],newData)
                continue
            end
            
            bursts=diff(X)<10;
            StartInd=find(diff(bursts)==-1,1)+1;
            Start=X(StartInd)+1;
            if isempty(Start)
                newData=Data;
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\' filenames(indFile).name],newData)
                continue
            end

            EndInd=find(diff(bursts(StartInd-1:end))==1);
            End=X(StartInd+EndInd)-1;
            if isempty(End)
                End=X(end);
            end

            newData=Data(Start*ClipOverlap*Cliplen:End*ClipOverlap*Cliplen,:);
        else
            r=.055;

            s=zeros(numClips,1);

            for i=1:numClips
                d=Data((i-1)*Cliplen*(1-ClipOverlap)+1:(i-1)*Cliplen*(1-ClipOverlap)+Cliplen,ax);

                s(i)=SampEn(5,r,d);
            end

            [val,X]=findpeaks(s);
            rmvinds=find(val<.05);
            X(rmvinds)=[];
            if isempty(X)
                newData=Data;
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\' filenames(indFile).name],newData)
                continue
            end
            bursts=diff(X)<7;
            StartInd=find(bursts==0,1)+1;
            if isempty(StartInd)
                StartInd=1;
            end
            Start=X(StartInd);

    %         EndInd=find(bursts==0,1,'last');
    %         if isempty(EndInd) || EndInd<StartInd+1
    %             EndInd=length(X);
    %         end
    %         End=X(EndInd);
            End=X(end);

            newData=Data(Start*ClipOverlap*Cliplen:End*ClipOverlap*Cliplen,:);
        end
        csvwrite([dirname 'TrimmedData\' Set{indSet} '\' filenames(indFile).name],newData)
    end
end
