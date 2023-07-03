function [scaling_factor]=radius_scaling(arcs, root_nodeID)

cannula_radius_microns = 430;

for i=1:length(arcs)
    if arcs{1,i}(1,1)==root_nodeID || arcs{1,i}(1,2)==root_nodeID
        root_nodeID
        arcs{1,i}
        rows_to_use = input('Pick range of 5 rows which represent the voxels in the cannula: [row1 row2] = ');
        radii = arcs{1,i}(rows_to_use(1):rows_to_use(2),4);
        scalings = cannula_radius_microns./radii;
        scaling_factor = mean(scalings);
        
        break
    end
end
end