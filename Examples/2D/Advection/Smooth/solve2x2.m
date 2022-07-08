function [x] = solve2x2(A,b)
den = A(1, 1) * A(2, 2) - A(2, 1)*A(1, 2);
num1 = b(1)*A(2, 2) - A(1, 2)*b(2);
num2 = b(2)*A(1, 1) - A(2, 1)*b(1);
x = [num1/den; num2/den];
assert(max(abs(A*x-b)) < 2*eps)
end