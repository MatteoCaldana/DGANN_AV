
for field = {'PShift', 'BFaces', 'GEBC_list', 'mapBC_list', 'PerBFToF_map', 'PerBToB_map', 'vmapBC_list'}
    f = field{1};
    Mesh.(f) = map_to_cell(Mesh.(f));
end

Mesh.M = Mesh.MassMatrix;

save(sprintf("mesh_square_trans_K%d_N%d", KK(iii), N), "Mesh", "N", "msh_file", "BC_cond");