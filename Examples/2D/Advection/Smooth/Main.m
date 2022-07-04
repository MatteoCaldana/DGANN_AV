% Remove NN diretory paths if they still exist
CleanUp2D;

close all
clear all
clc

model             = 'Advection';
AdvectionVelocity = [1,1]; % Used for linear advection only
test_name         = 'Smooth'; 
InitialCond       = @IC;
BC_cond           = {100001,'P'; 100002,'P'; 100003,'P'; 100004,'P'};


FinalTime        = 0.5;
CFL              = 0.3;
tstamps          = 2;
N                = 1;
RK               = 'LS54';

% Set type of indicator
%Indicator       = 'TVB'; TVBM = 10; TVBnu = 1.5;
Indicator       = 'NONE';
Filter_const    = true;
nn_model        = '';
Limiter         = 'NONE';


%Set viscosity model
Visc_model = 'NONE';
nn_visc_model = '';
% Visc_model='EV'; c_E=1; c_max=0.25;
%Visc_model='MDH'; c_A=2; c_k=0.4; c_max=0.8;
%Visc_model='MDA'; c_max=0.8;
%Visc_model='NN';


% Mesh file
msh_file        = 'square_trans.10.v2.msh';

% Output flags
plot_iter  = 1e6;
show_plot  = false;
xran       = [0,1]; 
yran       = [0,1];
clines     = linspace(0,2,30);
save_soln  = false;

% Call main driver
ScalarDriver2D;

sol = IC(Mesh.x - FinalTime, Mesh.y - FinalTime);

figure
scatter3(Mesh.x(:), Mesh.y(:), Q_save{end}(:))
hold on
scatter3(Mesh.x(:), Mesh.y(:), sol(:), 'x')

