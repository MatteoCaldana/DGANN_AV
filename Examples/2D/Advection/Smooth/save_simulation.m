Params = struct;
Params.model = model;
Params.name = test_name;
Params.N = N;
Params.msh_file = msh_file;
Params.bc = BC_cond;
Params.final_time = FinalTime;
Params.cfl = CFL;
Params.time_integrator = RK;
Params.viscosity_model = Visc_model;
Params.limiter = Limiter;

for var = ["c_E", "c_max", "c_A", "c_k"]
    if exist(var, 'var')
        Params.(var) = eval(var);
    end
end

for field = {'PShift', 'BFaces', 'GEBC_list', 'mapBC_list', 'PerBFToF_map', 'PerBToB_map', 'vmapBC_list'}
    f = field{1};
    Mesh.(f) = map_to_cell(Mesh.(f));
end

Mesh.M = Mesh.MassMatrix;

save(sprintf("test_%d.mat", floor(now*1e6)), "Params", "Mesh", "TSteps")
