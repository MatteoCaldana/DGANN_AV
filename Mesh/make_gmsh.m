function [VX, VY, K, Nv,EToV,BFaces, PerBToB_map, PerBFToF_map] = make_gmsh(corner_sw, corner_ne, np)

assert(length(corner_sw) == 2);
assert(length(corner_ne) == 2);
assert(length(np) == 2);

X =  linspace(corner_sw(1), corner_ne(1), np(1));
Y =  linspace(corner_sw(2), corner_ne(2), np(2));

[XX, YY] = meshgrid(X, Y);
VX = reshape(XX.',1,[]);
VY = reshape(YY.',1,[]);

K = 2 * (np(1) - 1) * (np(2) - 1);
Nv = length(VX);

EToV = zeros(K, 3);
for k = 0:K/2-1
    ie = [mod(k, np(1) - 1), fix(k / (np(2) - 1))];
    iv1 = [ie; ie + [1, 0]; ie + [0, 1]];
    iv2 = [ie + [0, 1]; ie + [1, 0]; ie + [1, 1]];
    
    for j = 1:3
        EToV(2*k+1, j) = iv1(j, 1) + iv1(j, 2) * np(1) + 1;
        EToV(2*(k+1), j) = iv2(j, 1) + iv2(j, 2) * np(1) + 1;
    end
end

BFaces  = containers.Map('KeyType','uint32','ValueType','any');
BFaces100001 = zeros(np(2) - 1, 2);
BFaces100002 = zeros(np(2) - 1, 2);
BFaces100003 = zeros(np(1) - 1, 2);
BFaces100004 = zeros(np(1) - 1, 2);
for i = 1:np(1)-1
    BFaces100003(i, :) = i + [0, 1];
    BFaces100004(i, :) = Nv-i + [1, 0];
end
for i = 0:np(2)-2
    BFaces100001(end-i, :) = 1 + [i+1, i]*np(1);
    BFaces100002(i + 1, :) = np(1) * [i + 1, i + 2];
end
BFaces(100001) = BFaces100001;
BFaces(100002) = BFaces100002;
BFaces(100003) = BFaces100003;
BFaces(100004) = BFaces100004;

PerBToB_map  = containers.Map('KeyType','uint32','ValueType','uint32');
PerBToB_map(100002) = 100001;
PerBToB_map(100003) = 100004;

PerBFToF_map = containers.Map('KeyType','uint32','ValueType','any');
PerBFToF_map(100002) = (-length(BFaces(100002)):-1)';
PerBFToF_map(100003) = (-length(BFaces(100003)):-1)';


end

