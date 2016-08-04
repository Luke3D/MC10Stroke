function RealConfMat = checkLab(x, ConfMat, num)

RealConfMat = [];
Labels = {'IA' 'SA' 'HA'};
c1 = []; c2 = [];
present = zeros(1,3);
N = length(ConfMat);
c = ConfMat;

for i = 1:length(x)
    present = present + strcmp(x(i), Labels);
end

missing = Labels(~present);

if N == num
    RealConfMat = ConfMat;
    return
elseif N ~= num && sum(present) == 3
    RealConfMat = [ConfMat [0;0]; 0 0 0];
    return
else
    n = length(c);
    
    if length(c) == num;
        RealConfMat = c;
        return
    else
        for i = 1:length(missing)
            switch missing{i}
                case 'SA'
                    c1(1,:) = zeros(1,n);
                    c1(2:n+1,:) = c;
                    
                    c2(:,1) = zeros(n+1,1);
                    c2(:,2:n+1) = c1(:,:);
                    
                    C = c2;
                    
                case 'HA'
                    c1(1,:) = c(1,:);
                    c1(2,:) = zeros(1,n);
                    c1(3:n+1,:) = c(2:end,:);
                    
                    c2(:,1) = c1(:,1);
                    c2(:,2) = zeros(1,n+1);
                    c2(:,3:n+1) = c1(:,2:end);
                    
                    C = c2;
                    
                case 'IA'
                    c1(1:2,:) = c(1:2,:);
                    c1(3,:) = zeros(1,n);
                    c1(4:n+1,:) = c(3:end,:);

                    c2(:,1:2) = c1(:,1:2);
                    c2(:,3) = zeros(n+1,1);
                    c2(:,4:n+1) = c1(:,3:end);

                    C = c2;
            end
            
            if length(C) == num
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

end