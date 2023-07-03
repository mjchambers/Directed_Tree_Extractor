% This function properly formats arcs and nodes data to work in the
% dijkstra algorithm. 

function [path]=useDijkstra(arcs, nodes, root_node)

numVessels=length(arcs);
segments=zeros(numVessels,3);
for i=1:numVessels
    segments(i,1)=i;
    segments(i,2)=arcs{1,i}(1,1);
    segments(i,3)=arcs{1,i}(1,2);
end

nodes_first4cols=nodes(:,1:4);

% Run Dijkstra. Info on dijkstra algorithm included in the code comments of the function.
[~,path]=dijkstra(nodes_first4cols,segments,root_node);

end