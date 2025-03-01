% Code from Lab 2

clear;
clc;
close all;

%% Part 1 (Single Mode)

g = 9.81;
L = [.6, .8, .9, 1.2];
w = sqrt(g./L);
Vtol = .05;
Td = 2.*pi./w;

ZV = [];
EI = [];
ZVD = [];
ZVDD = [];
for i = 1:length(w)
    ZV = cat(3, ZV, [0, pi./w(i); 1/2, 1/2]);
    EI = cat(3, EI, [0, .5.*Td(i), Td(i); (1+Vtol)./4, (1-Vtol)./4, (1+Vtol)./4]);
    ZVD = cat(3, ZVD, [0, .5.*Td(i), Td(i); 1/4, 1/2, 1/4]);
    ZVDD = cat(3, ZVDD, [1./8, 3./8, 3./8, 1./8; 0, .5.*Td(i), Td(i), 1.5.*Td(i)]);
end

%% Part 2 (2-Mode with 1-Mode shapers)

% clear;
% close all;
% clc;

L1 = 1;
L2 = .625;
m1 = .658;
m2 = .227;
R = m2./m1;
cg = (m2.*L2)./(m1 + m2);
g = 9.81;
w = sqrt(g./(cg+L1));
Vtol = .05;
Td = 2.*pi./w;

ZV = [0, pi./w; 1/2, 1/2];
EI = [0, .5.*Td, Td; (1+Vtol)./4, (1-Vtol)./4, (1+Vtol)./4];
ZVD = [0, .5.*Td, Td; 1/4, 1/2, 1/4];
ZVDD = [1./8, 3./8, 3./8, 1./8; 0, .5.*Td, Td, 1.5.*Td];

%% Part 3 (2-Mode Shapers)

clear;
close all;
clc;

L1 = 1;
L2 = .625;
m1 = .658;
m2 = .227;
R = m2./m1;
cg = (m2.*L2)./(m1 + m2);
g = 9.81;
Vtol = .05;
B = sqrt(((1+R).^2).*((1./L1)+(1./L2)).^2 - 4.*((1+R)./(L1.*L2)));
w1 = sqrt(g./2).*sqrt((1+R).*((1./L1)+(1./L2))+B);
w2 = sqrt(g./2).*sqrt((1+R).*((1./L1)+(1./L2))-B);
Td1 = 2.*pi./w1;
Td2= 2.*pi./w2;

ZV1 = [1/2, 1/2; 0, pi./w1];
EI1 = [(1+Vtol)./4, (1-Vtol)./4, (1+Vtol)./4; 0, .5.*Td1, Td1];
ZVD1 = [1/4, 1/2, 1/4; 0, .5.*Td1, Td1];
ZVDD1 = [1./8, 3./8, 3./8, 1./8; 0, .5.*Td1, Td1, 1.5.*Td1];
ZV2 = [1/2, 1/2; 0, pi./w2];
EI2 = [(1+Vtol)./4, (1-Vtol)./4, (1+Vtol)./4; 0, .5.*Td2, Td2];
ZVD2 = [1/4, 1/2, 1/4; 0, .5.*Td2, Td2];
ZVDD2 = [1./8, 3./8, 3./8, 1./8; 0, .5.*Td2, Td2, 1.5.*Td2];


ex1 = [.25, .5, .25; 0, .5, 1];
ex2 = [.25, .5, .25; 0, .2, .4];
ex = [];
ZV = [];
ZVD = [];
ZVDD = [];
EI = [];

for i = 1:length(ex1(1,:))
    for j = 1:length(ex1(1,:))
       ex = [ex, [ex1(1, i).*ex2(1,j) ;ex1(2, i)+ex2(2, j)]];
       
    end
end
for i = 1:length(ZV1(1,:))
    for j = 1:length(ZV1(1,:))
       ZV = [ZV, [ZV1(1, i).*ZV2(1,j) ;ZV1(2, i)+ZV2(2, j)]];
       
    end
end

for i = 1:length(ZVD1(1,:))
    for j = 1:length(ZVD1(1,:))
       ZVD = [ZVD, [ZVD1(1, i).*ZVD2(1,j) ;ZVD1(2, i)+ZVD2(2, j)]];
       
    end
end
for i = 1:length(ZVDD1(1,:))
    for j = 1:length(ZVDD1(1,:))
       ZVDD = [ZVDD, [ZVDD1(1, i).*ZVDD2(1,j) ;ZVDD1(2, i)+ZVDD2(2, j)]];
       
    end
end
for i = 1:length(EI1(1,:))
    for j = 1:length(EI1(1,:))
       EI = [EI, [EI1(1, i).*EI2(1,j) ;EI1(2, i)+EI2(2, j)]];
       
    end
end