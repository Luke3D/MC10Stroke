%% Viusualize Labeled Data
colors = {'g','r','y','k'};
Labels={'Non-Spastic Activity', 'Spastic Activity', 'Inactive', 'Misc'};

[filename,pathname] = uigetfile('Z:\Stroke MC10\LabeledData\*.csv');

Data=table2cell(readtable([pathname filename]));

figure; hold on

for indLab=1:length(Labels)
    inds=strcmp(Labels{indLab},Data(:,end-1));
    labelData=cell2mat(Data(inds,[1 5]));
    if isempty(labelData)
        continue
    end
    sepInds=[0; find(round(diff(labelData(:,1)*10000))~=40)];
    for i=1:length(sepInds)
        if isempty(sepInds)
            temp=LabelData; 
        elseif i==length(sepInds)
            temp=labelData(sepInds(i)+1:end,:);
        else
            temp=labelData(sepInds(i)+1:sepInds(i+1),:);
        end
        plot(temp(:,1),temp(:,2),colors{indLab});     
    end
end
