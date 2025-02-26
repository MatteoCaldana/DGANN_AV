% Purpose : Setup script, building operators, grid, metric, and connectivity tables.
% Definition of constants
Mesh.Nfp = N+1; Mesh.Np = (N+1)*(N+2)/2; Mesh.Nfaces=3; Mesh.NODETOL = 1e-12;

% Compute nodal set
fprintf('... generating nodes\n')
[x,y] = Nodes2D(N); [Mesh.r,Mesh.s] = xytors(x,y);
Mesh.xrs = x; Mesh.yrs = y;

% Build reference element matrices
fprintf('... generating basic matrices\n')
Mesh.V          = Vandermonde2D(Mesh.N,Mesh.r,Mesh.s); 
Mesh.invV       = inv(Mesh.V);
Mesh.MassMatrix = Mesh.invV'*Mesh.invV;
[Mesh.Dr,Mesh.Ds]  = Dmatrices2D(Mesh.N, Mesh.r, Mesh.s, Mesh.V);

% build coordinates of all the nodes
fprintf('... generating nodes cordinates\n')
va = Mesh.EToV(:,1)'; vb = Mesh.EToV(:,2)'; vc = Mesh.EToV(:,3)';
Mesh.x = 0.5*(-(Mesh.r+Mesh.s)*Mesh.VX(va)+(1+Mesh.r)*Mesh.VX(vb)+(1+Mesh.s)*Mesh.VX(vc));
Mesh.y = 0.5*(-(Mesh.r+Mesh.s)*Mesh.VY(va)+(1+Mesh.r)*Mesh.VY(vb)+(1+Mesh.s)*Mesh.VY(vc));


% find all the nodes that lie on each edge
fprintf('... generating cell face mask\n')
fmask1   = find( abs(Mesh.s+1) < Mesh.NODETOL)'; 
fmask2   = find( abs(Mesh.r+Mesh.s) < Mesh.NODETOL)';
fmask3   = find( abs(Mesh.r+1) < Mesh.NODETOL)';
Mesh.Fmask = [fmask1;fmask2;fmask3]';
Mesh.Fx  = Mesh.x(Mesh.Fmask(:), :); Mesh.Fy = Mesh.y(Mesh.Fmask(:), :);

% Create surface integral terms
fprintf('... generating face matrices\n')
% [LIFT,M1D_1, M1D_2, M1D_3, facemid1, facemid2, facemid3] = Lift2D();
Lift2D;

% Creating averaging matrices
Mesh.AVG2D   = sum(Mesh.MassMatrix)/2;
Mesh.AVG1D_1 = sum(Mesh.M1D_1)/2; 
Mesh.AVG1D_2 = sum(Mesh.M1D_2)/2; 
Mesh.AVG1D_3 = sum(Mesh.M1D_3)/2;

% calculate geometric factors
fprintf('... calculating geometric transform factors\n')
[Mesh.rx,Mesh.sx,Mesh.ry,Mesh.sy,Mesh.J] = GeometricFactors2D(Mesh.x,Mesh.y,Mesh.Dr,Mesh.Ds);

% calculate geometric factors
fprintf('... generating face normal data\n')
%[Mesh.nx, Mesh.ny, Mesh.sJ] = Normals2D();
Normals2D
Mesh.Fscale = Mesh.sJ./(Mesh.J(Mesh.Fmask,:));

% calculate incircle radius for each triangle
fprintf('... calculating radius of incircles\n')
xscale2D;

% Build connectivity matrix
%[EToE, EToF] = tiConnect2D(EToV);
fprintf('... creating connectivity matrices\n')
[Mesh.EToE, Mesh.EToF, Mesh.PShift, Mesh.BCTag] = ...
     Connect2D(Mesh.EToV,Mesh.BFaces,Mesh.PerBToB_map,Mesh.PerBFToF_map,Mesh.BC_flags,...
                                 Mesh.UseMeshPerData,Mesh.VX,Mesh.VY,Mesh.BC_ENUM.Periodic);

% Build ghost elements for non-periodic boundary faces
fprintf('... generating additional geometric data and ghost elements\n')
GetGeomData2D;
                             
%%                             
% Build connectivity maps
fprintf('... building face maps\n')
BuildMaps2D;

% Compute weak operators (could be done in preprocessing to save time)'
% NOTE that there is a transponse in the weak formulation, thus the
% following matrix form is obtained after multiplying by the inverse
% of the mass matrix
fprintf('... generating weak operators\n')
[Mesh.Vr, Mesh.Vs] = GradVandermonde2D(Mesh.N, Mesh.r, Mesh.s);
Mesh.Drw = (Mesh.V*Mesh.Vr')/(Mesh.V*Mesh.V'); 
Mesh.Dsw = (Mesh.V*Mesh.Vs')/(Mesh.V*Mesh.V');

% Find projection matrices need for Fu-Shu indicator
%ProjectFromNb2D = Get_Projection_2D;


%% 

fprintf('... generating interpolation matrix\n')

% Compute matrix to perform linear interpolation of artificial viscosity:
% from value in vertexes, returns value in all points
Mesh.VToE=sparse(length(Mesh.VX),Mesh.K);

Mesh.EToVT=Mesh.EToV';

% Compute neighboring elements
for i=1:length(Mesh.VX)
    ids=find(Mesh.EToVT(:)==i);
    elem=floor((ids-1)/3)+1;
    
    Mesh.VToE(i,elem)=1;
end
Mesh.neighbors=full(sum(Mesh.VToE,2));

% Compute (inverse) of "Vandermonde" matrix
Coord_vector=[Mesh.VX(Mesh.EToVT(:))',Mesh.VY(Mesh.EToVT(:))',ones(length(Mesh.EToVT(:)),1)];
for i=1:Mesh.K, Coord_vector(3*(i-1)+1:3*i,:)=Coord_vector(3*(i-1)+1:3*i,:)\eye(3,3); end
[rws,cls]=size(Coord_vector); i=repmat([1:rws]',3,1); tmp=[1:3:3*Mesh.K, 2:3:3*Mesh.K, 3:3:3*Mesh.K]; j=repmat(tmp,3,1); 
Coord_matrix_V_inv=sparse(i(:),j(:),Coord_vector(:));

% Evaluate coefficients in the (x,y) points
Coord_vector=[Mesh.x(:),Mesh.y(:),ones(length(Mesh.x(:)),1)];
[rws,cls]=size(Coord_vector); i=repmat([1:rws]',3,1); tmp=[1:3:3*Mesh.K, 2:3:3*Mesh.K, 3:3:3*Mesh.K]; j=repmat(tmp,Mesh.Np,1); 
Coord_matrix_DOF=sparse(i(:),j(:),Coord_vector(:));

Mesh.coov_inv = Coord_matrix_V_inv;
Mesh.coov_dof = Coord_matrix_DOF;

% Store interpolation matrix
Mesh.interp_matrix=Coord_matrix_DOF*(Coord_matrix_V_inv);