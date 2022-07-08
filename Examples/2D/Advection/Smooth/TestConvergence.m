close all
clear
clc

model             = 'Advection';
AdvectionVelocity = [1,1];
test_name         = 'Smooth';
InitialCond       = @IC;
BC_cond           = {100001,'P'; 100002,'P'; 100003,'P'; 100004,'P'};

FinalTime        = 0.2;
CFL              = 0.2;
tstamps          = 1;
RK               = 'SSP3';

% Set type of indicator
Indicator       = 'NONE';
Filter_const    = true;
Limiter         = 'NONE';

%Set viscosity model
Visc_model = 'EV';
c_E=1; c_max=0.25;

% Output flags
plot_iter  = 1e6;
show_plot  = false;
xran       = [0,1];
yran       = [0,1];
clines     = linspace(0,2,30);
save_soln  = false;


NN = [1];
KK = [10];
ERROR_TABLE_l2 = zeros(length(KK), length(NN));
ERROR_TABLE_loo = zeros(length(KK), length(NN));
ERROR_TABLE_L2 = zeros(length(KK), length(NN));
for iii = 1:length(KK)
    for jjj = 1:length(NN)
        clear fixed_dt
        msh_file = sprintf('square_trans.%d.v2.msh', KK(iii));
        N        = NN(jjj);

        ScalarDriver2D;

        Qex = IC(Mesh.x - FinalTime, Mesh.y - FinalTime);
        e = TSteps{end}.u - Qex;

        ERROR_TABLE_loo(iii, jjj) = norm(e(:), inf) / norm(Qex(:), inf);
        ERROR_TABLE_l2(iii, jjj) = norm(e(:), 2) / norm(Qex(:), 2);

        paper_norm = @(e) sqrt(sum((e' * Mesh.MassMatrix) .* e', 'all'));
        ERROR_TABLE_L2(iii, jjj) = paper_norm(e)/paper_norm(Qex);

        save_simulation;
    end
end

convergence =  @(x) diff(log(x)) ./ -diff(log(KK))';

conv_l2 = convergence(ERROR_TABLE_l2)
conv_loo = convergence(ERROR_TABLE_loo)
conv_L2 = convergence(ERROR_TABLE_L2)

figure
loglog(KK, ERROR_TABLE_L2, '-o')


