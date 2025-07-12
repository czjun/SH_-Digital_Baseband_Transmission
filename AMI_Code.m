function output=AMI_Code(type,input)
    output=zeros(1,length(input));
    if type == 1
        cout=1;
        for i=1:length(input)  %转换成AMI码
            if input(i)==1
                output(i)=cout;   
                cout=-cout; 
            else
                output(i)=0;
            end
        end
    elseif type == 2
        output = input;
    end
end