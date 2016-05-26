%% Save .mat file with table containing MC10 activities information
% Copy section form annotation csv with StartTime(utc) EndTime(utc) and
% Label into Times variable before running

Subj='CS029';
Day='2';

QuestionInd=cellfun(@(x) strcmp(x(1:9),'ActivityQ'),Times.Label);
Times(QuestionInd,:)=[];


TenMWT={'SS1','SS2','SS3','FS1','FS2','FS3'};
indTen=1;

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
    end
end



%% Save Times File as .mat
if ~exist(['Z:\Stroke MC10\' Subj], 'dir')
    mkdir(['Z:\Stroke MC10\' Subj])
end
if ~exist(['Z:\Stroke MC10\' Subj '\Lab Day ' Day], 'dir')
    mkdir(['Z:\Stroke MC10\' Subj '\Lab Day ' Day])
    mkdir(['Z:\Stroke MC10\' Subj '\Lab Day ' Day '\Gastrocnemius'])
    mkdir(['Z:\Stroke MC10\' Subj '\Lab Day ' Day 'Hamstring'])
end

save(['Z:\Stroke MC10\' Subj '\Lab Day ' Day '\' Subj '_Day' Day '_Times.mat'],'Times')