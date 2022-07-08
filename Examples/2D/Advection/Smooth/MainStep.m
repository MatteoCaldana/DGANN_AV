% Remove NN diretory paths if they still exist
CleanUp2D;

close all
clear all
clc

model             = 'Advection';
AdvectionVelocity = [1,1];
test_name         = 'Step'; 
InitialCond       = @(x, y) (x>0.25).*(x<0.5).*(y>0.25).*(y<0.5);
BC_cond           = {100001,'P'; 100002,'P'; 100003,'P'; 100004,'P'};


FinalTime        = 0.2;
CFL              = 0.3;
tstamps          = 2;
N                = 2;
RK               = 'LS54';

% Set type of indicator
Indicator       = 'NONE';
Filter_const    = true;
nn_model        = '';
Limiter         = 'NONE';


%Set viscosity model
Visc_model = 'NONE';
nn_visc_model = '';

% Mesh file
msh_file        = 'square_trans.40.v2.msh';

% Output flags
plot_iter  = 1e6;
show_plot  = false;
xran       = [0,1]; 
yran       = [0,1];
clines     = linspace(0,2,30);
save_soln  = false;

% Call main driver
tic
ScalarDriver2D;
toc
sol = InitialCond(Mesh.x - FinalTime, Mesh.y - FinalTime);

figure
hold on
% scatter3(Mesh.x(:), Mesh.y(:), Q_save{end}(:))
% scatter3(Mesh.x(:), Mesh.y(:), sol(:), 'x')

if N == 1
    tri = reshape(1:numel(Mesh.x), 3, [])';
    trisurf(tri,Mesh.x(:), Mesh.y(:),  Q_save{end}(:))
else
    [n, m] = size(Mesh.x);
    for i = 1:m
        tri = delaunay(Mesh.x(:, i), Mesh.y(:, i));
        trisurf(tri, Mesh.x(:, i), Mesh.y(:, i),  Q_save{end}(:, i))
    end
end
