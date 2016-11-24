function outputArray = matchArrays(shortArray, longArray,lineInterval)

    % This function makes the granularity between shortArray and longArray
    % equal.

    % i runs through the shortArray.
    % line saves the value of the last read line.
    
    line = lineInterval;
    
    outputArray = zeros(size(shortArray));
    
    for i=1:length(shortArray)
        if(line > length(longArray))
            break;
        end
        outputArray(i,:) = longArray(line,:);
        line = line+lineInterval;
    end

end