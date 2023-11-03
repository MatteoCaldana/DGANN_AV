clc
clear all
close all

% Call code driver

KK = [30];
NN = [3];
ERROR_TABLE_XX = zeros(length(KK), length(NN));
ERROR_TABLE_PAPER = zeros(length(KK), length(NN));
for i__ = 1:length(KK)
    for j__ = 1:length(NN)
        K = KK(i__);
        N = NN(j__);

        CleanUp1D;

        model     = 'Advection';
        test_name = 'Sine';
        mp = @(x) (x + 1) - fix(x + 1);
        u2 = @(x) -exp(-400*(x-0.5).^2) .* (x > 0.3) .* (x < 0.7);
        u3 = @(x) 20 * (0.5 - abs(x - 0.5));
        u7 = @(x) sin(4*pi*x) .* (x > 0.25) .* (x < 0.5) + ...
                  sin(8*pi*x) .* (x > 0.5) .* (x < 0.75);

        u8 = @(x)  x .* (x < 0.5) + (x - 1) .* (x > 0.5);
        u9 = @(x)  (x > 0.25) .* (x < 0.75);
        u_IC = u9; %@(x) mp(x) > 0.5; %2 + sin(2*pi*x);


        bnd_l     = 0;
        bnd_r     = 1.0;
        mesh_pert = 0.0;
        bc_cond   = {'P',0.0,'P',0.0};
        FinalTime = 0.2;
        CFL       = 0.1;
        RK        = 'LS54';


        Indicator = 'NONE'; TVBM=1;
        nn_model  = '';
        Limiter   = 'NONE';

        Visc_model = 'NONE';
        nn_visc_model = '';
%         Visc_model='EV';
        c_E=1; c_max=0.5;
        %         Visc_model='MDH'; c_A=2.5; c_k=0.2; c_max=0.5;
        %         Visc_model='MDA'; c_max=1;

        plot_iter  = 1;
        save_iter  = 1e6;
        save_soln  = false;
        save_ind   = false;
        save_visc  = false;
        save_plot  = false;
        ref_avail  = false;
        ref_fname  = 'ref_soln.dat';
        var_ran    = [-1.2,1.5];

        params = struct;
        params.model = model;
        params.N = N;
        params.K = K;
        params.u_IC = u_IC;
        params.bnd_l = bnd_l;
        params.bnd_r = bnd_r;
        params.mesh_pert = mesh_pert;
        params.bc = bc_cond;
        params.final_time = FinalTime;
        params.cfl = CFL;
        params.integrator = RK;
        params.viscosity_model = Visc_model;
        params.c_E = c_E;
        params.c_max = c_max;
        params.name = test_name;
        params.indicator = Indicator;
        params.limiter = Limiter;

        ScalarDriver1D;

        %save("test_09.mat", "params", "Mesh", "memory")
        x = Mesh.x(:);
        ERROR_TABLE_XX(i__, j__) = norm(u(:) - u_IC(x - FinalTime), inf);

        uhu = u - u_IC(Mesh.x - FinalTime);
        ERROR_TABLE_PAPER(i__, j__) = sqrt(sum(sum((uhu' * Mesh.M) .* uhu')));

%         figure
%         plot(x, u(:), x, u_IC(x - FinalTime))
%         pause
%         close
    end
end

figure
loglog(KK, ERROR_TABLE_XX, '-o')
hold on
loglog(KK, ERROR_TABLE_PAPER, '-o')
loglog(KK, (1./KK).^(NN'+1), '--k')
grid on

pxx = (log(ERROR_TABLE_XX(1:end-1, :)) - log(ERROR_TABLE_XX(2:end, :))) ./ ...
    (log(KK(2:end)) - log(KK(1:end-1)))'

ppa = (log(ERROR_TABLE_PAPER(1:end-1, :)) - log(ERROR_TABLE_PAPER(2:end, :))) ./ ...
    (log(KK(2:end)) - log(KK(1:end-1)))'

close all
