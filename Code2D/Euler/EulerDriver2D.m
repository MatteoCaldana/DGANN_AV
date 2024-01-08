% Create BC_flag
BC_flags = CreateBC_Flags2D(BC_cond);

% Check parameters
EulerCheckParam2D;

% Display paramaters
EulerStartDisp2D;

% Initialize solver and construct grid and metric
[Mesh.VX,Mesh.VY,Mesh.K,Mesh.Nv,Mesh.EToV,Mesh.BFaces,Mesh.PerBToB_map,Mesh.PerBFToF_map] ...
                                          = read_gmsh_file(Mesh.msh_file);


% Generate necessary data structures
StartUp2D;

% Get essential BC_flags
Mesh.BC_ess_flags = BuildBCKeys2D(Mesh.BC_flags,Mesh.BC_ENUM.Periodic);

Mesh = BuildBCMaps2D(Mesh);

%% compute initial condition (time=0)
Q = feval(Problem.InitialCond, Mesh.x, Mesh.y, Problem.gas_gamma, Problem.gas_const);
    
% Find relative path
REL_PATH = Find_relative_path();
    
% Extract MLP weights, biases and other parameters
if(strcmp(Limit.Indicator,'NN'))
    Net = read_mlp_param2D(Limit.nn_model,REL_PATH);
else
    Net.avail = false;
end

%Repeat for viscosity
if(strcmp(Viscosity.model,'NN'))
    NetVisc = read_mlp_param2D_visc(Viscosity.nn_visc_model,REL_PATH,Mesh.N);
else
    NetVisc.avail = false;
end
    
% Creating save file base names
data_fname = Create_sfile_base2D(Problem, Limit, Viscosity);
    
%% Solve Problem
fprintf('... starting main solve\n')
tic
[Q_save,ind_save,visc_save,ptc_hist,pnc_hist,maxvisc_hist,t_hist,Save_times] = Euler2D(Q,Problem,Mesh,Limit,Net,Viscosity,NetVisc,Output);
sim_time = toc;
    
%% Saving data
if(Output.save_soln)
    Euler_Save2D(Mesh, Save_times,Q_save,ind_save,visc_save,ptc_hist,pnc_hist,maxvisc_hist,t_hist,sim_time,gas_gamma,gas_const, data_fname);
end
    
% Clean up processes
fprintf('... cleaning up\n')
CleanUp2D();

fprintf('------------ Solver has finished -------------\n')


