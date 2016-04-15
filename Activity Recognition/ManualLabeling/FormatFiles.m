% Prep data for labeling
% load EMG and ACC data

dirname='Z:\Stroke MC10\Activity Recognition\ToFormat\';

filenames=dir('Z:\Stroke MC10\Activity Recognition\ToFormat\CS*');

ndir=find([filenames.isdir]~=1);

filenames(ndir)=[];

for indFile=1:length(filenames) 
    % load acceleration data from hamstring (ham) and gastrocnemius (gas)
    ham=csvread([dirname filenames(indFile).name '\ham.csv'],1,0);
    gas=csvread([dirname filenames(indFile).name '\gas.csv'],1,0);
    
    ham(:,1)=(ham(:,1)-gas(1,1))/1000;
    gas(:,1)=(gas(:,1)-gas(1,1))/1000;
    
    t=0:.02:gas(end,1);
    test=spline(gas(:,1).',gas(:,2:end).',t).';
    ACC=[t.' test];
    test=spline(ham(:,1).',ham(:,2:end).',t).';
    ACC=[ACC test];
    
    csvwrite(['Z:\Stroke MC10\Activity Recognition\ToLabel\' filenames(indFile).name '.csv'],ACC)
end
    