clc
clear all
close all


KK = [10, 20, 40, 80, 160];
NN = [1, 2, 3];
ERROR_TABLE_L2 = zeros(length(KK), length(NN));
ERROR_TABLE_Loo = zeros(length(KK), length(NN));
ERROR_TABLE_PAPER = zeros(length(KK), length(NN));
for iii = 1:length(KK)
    for jjj = 1:length(NN)

        K = KK(iii);
        N = NN(jjj);

        CleanUp1D;

        model     = 'Advection';
        test_name = 'Sine';
        u_IC =@(x) 2 + sin(2*pi*x);


        bnd_l     = 0;
        bnd_r     = 1.0;
        mesh_pert = 0.0;
        bc_cond   = {'P',0.0,'P',0.0};
        FinalTime = 0.2;
        CFL       = 0.01;
        RK        = 'LS54';


        Indicator = 'NONE';
        nn_model       = '';
        Limiter    = 'NONE';

        Visc_model = 'NONE';
        nn_visc_model = '';
        %Visc_model='EV'; c_E=1; c_max=0.5;
        %Visc_model='MDH'; c_A=2.5; c_k=0.2; c_max=0.5;
        %Visc_model='MDA'; c_max=1;
        %Visc_model='NN';

        plot_iter  = 1e6;
        save_iter  = 1e6;
        save_soln  = false;
        save_ind   = false;
        save_visc  = false;
        save_plot  = false;
        ref_avail  = false;
        ref_fname  = 'ref_soln.dat';
        var_ran    = [-1.2,1.5];

        % Call code driver
        ScalarDriver1D;


        x = Mesh.x(:);
        u_ex = u_IC(Mesh.x - FinalTime);

        ERROR_TABLE_Loo(iii, jjj) = norm(u(:) - u_ex(:), inf) / norm(u_ex(:), inf);
        ERROR_TABLE_L2(iii, jjj) = norm(u(:) - u_ex(:), 2) / norm(u_ex(:), 2);

        
        e = u - u_ex;

        paper_norm = @(e) sqrt(sum((e' * Mesh.M) .* e', 'all'));
        ERROR_TABLE_PAPER(iii, jjj) = paper_norm(e)/paper_norm(u_ex);
    end
end


convergence =  @(x) diff(log(x)) ./ -diff(log(KK))';

convergence(ERROR_TABLE_L2)
convergence(ERROR_TABLE_Loo)
convergence(ERROR_TABLE_PAPER)


figure
loglog(KK, ERROR_TABLE_L2, '-o')