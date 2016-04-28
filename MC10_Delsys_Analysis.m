%% Analyze Delsys and MC10
num=4;
MC10=MCData{num};
DelAcc=DelData{num};

Acc_M=spline(MC10(:,1).',MC10(:,2:4).',0:1/50:MC10(end,1)).';
Acc_D=spline(DelAcc(:,1).',DelAcc(:,2:4).',0:1/50:DelAcc(end,1)).';

% Use xcorr to find lag between signals
x=zeros(3,1);
X=cell(1,3);
L=cell(1,3);

for i=1:3
    [A,B]=xcorr(Acc_M(:,i),Acc_D(:,i));
    X{i}=A; L{i}=B;
    [~,I]=max(abs(X{i}));
    x(i)=L{i}(I);
end

figure; hold on;
for i=1:3
    subplot(3,1,i)
    plot(L{i},X{i})
end

%% Align Signals

lag=1041;

if lag>0
    Acc_M=Acc_M(lag+1:end,:);
    if length(Acc_D)>length(Acc_M)
        Acc_D=Acc_D(1:length(Acc_M),:);
    else
        Acc_M=Acc_M(1:length(Acc_D),:);
    end
else
    Acc_D=Acc_D(lag+1:end,:);
    if length(Acc_D)>length(Acc_M)
        Acc_M=Acc_M(1:length(Acc_D),:);
    else
        Acc_D=Acc_D(1:length(Acc_M),:);
    end
end


%% R-squared of acceleration norm

Norm_M=sum(Acc_M.^2,2).^.5;
Norm_D=sum(Acc_D.^2,2).^.5;

% indz=find(Norm_D<.25);
% Norm_M(indz)=[];
% Norm_D(indz)=[];

constant=ones(length(Norm_M),1);

[b,~,~,~,stat]=regress(Norm_M,[constant Norm_D]);

r=stat(1);

xfit=0:.05:5;

yfit=b(2)*xfit+b(1);

figure; hold on
scatter(Norm_D, Norm_M); plot(xfit,yfit)

%% R-squared of axes

for i=1:3

    M=Acc_M(:,i);
    D=Acc_D(:,i);

    % indz=find(Norm_D<.25);
    % Norm_M(indz)=[];
    % Norm_D(indz)=[];

    constant=ones(length(M),1);

    [b,~,~,~,stat]=regress(M,[constant D]);

    ra(i)=stat(1);

    xfit=min(D):.05:max(D);

    yfit=b(2)*xfit+b(1);

    figure; hold on
    scatter(D, M); plot(xfit,yfit)
end

%%
for i=1:4
    
    M=CS1{(i-1)*2+1};
    D=CS1{i*2};
    
    if i==1
        indz1=find(D<.25);
    end
    
    M(indz1)=[];
    D(indz1)=[];
    
    constant=ones(length(M),1);

    [b,~,~,~,stat]=regress(M,[constant D]);

    ra1(i)=stat(1);

    xfit=min(D):.05:max(D);

    yfit=b(2)*xfit+b(1);

    figure; hold on
    scatter(D, M); plot(xfit,yfit)
    
    M=CS2{(i-1)*2+1};
    D=CS2{i*2};
    
    if i==1
        indz2=find(D<.25);
    end
    
    M(indz2)=[];
    D(indz2)=[];
    
    constant=ones(length(M),1);

    [b,~,~,~,stat]=regress(M,[constant D]);

    ra2(i)=stat(1);

    xfit=min(D):.05:max(D);

    yfit=b(2)*xfit+b(1);

    scatter(D, M); plot(xfit,yfit)
    
end
