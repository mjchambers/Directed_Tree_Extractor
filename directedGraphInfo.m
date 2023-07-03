function [orientation, newNetwork, connection, maxNumDaughters, maxNumParents] = directedGraphInfo(arcs, nodes, path)

[orientation]=edge_orientation(arcs, path);
[newNetwork]=networkGenerator(arcs, orientation);
[connection, maxNumDaughters, maxNumParents]=connectivity(nodes, newNetwork);

end