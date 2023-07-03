
% This function plots arcs and nodes data from the formatData program. The
% data is plotted in a 3D point cloud with node IDs labeled. Examining this
% plot alongside the image in 3D slicer helps identify the root node. Also,
% nodes of degree 4 re labeled in red because those are where possible
% loops/trifurcations occur, so they are of interest.

% Inputs:
% 1. arcs, output from formatData script
% 2. nodes, output from formatData script

% Output:
% Figure--3D plot of point cloud

function []=plotSlicerData(arcs, nodes)

% Create vectors (x, y, z) of point coordinates to plot
x=[];
y=[];
z=[];
NumVessels=length(arcs);
for i=1:NumVessels
    [numPoints,~]=size(arcs{1,i});
    newX=arcs{1,i}(2:numPoints,1);
    newY=arcs{1,i}(2:numPoints,2);
    newZ=arcs{1,i}(2:numPoints,3);
    x=[x;newX];
    y=[y;newY];
    z=[z;newZ];
end

% Create vector of node ID labels
label=num2str(nodes(:,1));
xN=nodes(:,2);
yN=nodes(:,3);
zN=nodes(:,4);

C=zeros(length(z), 3);
minZ=min(z);
maxZ=max(z);
zRange=maxZ-minZ;

for i=1:length(z)
    C(i, 3) = (z(i)-minZ)/zRange;
    C(i, 2) = 1 - C(i, 3);
end

% Plot data, labeling nodes
figure(100)
hold on
scatter3(x,y,z,500,[0.46, 0.84, 1],'.');
t=text(xN,yN,zN,label,'FontSize',10);
for i=1:size(nodes, 1)
    t(i).Color = 'black';
    t(i).FontSize = 18;
    if nodes(i, 1) == 1037
        t(i).Color = 'red';
        t(i).FontSize = 24;
    end
end
hold off

figure(101)
hold on
scatter3(x,y,z,100,'k', '.');
scatter3(xN,yN,zN,1000,'r', '.');
view(0,0)

hold off
end