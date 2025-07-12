function output=extrudeMultiples(input,multiples)
    output=zeros(1,length(input)*multiples);
    for i=multiples:multiples:length(input)*multiples
        output(i)=input(i/multiples);
    end
end