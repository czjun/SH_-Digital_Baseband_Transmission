function y=makingData(type,Length)
    a = 2*rand(1,Length)-1;
    y=(Length);
    if type==1      %生成0 1比特流（均匀分布）
        for i=1:Length
            if a(i)>0
                y(i) = 1;
            else
                y(i) = 0;
            end
        end
    elseif type==2      %生成1 -1数据流
        for i=1:Length
            if a(i)>0
                y(i) = 1;
            else
                y(i) = -1;
            end
        end
    end
        
end