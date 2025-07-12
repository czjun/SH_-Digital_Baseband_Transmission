function output=sample_AY(input,period)
    output=(length(input)/period);   
     for i=period:period:length(input)   %设置间隔来取出抽样值；
        output(i/period)=input(i);
     end
end