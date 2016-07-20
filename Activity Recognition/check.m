function RealConfMat = check(x, ConfMat)
%--------------------------------------------------------------------------
% Function CHECK performs a series of switch cases in order to determine
% which labels are missing from X. The values in the original
% confusion matrix CONFMAT are then redistributed into the final confusion
% matrix REALCONFMAT, a 6x6 confusion matrix representative of all the
% original 6 activity labels.
%--------------------------------------------------------------------------
Activities={'Lying' 'Sitting' 'Standing' 'Stairs Down' 'Stairs Up' 'Walking'};
RealConfMat = [];

N = length(ConfMat);
c1 = []; c2 = [];
present = zeros(1,6);

for i = 1:length(x)
    present = present + strcmp(x(i), Activities);
end

missing = Activities(~present);
c = ConfMat;

if N == 6
    RealConfMat = ConfMat;
    return
else
    for i = 1:length(missing)
        n = length(c);
        
        if length(c) == 6
            RealConfMat = C;
            return
        end
        
        switch missing{i}
            case 'Lying'
                c1(1,:) = zeros(1,n);
                c1(2:n+1,:) = c;
                
                c2(:,1) = zeros(n+1,1);
                c2(:,2:n+1) = c1(:,:);
                
                C = c2;
                
                
            case 'Sitting'
                c1(1,:) = c(1,:);
                c1(2,:) = zeros(1,n);
                c1(3:n+1,:) = c(2:end,:);

                c2(:,1) = c1(:,1);
                c2(:,2) = zeros(n+1,1);
                c2(:,3:n+1) = c1(:,2:end);
                
                C = c2;
                
                
            case 'Standing'
                c1(1:2,:) = c(1:2,:);
                c1(3,:) = zeros(1,n);
                c1(4:n+1,:) = c(3:end,:);

                c2(:,1:2) = c1(:,1:2);
                c2(:,3) = zeros(n+1,1);
                c2(:,4:n+1) = c1(:,3:end);
                
                C = c2;
                
                
            case 'Stairs Down'
                c1(1:3,:) = c(1:3,:);
                c1(4,:) = zeros(1,n);
                c1(5:n+1,:) = c(4:end,:);

                c2(:,1:3) = c1(:,1:3);
                c2(:,4) = zeros(n+1,1);
                c2(:,5:n+1) = c1(:,4:end);
                
                C = c2;
                
                
            case 'Stairs Up'
                c1(1:4,:) = c(1:4,:);
                c1(5,:) = zeros(1,n);
                c1(6,:) = c(5,:);

                c2(:,1:4) = c1(:,1:4);
                c2(:,5) = zeros(n+1,1);
                c2(:,6) = c1(:,5:end);
                
                C = c2;
                
                
            case 'Walking'
                c1(1,:) = zeros(1,n);
                c1(2:end,:) = c(:,:);
                
                c2(:,1) = zeros(n,1);
                c2(:,2:end) = c1(:,:);
                
                C = c2;
                
                
        end
        
        if length(C) == 6
            RealConfMat = C;
            return
        else
            c = C;
            c1 = []; c2 = [];
        end
    end
    
    RealConfMat = C;
    c1 = []; c2 = []; C = [];

   
end
    
end