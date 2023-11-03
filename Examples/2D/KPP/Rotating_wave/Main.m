% Remove NN diretory paths if they still exist
CleanUp2D;

close all
clear all
clc

model             = 'KPP';
AdvectionVelocity = [1,1]; % Used for linear advection only
test_name         = 'KPP'; 
InitialCond       = @(x,y) 3.5*pi*(x.^2+y.^2<1)+0.25*pi*(x.^2+y.^2>=1);
BC_cond           = {100001,'P'; 100002,'P'; 100003,'P'; 100004,'P'};


FinalTime        = 1.0;
CFL              = 0.2;
tstamps          = 2;
N                = 1;
RK               = 'LS54';

% Set type of indicator
%Indicator       = 'TVB'; TVBM = 10; TVBnu = 1.5;
Indicator       = 'NONE';
Filter_const    = true;
nn_model        = 'MLP_v1';
Limiter         = 'NONE';


%Set viscosity model
%Visc_model = 'NONE';
nn_visc_model = 'MLP_visc';
Visc_model='EV'; c_E=2.0; c_max=1.0;
%Visc_model='MDH'; c_A=2; c_k=0.4; c_max=0.8;
%Visc_model='MDA'; c_max=0.8;
%Visc_model='NN';


% Mesh file
% gmsh -2 -format msh2 square_trans.geo
msh_file        = 'square_trans.040.msh';
%msh_file        = 'unstructured_22_H004.msh';

% Output flags
plot_iter  = 99999999;
show_plot  = true;
xran       = [-2,2]; 
yran       = [-2,2];
clines     = linspace(0.7,11.5,30);
save_soln  = false;

% Call main driver
ScalarDriver2D;

