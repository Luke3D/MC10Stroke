%Plot Acc and EMG from all tests
subjname = 'SCI002';
dirname = ['Z:\Stroke MC10\SCI\EMGtoLabel\' subjname];
plotacc = 1  %flag to plot acceleration in a separate plot
days=dir(dirname); days(1:2)=[];
dirname = [dirname '\' days.name '\'];
filenames = dir([dirname 'Shank\*.csv']);
selectedtest = {'MAS-KF'}%,'MAS-DF','MAS-PF','VCM-Knee','MVC-GA','MAS-KE','MAS-KF'};


for f = 1:length(filenames)
    shank = readtable([dirname 'Shank\' filenames(f).name]);
    thigh = readtable([dirname 'Thigh\' filenames(f).name]);
    
    Data = [cell2mat(table2cell(thigh)) cell2mat(table2cell(shank(:,2:end)))];
    Data = Data(:,[1:4 7:9 5:6 10:11]);
    ylabels = [thigh.Properties.VariableNames(end-1:end) shank.Properties.VariableNames(end-1:end)];
    
    if any(strcmp(filenames(f).name(1:end-4),selectedtest))
        figure('Name',fliplr(filenames(f).name(end-4:-1:1))), hold on
        subplot(511), plot(Data(:,1),Data(:,[2 5]))  %X-axis
        title(fliplr(filenames(f).name(end-4:-1:1)))
        
        for i = 1:4
            subplot(5,1,i+1), plot(Data(:,1),Data(:,i+7)), ylabel(ylabels{i})
            ylim([-2.5E-4 2.5E-4])
        end
        
        if plotacc
            figure, hold on
            subplot(211), plot(Data(:,1),Data(:,2)), ylabel('Acc [g]')
            subplot(212), hold on, plot(Data(:,1),Data(:,end-3)),  xlabel('Time [s]'), ylabel('EMG [V]')
        end
        
    end
    
    
end
