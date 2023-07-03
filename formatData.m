% This program formats the text file outputs of the skeletonization
% algorithm into a way that's useful in Matlab.

% Inputs: 
% 1. 'data_file' is the filename of the text file containing the
%    degree/radius/data information of the graph
% 2. 'points_file' is the filename of the text file containing the nodes and
%    edges of the graph
% 3. 'dmap' is the filename of the distance map, a .nrrd file. This is how
%    we get the radii at points.

% Outputs:
% 1. 'arcs' is a [1 x n] cell structure. Each cell in arcs is a [m x 4]
%    matrix containing data for an individual edge in the network. The 
%    first row of the arcs matrix is [ node1 ID | node2 ID | 0 | 0 ]
%    (with the zeros just being placeholders). Subsequent rows in the arcs 
%    matrix are formatted as [ x | y | z | rad], containing the coordinates
%    of points along that edge and the vessel radius at those points.
% 2. 'nodes' is a [N x 5] matrix containing information about the
%    vertices (also called 'nodes') in the network. It is formatted as:
%    [node ID | x | y | z | degree of node].

% NOTE: This function calls the "nrrdread" function, a separate function
% designed to handle .nrrd files and obtainthe radius information.

function [arcs, nodes]=formatData(data_file,points_file, dmap)

% Read in data file and split into two cells
str=fileread(points_file);
str=regexprep(str,'graph G {\n0','0');
str=regexprep(str,'\n}','');
str=regexprep(str,'\n0--1  [','\nSPLIT HERE\n0--1  [');
str=strsplit(str,'\nSPLIT HERE\n');
nodes1=str{1,1};
arcs1=str{1,2};

% Reformat nodes string
nodes1=erase(nodes1,'[spatial_node="');
nodes1=erase(nodes1,'"];');
nodes1=textscan(nodes1,'%f %f %f %f');
nodes1=cell2mat(nodes1);
% matrix nodes1 contains [node ID|x|y|z]

% Read in data file and split into two cells
str2=fileread(data_file);
str2=regexprep(str2,'# degrees\n','');
str2=regexprep(str2,'\n# ete_distances','\nSPLIT HERE');
str2=strsplit(str2,'\nSPLIT HERE\n');
degrees=str2{1,1};
degrees=str2num(degrees)';
nodes1=[nodes1 degrees];
% Now, matrix nodes1 contains [node ID|x|y|z|degree]

% Reformat arcs string
arcs1=erase(arcs1,'"');
arcs1=regexprep(arcs1,'{','\n');
arcs1=erase(arcs1,["  [spatial_edge=[","}","]];",","]);
arcs1=regexprep(arcs1,'-| ',',');
arcs1=textscan(arcs1,'%f %f %f','Delimiter',',','MultipleDelimsAsOne',0,'EmptyValue',-Inf);
% cell structure arcs contains [node1 ID|-inf|node2 ID]
%                              [   x    |  y |    z   ]
%                              [   x    |  y |    z   ]
%                                          :
%                              [node1 ID|-inf|node2 ID]
%                              [   x    |  y |    z   ]
%                              [   x    |  y |    z   ]
%                                          :
% Find rows that are the start of a new arc
ind=find(arcs1{1,2}==-Inf);

% Split up arcs matrix into individual vessels
numArcs=length(ind);
arcs_mat=cell2mat(arcs1);
n=length(arcs_mat);
dim=[];
for i=1:numArcs-1
    diff=ind(i+1)-ind(i);
    dim=[dim;diff];
end
diff=n-ind(numArcs)+1;
dim=[dim;diff];
arcs=(mat2cell(arcs_mat,dim,3))';
% arcs is [1 X numArcs] cell array of 
% {--x3} {--x3} ...
%   |
% [node1 ID|-inf|node2 ID]
% [   x    |  y |    z   ] \ pts along vessel
% [   x    |  y |    z   ] /
%             :
%             :

% read in distance map
[X, ~] = nrrdread(dmap);

for i=1:numArcs
    node1=arcs{1,i}(1,1);  % node1 id
    arcs{1,i}(1,2)=arcs{1,i}(1,3);
    arcs{1,i}(1,3)=0;
    node2=arcs{1,i}(1,2);  % node2 id
    node1Ind=find(nodes1(:,1)==node1);   % which row in nodes has node1?
    node2Ind=find(nodes1(:,1)==node2);   % which row in nodes has node2?
    arcs{1,i}=[arcs{1,i};nodes1(node2Ind,2:4)]; %append node2 xyz at end of list of points
    [n,~]=size(arcs{1,i}); % n=how many points along this arc?
    arcs{1,i}=[arcs{1,i}(1,:);nodes1(node1Ind,2:4);arcs{1,i}(2:n,:)]; %insert node1 xyz beneath row 1
	arcs{1,i}=[arcs{1,i} zeros(n+1,1)];
    
    % For each xyz point on the arc, append the radius at that point in a
    % fourth column.
    for j=1:n
        x=arcs{1,i}(j+1,2)+1;
        y=arcs{1,i}(j+1,1)+1;
        z=arcs{1,i}(j+1,3)+1;
        rad=X(x,y,z);
        arcs{1,i}(j+1,4)=rad;
    end
end

% Now, arcs is [1 X numArcs] cell array of 
% {--x4} {--x4} ...
%   |
% [node1 ID|node2 ID|    0   |  0  ] --first row tells which nodes define edge (0's are just placeholders in first row)
% [node1_x |node1_y |node1_z | rad ]
% [   x    |    y   |    z   | rad ] \ 
% [   x    |    y   |    z   | rad ]  \
%                :                    pts along vessel
%                :                    /
% [   x    |    y   |    z   | rad ] /
% [node2_x |node2_y |node2_z | rad ]

% Now, in some of the vessels the edge points are in reversed order,
% meaning for an edga listed a--b [ (x1, y1, z1), (x2, y2, z2), ... , (xn,
% yn, zn) ], it may be true that a is connected to (xn, yn, zn), not (x1,
% y1, z1). For these, we need to reverse the edge points of the vessels.

for i=1:length(arcs)
    for j=3:size(arcs{1,i},1)
        coord1=arcs{1,i}(j-1, 1:3);
        coord2=arcs{1,i}(j, 1:3);
        diff=abs(coord2-coord1);
        if diff(1)>1 || diff(2)>1 || diff(3)>1
            A=flipud(arcs{1,i}(3:end-1, :));
            arcs{1,i}(3:end-1, :)=A;
        end
    end
end

% Some nodes have degree 0 as a result of skeletonization. We will
% eliminate these in the final nodes matrix
nodes=[];
for i=1:length(nodes1)
    if nodes1(i,5)~=0               % if degree of the node is not 0
        nodes=[nodes;nodes1(i,:)];  % add that row of info to nodes matrix
    end
end

end
