close all;
clear all;
set(0,'DefaultFigureWindowStyle','docked')

%%
% Start by setting up the values for the componants of the circuit
R1 = 1;
c = 0.25;
R2 = 2;
L = 0.2;
R3 = 10;
alpha = 100;
R4 = 0.1;
Ro = 1000;

% For simplicity, use the convert resistnaces to conductances
g1 = 1/R1;
g2 = 1/R2;
g3 = 1/R3;
g4 = 1/R4;
go = 1/Ro;

%%
% Initialize the C, G, and F matricies to the correct size
G = sparse(8,8);
C = sparse(8,8);
F = sparse(8,1);

%%
% Fill in the G matrix using the equations based on the MNA formulation
G(1,1) = g1;
G(1,2) = -g1;
G(2,1) = g1;
G(2,2) = g1+g2;
G(3,3) = g3;
G(4,4) = g4;
G(4,5) = -g4;
G(5,4) = -g4;
G(5,5) = g4+go;
G(6, 1) = 1;
G(7, 2) = 1;
G(7, 3) = -1;
G(8, 3) = -alpha*g3;
G(8, 4) = 1;
G(1, 6) = 1;
G(2, 7) = 1;
G(3, 7) = -1;
G(4, 8) = 1;

%%
% fill in the C matrix using storage elements of the circuit
C(1,1) = c;
C(1,2) = -c;
C(2,1) = -c;
C(2,2) = c;
C(7,7) = -L;

%%
% To solve for Vout (V5) we sweep Vin from -10 to 10V
iter = 50;
Vin = zeros(iter,1);
V3 = zeros(iter,1);
V5 = zeros(iter,1);
count = 1;
for i = -10:(20/(iter-1)):10
    F(6) = i;
    V = G\F;
    V3(count) = V(3);
    V5(count) = V(5);
    Vin(count) = i;
    count = count+1;
end

figure(1)
subplot(2,1,1);
plot(Vin, V3);
title('DC sweep of Vin vs. V3');
xlabel('Vin (V)');
ylabel('V3 (V)');

subplot(2,1,2)
plot(Vin, V5);
title('DC sweep of Vin vs. Vout');
xlabel('Vin (V)');
ylabel('V5 (Vout) (V)');

%%
% For the AC case, plot Vout as a function of omega
iter = 1000;
omega = zeros(iter,1);
gain = zeros(iter,1);
Vo = zeros(iter,1);
for i = 1:1:iter-1
    S = 1i*i;
    V = inv((G + S.*C))*F;
    Vo(i) = abs(V(5));
    omega(i) = 2*pi*i;
    gain(i) = 20*log10(abs(Vo(i))/abs(V(1)));
end

figure(2)
subplot(2,1,1);
plot(omega,Vo);
title('omega vs. Vout');
xlabel('omega (/s)');
ylabel('Vout (V)');

% The gain in dB also needs to be plotted with respect to the angular
% frequency
subplot(2,1,2);
semilogx(omega, gain);
title('Gain Vo/V1');
xlabel('omega (/s)');
ylabel('gain (dB)');

%%
% a normally distributed random perturbation is applied to the capacitor
Vo = zeros(length(omega),1);
gain = zeros(length(omega),1);
for i = 1:length(gain)
    pert = randn()*0.05;
    C(1,1) = c*pert;
    C(2,1) = -c*pert;
    C(1,2) = -c*pert;
    C(2,2) = c*pert;
    
    S = 1i*2*pi;
    V = inv((G + S.*C))*F;
    Vo(i) = abs(V(5));
    gain(i) = 20*log10(abs(Vo(i))/abs(V(1)));
end

figure(3)
histogram(gain,75);
title('Histogram of gain with 0.05 perturbation on C');
ylabel('count');
xlabel('Gain (dB)');
