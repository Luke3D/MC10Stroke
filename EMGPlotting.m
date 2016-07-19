% EMG Plotting
filenames = []; processedFiles = []; len = [];
emg = []; lab = [];
location = {'Gastrocnemius' 'Hamstring'};
dirname = 'Z:\Stroke MC10\LabeledData\CS0';

subject{1}=([1:20 23:29])'; % Gastrocnemius index
subject{2}=([1:15])'; % Hamstring index

%--------------------------------------------------------------------------
% Data Extraction
%--------------------------------------------------------------------------
for x = 1:length(location)
    filenames = []; processedFiles = []; len = [];
    sub = num2str(subject{x});
    
    for i=1:size(sub,1)
        if strcmp(sub(i,1),' ')
            sub(i,1)='0';
        end
    end
    
    for i=1:size(sub,1)
        filenames=[filenames; rdir([dirname sub(i,:) '\**\' location{x} '*MVC' '*.csv'])];
        
        len(i) = length(filenames);
    end
    
    for i=1:length(filenames)
        [num, text, ~] = xlsread(filenames(i).name);
        index = strcmp(text(:,1), 'Not labeled');
        num = num(~index,5);
        text = text(~index);
        
        processedFiles(i).emg = num;
        processedFiles(i).lab = text;
    end
    
    for i = 1:size(sub,1)
        if i == 1
            for j = 1:len(1)
                emg = [emg; processedFiles(j).emg];
                lab = [lab; processedFiles(j).lab];
            end
            
            if strcmp(location{x}, 'Gastrocnemius')
                gEMG(i).emg = emg;
                gEMG(i).lab = lab;
            else
                hEMG(i).emg = emg;
                hEMG(i).lab = lab;
            end
            
            emg = [];
            lab = [];
        else
            for j = len(i-1)+1:len(i);
                emg = [emg; processedFiles(j).emg];
                lab = [lab; processedFiles(j).lab];
            end
            
            if strcmp(location{x}, 'Gastrocnemius')
                gEMG(i).emg = emg;
                gEMG(i).lab = lab;
            else
                hEMG(i).emg = emg;
                hEMG(i).lab = lab;
            end
            
            emg = [];
            lab = [];
        end
    end
    
    index = [];
    for i=1:size(sub,1)
        if strcmp(location{x}, 'Gastrocnemius')
            tempDat = gEMG(i).emg;
            tempLab = gEMG(i).lab;
            
            index = strcmp(tempLab, 'Inactive');
            gIA(i).emg = tempDat(index);
            gIA(i).lab = tempLab(index);
            gHA(i).emg = tempDat(~index);
            gHA(i).lab = tempLab(~index);
        else
            tempDat = hEMG(i).emg;
            tempLab = hEMG(i).lab;
            
            index = strcmp(tempLab, 'Inactive');
            hIA(i).emg = tempDat(index);
            hIA(i).lab = tempLab(index);
            hHA(i).emg = tempDat(~index);
            hHA(i).lab = tempLab(~index);
        end
    end
    
    if strcmp(location{x}, 'Gastrocnemius')
        for i = 1:size(sub,1)
            N1 = size(gHA(i).emg,1);
            N2 = size(gIA(i).emg,1);
            
            valTemp1 = sum((gHA(i).emg .^ 2)) / N1;
            gHA_Power(i) = valTemp1;
            gHA_RMS(i) = sqrt(valTemp1);
            
            valTemp2 = sum((gIA(i).emg .^ 2)) / N2;
            gIA_Power(i) = valTemp2;
            gIA_RMS(i) = sqrt(valTemp2);
        end
        N1 = 0; N2 = 0; valTemp1 = 0; valTemp2 = 0;
        
        gSNR = 20*log10(gHA_RMS ./ gIA_RMS);
        gSNR = gSNR(~isnan(gSNR));
        
    else
        for i=1:size(sub,1)
            N1 = size(hHA(i).emg,1);
            N2 = size(hIA(i).emg,1);
            
            valTemp1 = sum((hHA(i).emg .^ 2)) / N1;
            hHA_Power(i) = valTemp1;
            hHA_RMS(i) = sqrt(valTemp1);
            
            valTemp2 = sum((hIA(i).emg .^ 2)) / N2;
            hIA_Power(i) = valTemp2;
            hIA_RMS(i) = sqrt(valTemp2);
        end
        N1 = 0; N2 = 0; valTemp1 = 0; valTemp2 = 0;
        
        hSNR = 20*log10(hHA_RMS ./ hIA_RMS);
        hSNR = hSNR(~isnan(hSNR));
    end
end

figure
subplot(2,1,1)
histogram(gSNR, length(gSNR))
xlabel('SNR [dB]')
ylabel('Number of Subjects')
title('Gastrocnemius SNR Distribution')

subplot(2,1,2)
histogram(hSNR, length(hSNR))
xlabel('SNR [dB]')
ylabel('Number of Subjects')
title('Hamstring SNR Distribution')
