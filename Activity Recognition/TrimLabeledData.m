%% 
close all
clear all

HPF=10;
Fs=250;

Cliplen=100;
ClipOverlap=.5;
ax=2;
dirname='Z:\Stroke MC10\Activity Recognition\';
Activities={'Lying' 'Sitting' 'Standing' 'Stairs Up' 'Stairs Down' 'Walking'};
Set={'Train' 'Test'};
for indSet=1:length(Set)
    
    filenames=dir([dirname 'RawData\' Set{indSet} '\ACC\*.csv']);

    for indFile=1:length(filenames)
        Data=csvread([dirname 'RawData\' Set{indSet} '\ACC\' filenames(indFile).name]);
        EMG=csvread([dirname 'RawData\' Set{indSet} '\EMG\' filenames(indFile).name(1:end-4) '_EMG.csv']);
        
        [B,A] = butter(1, HPF*2/Fs, 'high');
        EMG(:,2:end)=filtfilt(B,A,EMG(:,2:end));
        
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
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\ACC\' filenames(indFile).name],newData)
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\EMG\' filenames(indFile).name(1:end-4) '_EMG'],EMG)
                continue
            end
            
            bursts=diff(X)<10;
            StartInd=find(diff(bursts)==-1,1)+1;
            Start=X(StartInd)+1;
            if isempty(Start)
                newData=Data;
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\ACC\' filenames(indFile).name],newData)
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\EMG\' filenames(indFile).name(1:end-4) '_EMG'],EMG)
                continue
            end

            EndInd=find(diff(bursts(StartInd-1:end))==1);
            End=X(StartInd+EndInd)-1;
            if isempty(End)
                End=X(end);
            end

            newData=Data(Start*ClipOverlap*Cliplen:End*ClipOverlap*Cliplen,:);
            tStart=newData(1,1); tEnd=newData(end,1);
            newEMG=spline(EMG(:,1).',EMG(:,2:end).',tStart:1000/250:tEnd).';
            newData=newData(:,2:end);
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
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\ACC\' filenames(indFile).name],newData)
                csvwrite([dirname 'TrimmedData\' Set{indSet} '\EMG\' filenames(indFile).name(1:end-4) '_EMG'],EMG)
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
            tStart=newData(1,1); tEnd=newData(end,1);
            newEMG=spline(EMG(:,1).',EMG(:,2:end).',tStart:1000/250:tEnd).';
            newData=newData(:,2:end);
        end
        csvwrite([dirname 'TrimmedData\' Set{indSet} '\ACC\' filenames(indFile).name],newData)
        csvwrite([dirname 'TrimmedData\' Set{indSet} '\EMG\' filenames(indFile).name(1:end-4) '_EMG.csv'],newEMG)
    end
end
