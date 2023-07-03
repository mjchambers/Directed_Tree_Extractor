function [Connection, maxNumDaughters, maxNumParents]=connectivity(nodes, newNetwork)

numNodes=length(nodes);
Connection=zeros(numNodes,9); % Extra columns to make allowances for up to 4 daughters and 2 parents

for i=1:numNodes
    
    % Column 1 = nodeID
    Connection(i,1)=nodes(i,1);
    
    % Column 2 = out degree
    daughter_vessels=[];
    daughter_vessels_indices=find(newNetwork(:,2)==Connection(i,1)); % which vessels are daughters of current node?
    num_daughters=length(daughter_vessels_indices);
    for k=1:num_daughters
        daughter_vessels(k)= newNetwork(daughter_vessels_indices(k),1);
    end
    Connection(i,2)=num_daughters; % how many daughters?
    
    % Column 3 = in degree
    parent_vessels_indices=find(newNetwork(:,3)==Connection(i,1)); % which vessels are parents of current node?
    num_parents=length(parent_vessels_indices);
    for k=1:num_parents
        parent_vessels(k)= newNetwork(parent_vessels_indices(k),1);
    end
    Connection(i,3)=num_parents; % how many parents?
    
    % Column 4--Column 7 = daughters
    for j=1:num_daughters
        Connection(i,3+j)=daughter_vessels(j);
    end
    
    % Column 8--Column 9 = parents
    for k=1:num_parents
        Connection(i,7+k)=parent_vessels(k);
    end
end

maxNumDaughters=max(Connection(:,2));
maxNumParents=max(Connection(:,3));

% Remove unused columns
Connection( :, all(~Connection,1) ) = [];

end