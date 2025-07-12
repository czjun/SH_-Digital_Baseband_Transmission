function output=filterDeal(input,hn)
    L=length(hn);
    output=conv(input,hn);
    for j=1:(L-1)/2
        output(:,1)=[];
    end
    for i=1:(L-1)/2
        output(:,length(input)+1)=[];
    end
end