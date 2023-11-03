% Create BC_flag
CreateBC_Flags2D;

% Check parameters
ScalarCheckParam2D;


% Display paramaters
ScalarStartDisp2D;

% Initialize solver and construct grid and metric
[Mesh.VX,Mesh.VY,Mesh.K,Mesh.Nv,Mesh.EToV,Mesh.BFaces,Mesh.PerBToB_map,Mesh.PerBFToF_map] ...
                                          = read_gmsh_file(Mesh.msh_file);

[Mesh.VX,Mesh.VY,Mesh.K,Mesh.Nv,Mesh.EToV,Mesh.BFaces,Mesh.PerBToB_map,Mesh.PerBFToF_map] = ...
    make_gmsh([min(Mesh.VX), min(Mesh.VY)], [max(Mesh.VX), max(Mesh.VY)], [1, 1] * sqrt(Mesh.Nv));

% for i = 1:4
%     ex = abs(Mesh.VX(Mesh.BFaces(100000+i)) - VX2(BFaces2(100000+i)));
%     ey = abs(Mesh.VY(Mesh.BFaces(100000+i)) - VY2(BFaces2(100000+i)));
%     fprintf("%d - %e %e\n", i, max(max(ex)), max(max(ey)))
% end
% 
% for i = 2:3
%     eB = Mesh.PerBToB_map(100000+i) - PerBToB_map2(100000+i) ;
%     eF = Mesh.PerBFToF_map(100000+i) - PerBFToF_map2(100000+i) ;
%     fprintf("%d - %e %e\n", i, max(eB), max(eF))
% end
% Generate necessary data structures
StartUp2D;

% Get essential BC_flags
Mesh.BC_ess_flags = BuildBCKeys2D(Mesh.BC_flags,Mesh.BC_ENUM.Periodic);

BuildBCMaps2D;

%% compute initial condition (time=0)
Q = feval(Problem.InitialCond, Mesh.x, Mesh.y);
    
% Find relative path
Find_relative_path;
    
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
Create_sfile_base2D;
    
% Solve Problem
fprintf('... starting main solve\n')

tic;
[TSteps,ind_save,visc_save,ptc_hist,maxvisc_hist,t_hist,Save_times] = Scalar2D(Q,Problem,Mesh,Limit,Net,Viscosity,NetVisc,Output);
sim_time = toc;
    
%%
% Saving data
if(Output.save_soln)
   Scalar_Save2D;
end
    
% Clean up processes
fprintf('... cleaning up\n')
CleanUp2D;

fprintf('------------ Solver has finished -------------\n')

