% Segment orientation program
function [orientation]=edge_orientation(arcs, path)

numVessels=length(arcs);
pathLength=length(path);
orientation=zeros(numVessels, 1);

for i=1:numVessels
    firstNode=arcs{1,i}(1,1);
    secondNode=arcs{1,i}(1,2);
    
    % Find the cell in path that ends with our secondNode
    for j=1:pathLength
        n=length(path{1,j});
        if path{1,j}(1,n)==secondNode
            break
        end
    end
    
    % Determine orientation
    if n>1 && path{1,j}(1,n-1)==firstNode
        orientation(i,1)=1; % node order is correct
    else
        orientation(i,1)=-1; % node order should be switched
    end
    
end

end