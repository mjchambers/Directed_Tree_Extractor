% This program creates the newNetwork style table for the new data.
% The (x,y,z) and rad data are contained in the 'arcs' cell structure.
% This outputs a matrix called "newNetworkArcs" with columns that contain
% [vessel ID|top node ID|bot node ID|vessel radius (median)|
function [newNetwork]=networkGenerator(arcs, orientation)

numVessels=length(arcs);

% Q = 'How do you want to calculate radius? Enter MED, AVG, IQM, TDM, or TIM. ';
% answer = input(Q,'s');

newNetwork=zeros(numVessels,6);
for i=1:numVessels
    % vessel ID
    newNetwork(i,1)=i; 
    A=arcs{1,i}; % A=xyz and rad data for current vessel
    [rn,~]=size(A); % rn=number of points along vessel
    numPoints=rn-1;
    
    % top and bottom node
    if orientation(i,1)==1
        newNetwork(i,2)=A(1,1);
        newNetwork(i,3)=A(1,2);
    else
        newNetwork(i,2)=A(1,2);
        newNetwork(i,3)=A(1,1);
    end

    % RADIUS   

    newNetwork(i,4)=IQM(A(2:end,4)); 

    % Vessel Length
    D=0;
    for si=2:numPoints
            x1=A(si,1); 
            y1=A(si,2);
            z1=A(si,3);
            x2=A(si+1,1);
            y2=A(si+1,2); 
            z2=A(si+1,3);
            ds=sqrt((x1-x2)^2+(y1-y2)^2+(z1-z2)^2);
            D = D + ds;
    end
    newNetwork(i,5)=D; 
    
    % std deviation
    newNetwork(i,6)=std(A(:,4));
    
end
end