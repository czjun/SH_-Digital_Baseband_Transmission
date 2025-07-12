function output=judgeCode(type,input)  
output=(length(input));  
if type == 1  
    for i=1:length(input)  
        if input(i)>0.5  
            output(i)=1;  
        elseif input(i)<-0.5  
            output(i)=-1;  
        else  
            output(i)=0;  
        end  
    end  
elseif type == 2  
    for i=1:length(input)  
        if input(i)>0  
            output(i)=1;  
        else  
            output(i)=-1;  
        end  
    end  
end  
end  