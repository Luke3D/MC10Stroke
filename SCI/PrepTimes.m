%% Save .mat file with table containing MC10 activities information
% Copy section form annotation csv with StartTime(utc) EndTime(utc) and
% Copy Labels into Times table before running

%% Extracts timestamps for each test and saves them into Times
Subj='CS001';
Day='1';

QuestionInd=cellfun(@(x) strcmp(x(1:9),'ActivityQ'),Times.Label);
Times(QuestionInd,:)=[];


TenMWT={'SS1','SS2','FS1','FS2'};
Tug={'1','2','3'};
DynStand={'1','2','3'};

indTen=1;
indTug=1;
indDS=1;

for i=1:height(Times)
    Times.Label{i}=Times.Label{i}(10:end);
    if strcmp(Times.Label{i}(1),'V')
        Times.Label{i}=['VCM ' Times.Label{i}(end-1:end)];
    elseif strcmp(Times.Label{i}(1),'P')
        Times.Label{i}=['PM ' Times.Label{i}(end-1:end)];
    elseif strcmp(Times.Label{i}(1:2), 'MV')
        Times.Label{i}=['MVC ' Times.Label{i}(end-1:end)];
    elseif strcmp(Times.Label{i}(1:2),'10')
        Times.Label{i}=[Times.Label{i} '_' TenMWT{indTen}];
        if indTen<length(TenMWT)
            indTen=indTen+1;
        end
    elseif strcmp(Times.Label{i}(1:3),'TUG')
        Times.Label{i}=[Times.Label{i} '_' Tug{indTug}];
        if indTug<length(Tug)
            indTug=indTug+1;
        end
    elseif strcmp(Times.Label{i}(1:3),'Dyn')
        Times.Label{i}=[Times.Label{i} '_' DynStand{indDS}];
        if indDS<length(DynStand)
            indDS=indDS+1;
        end
    end
end


%% Save Times File as .mat and create folder for each sensors
if ~exist(['Z:\Stroke MC10\SCI\' Subj], 'dir')
    mkdir(['Z:\Stroke MC10\SCI\' Subj])
end
if ~exist(['Z:\Stroke MC10\SCI\' Subj '\Lab Day ' Day], 'dir')
    mkdir(['Z:\Stroke MC10\SCI\' Subj '\Lab Day ' Day])
    mkdir(['Z:\Stroke MC10\SCI\' Subj '\Lab Day ' Day '\RF']) %Rectus Femoris
    mkdir(['Z:\Stroke MC10\SCI\' Subj '\Lab Day ' Day '\PT']) %Posterior Thigh (Hamstring)
    mkdir(['Z:\Stroke MC10\SCI\' Subj '\Lab Day ' Day '\TA']) %Tibilias Anterior 
    mkdir(['Z:\Stroke MC10\SCI\' Subj '\Lab Day ' Day '\GA']) %Gastrocnemius
    mkdir(['Z:\Stroke MC10\SCI\' Subj '\Lab Day ' Day '\Foot'])
    mkdir(['Z:\Stroke MC10\SCI\' Subj '\Lab Day ' Day '\Heel'])
end

save(['Z:\Stroke MC10\SCI\' Subj '\Lab Day ' Day '\' Subj '_Day' Day '_Times.mat'],'Times')