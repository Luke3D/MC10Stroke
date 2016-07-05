% EMG Plotting
load('EMGData.mat')
filenames = [];
location = {'Gastrocnemius' 'Hamstring'};
emg = [];   lab = [];

subject{1}=([1:20 23:29])'; % Gastrocnemius index
subject{2}=([1:15])'; % Hamstring index

%--------------------------------------------------------------------------
% Data Extraction
%--------------------------------------------------------------------------
for x = 1:length(location)
    filenames = [];
    sub = num2str(subject{x});

    for i=1:size(sub,1)
        if strcmp(sub(i,1),' ')
            sub(i,1)='0';
        end
    end

    for i=1:size(sub,1)
        filenames=[filenames; rdir(['Z:\Stroke MC10\Clips\' sub(i,:) '\**\' location{x} '*MVC' '*F_Clips.mat'])];

        len(i) = length(filenames);
    end

    for i=1:size(sub,1)
        if i == 1
            for j = 1:len(1);
                temp = load(filenames(j).name);
                temp = temp.AllClips;
                emg = [emg; cell2mat({temp(:).Emg})'];
                lab = [lab; {temp(:).ActivityLabel}'];
            end

            if strcmp(location{x}, 'Gastrocnemius')
                emgData(i).gEMG = emg;
                emgData(i).gLabel = lab;
            else
                emgData(i).hEMG = emg;
                emgData(i).hLabel = lab;
            end

            emg = [];
            lab = [];
        else
            for j = len(i-1) + 1 : len(i)
                temp = load(filenames(j).name);
                temp = temp.AllClips;
                emg = [emg; cell2mat({temp(:).Emg})'];
                lab = [lab; {temp(:).ActivityLabel}'];
            end

            if strcmp(location{x}, 'Gastrocnemius')
                emgData(i).gEMG = emg;
                emgData(i).gLabel = lab;
            else
                emgData(i).hEMG = emg;
                emgData(i).hLabel = lab;
            end

            emg = [];
            lab = [];
        end

        emg = [];
        lab = [];
        temp = [];
    end
end

%--------------------------------------------------------------------------
% RMS, Power, and SNR Calculations
%--------------------------------------------------------------------------
temp = [];
Power_IA_g = []; Power_HA_g = [];
Power_IA_h = []; Power_HA_h = [];
rms_IA_g = []; rms_HA_g = [];
rms_IA_h = []; rms_HA_h = [];
n_IA = 1; n_HA = 1;

for x = 1:length(location)
    sub = subject{x};
    
    for i = 1:size(sub,1)
        if strcmp(location{x}, 'Gastrocnemius')
            tempDat = emgData(i).gEMG;
            tempLab = emgData(i).gLabel;
            
            N = size(tempDat,2);
            
            for j = 1:size(tempDat,1)
                label = char(tempLab(j));
                if strcmp(label, 'IA')
                    tempVal = sum(tempDat(j,:).^2) / N;
                    Power_IA_g(n_IA) = tempVal;
                    rms_IA_g(n_IA) = sqrt(tempVal);
                    n_IA = n_IA + 1;
                else
                    tempVal = sum(tempDat(j,:).^2) / N;
                    Power_HA_g(n_HA) = tempVal;
                    rms_HA_g(n_HA) = sqrt(tempVal);
                    n_HA = n_HA + 1;
                end
            end
        else
            tempDat = emgData(i).hEMG;
            tempLab = emgData(i).hLabel;
            
            N = size(tempDat,2);
            
            for j = 1:size(tempDat,1)
                label = char(tempLab(j));
                if strcmp(label, 'IA')
                    tempVal = sum(tempDat(j,:).^2) / N;
                    Power_IA_h(n_IA) = tempVal;
                    rms_IA_h(n_IA) = sqrt(tempVal);
                    n_IA = n_IA + 1;
                else
                    tempVal = sum(tempDat(j,:).^2) / N;
                    Power_HA_h(n_HA) = tempVal;
                    rms_HA_h(n_HA) = sqrt(tempVal);
                    n_HA = n_HA + 1;
                end
            end
        end
        
        if isempty(Power_IA_g)
            Power_IA_g = 0;
            rms_IA_g = 0;
        end
        if isempty(Power_HA_g)
            Power_HA_g = 0;
            rms_HA_g = 0;
        end
        
        if isempty(Power_IA_h)
            Power_IA_h = 0;
            rms_IA_h = 0;
        end
        if isempty(Power_HA_h)
            Power_HA_h = 0;
            rms_HA_h = 0;
        end
        
        if strcmp(location{x}, 'Gastrocnemius')
            POWER_IA_G(i) = mean(Power_IA_g);
            POWER_HA_G(i) = mean(Power_HA_g);
            RMS_IA_G(i) = mean(rms_IA_g);
            RMS_HA_G(i) = mean(rms_HA_g);

            Power_IA_g = []; Power_HA_g = [];
            rms_IA_g = []; rms_HA_g = [];
            n_IA = 1; n_HA = 1;
        else
            POWER_IA_H(i) = mean(Power_IA_h);
            POWER_HA_H(i) = mean(Power_HA_h);
            RMS_IA_H(i) = mean(rms_IA_h);
            RMS_HA_H(i) = mean(rms_HA_h);

            Power_IA_h = []; Power_HA_h = [];
            rms_IA_h = []; rms_HA_h = [];
            n_IA = 1; n_HA = 1;
        end
    end
end

index1 = RMS_IA_G==0;             index2 = RMS_HA_G==0;
index = index1 + index2;
RMS_IA_G = RMS_IA_G(~index);    RMS_HA_G = RMS_HA_G(~index);

index1 = RMS_IA_H==0;             index2 = RMS_HA_H==0;
index = index1 + index2;
RMS_IA_H = RMS_IA_H(~index);    RMS_HA_H = RMS_HA_H(~index);


SNR_G = 20*log10(RMS_HA_G ./ RMS_IA_G);
SNR_H = 20*log10(RMS_HA_H ./ RMS_IA_H);

figure
subplot(2,1,1)
histogram(SNR_G, length(SNR_G))
xlabel('SNR')
ylabel('Number of Subjects')
title('Histogram of Gastrocnemius SNR')

subplot(2,1,2)
histogram(SNR_H, length(SNR_H))
xlabel('SNR')
ylabel('Number of Subjects')
title('Histogram of Hamstring SNR')