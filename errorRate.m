function output=errorRate(intput,sample)
    ER=0;
    for j=1:length(intput)
        if intput(j)~=sample(j)
            ER=ER+1;
        end
    end
    output=ER/length(sample);                %计算误码率
end