%% Analyze Delsys and MC10

Acc_M=spline(MC10(:,1).',MC10(:,2:4).',0:1/150:MC10(end,1)).';
Acc_D=spline(DelAcc(:,1).',DelAcc(:,2:4).',0:1/150:DelAcc(end,1)).';

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

%% R-squared of acceleration norm

Norm_M=sum(Acc_M.^2,2).^.5;
Norm_D=sum(Acc_D.^2,2).^.5;

constant=ones(length(Norm_M),1);

[~,~,~,~,stat]=regress(Norm_M,[constant Norm_D]);

r=stat(1);