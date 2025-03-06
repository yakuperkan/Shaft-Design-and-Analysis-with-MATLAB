clear all
clc
% This software was developed by Yakup Erkan KAYMAZ as part of a project assignment
% to assist us in designing shafts.
clear all
clc

D1=1;
D2=1;
D3=1;
D4=1;
q3=1;
qs3=1;
q2=1;
qs2=1;
q4=1;
qs4=1;


%Take values from user..!
for i=1:4
    D(i)=input('please,enter the diameter : ');
   % fprintf('D(%d)=%2.f\n',i,D(i))


    if i==1
        D1=D(1);
    elseif i==2
        D2=D(2);
    elseif i==3
        D3=D(3);
    else
        D4=D(4);
    end
    fprintf('D(%d)=%2.f\n',i,D(i))
    
end


%Set the qs and q values from table 6-20 and 6-21..! 

if D1>=30 && D1<40
    q4=0.83;
    qs4=0.84;

elseif D1 >= 40 && D1<50
    q4=0.86;
    q4s=0.86;

elseif D2>=30 && D2<40
    q3=0.83;
    qs3=0.84;

elseif D2 >= 40 && D2<50
    q3=0.86;
    q3s=0.86;
    
    
else if D3>=30 && D3<40
    q2=0.83;
    qs2=0.84;

elseif D3 >= 40 && D3<50
    q2=0.86;
    q2s=0.86;
else
   q2=rand();
   q2s=rand();
   q3=rand();
   q3s=rand();
   q4=rand();
   q4s=rand();
end
end




%Shaft dimensions
a=33.87; %bearing length in mm
b=20.03; %section 2 length in mm
c=41.79; %gear 1 length in mm
d=52.27; %section 4 length in mm
L=2*(a+b+c+d); % Length of the shaft in mm

%diameters of gears in mm (left side)
DG_1=328.19;
DG_2=66.76;

T=348.05; % Torque in N.m;

% Tangential forces in N
Wt_1=T/(((DG_1/2)*(10^(-3))));
Wt_2=T/(((DG_2/2)*10^(-3)));

%Radial forces in N
Wr_1=Wt_1*tand(20);
Wr_2=Wt_2*tand(20);

fprintf('T=%.2f N\n',T)
fprintf('Wt_1= %.2f N\n',Wt_1)
fprintf('Wt_2= %.2f N\n',Wt_2)
fprintf('Wr_1= %.2f N\n',Wr_1)
fprintf('Wr_2= %.2f N\n',Wr_2)


%Equations of equilibrium Completed!
syms RAz RBz RAy RBy
eq1 = RAz + RBz  == - Wt_2 + Wt_1; % Z direction equilibrium
eq2 = RAy + RBy == Wr_1 + Wr_2; % Y direction equilibrium
Mz = -Wt_1 * ((a/2)+b+(c/2)) + Wt_2 * ((a/2)+b+c+d+d+(c/2)) + RBz * (L-a) == 0; % Moment equilibrium (A point)
My = -Wr_1 * ((a/2)+b+(c/2)) - Wr_2 * ((a/2)+b+c+d+d+(c/2)) + RBy * (L-a) == 0; % Moment equilibrium (A point)


%Solving equations
sol = solve([eq1, eq2, Mz, My], [RAz, RAy, RBz, RBy]);
RAz = double(sol.RAz);
RAy = double(sol.RAy);
RBz = double(sol.RBz);
RBy = double(sol.RBy);


fprintf('RAz = %.2f N\n', RAz);
fprintf('RAy = %.2f N\n', RAy);
fprintf('RBz = %.2f N\n', RBz);
fprintf('RBy = %.2f N\n', RBy);


x = linspace(0, L, 2000); %Point on shaft along the shaft
Vxy = zeros(size(x)); % Shear force xy direction
Vxz = zeros(size(x)); % Shear force xz direction
Mxz = zeros(size(x)); % Moment about x-z axis
Mxy = zeros(size(x)); % Moment about x-y axis
M_total=zeros(size(x)); % Total moment value Mxz and Mxy
T = zeros(size(x)); %Torque


%Torque Distribution Diagram Completed!
for i = 1:length(x)
    if x(i) <= (a + b)
        T(i) = 0; % There is no torque in first part
    elseif x(i) <= (a + b + c)
        T(i) = 348.05; % The torque is constant value in mid part
    elseif x(i) <= L - (a + b + c)
        T(i) = 348.05; % Symmetric torque until the Gear 2
    else
        T(i) = 0; % Torque is zero in last part on the shaft
    end
end


% Vxy Diagram Completed!
for i = 1:length(x)

    if x(i) <= a + b +(c/2)
        Vxy(i) = RAy; 
    elseif x(i) <= (a + b + c + d + d + (c/2))
        Vxy(i) = RAy - Wr_1;
    elseif x(i) <= (a + b + c + d + d + c + (a/2))
        Vxy(i) = RAy - Wr_1 - Wr_2; 
    else
        V(i) = RAy - Wr_1 + RBy - Wr_2;
    end
end


% Vxz Diagram Completed!
for i=1:length(x)
    if x(i) <= a + b +(c/2)
        Vxz(i) = -RAz; 
    elseif x(i) <= (a + b + c + d + d + (c/2))
        Vxz(i) = -RAz + Wt_1;
    elseif x(i) <= (a + b + c + d + d + c + (a/2))
        Vxz(i) = -RAz + Wt_1 - Wt_2; 
    else
        Vxz(i) = -RAz + Wt_1 - RBz - Wt_2;
    end
end


%Mxy diagram Completed!
for i=1:length(x)
    if x(i) <= ((a/2) + b + (c/2))
        Mxy(i)= RAy*(x(i));

    elseif x(i) <= ((a/2)+b+c+2*d+(c/2))
        Mxy(i)= RAy*(a +b + (c/2)) + Wr_1*(x(i) - a - b - (c/2));

    elseif x(i) >= ((a/2)+b+c+2*d+(c/2)) && x(i) <= L
        Mxy(i)= RAy*(a +b + (c/2)) + Wr_1*((c/2) + d + d + (c/2)) - Wr_2*(x(i)- (a/2) - b - c - d - d - (c/2));
         if abs(Mxy(i)) < 480
            break
        end
    end
end


%Mxz Diagram Completed!
for i=1:length(x)
    if x(i) <= ((a/2) + b + (c/2))
        Mxz(i)= - RAz*(x(i));

    elseif x(i) <= ((a/2)+b+c+2*d+(c/2))
        Mxz(i)= - RAz*(a +b + (c/2)) + Wt_1*(x(i) - a - b - (c/2));

    elseif x(i) >= ((a/2)+b+c+2*d+(c/2)) && x(i) <= L
        Mxz(i)= -RAz*(a +b + (c/2)) + Wt_1*((c/2) + d + d + (c/2)) - Wt_2*(x(i)- (a/2) - b - c - d - d - (c/2));
         if Mxz(i)< 20
            break
        end
    end
end


for i=1:length(x)
   M_total(i)=Mxz(i)+Mxy(i);
end


% Vxz diagram Completed!
figure;
subplot(6, 1, 1);
plot(x, Vxz, 'b', 'LineWidth', 1.5);
xlabel('Length of shaft (mm)');
ylabel('Shear Force Vxz (N)');
title('Shear Force Diagram Vxz');
grid on;


%Vxy Diagram Completed!
subplot(6,1,2);
plot(x,Vxy,'m','LineWidth',1.5);
xlabel('Length of shaft (mm)');
ylabel('Shear Force Vxy (N)');
title('Shear Force Diagram Vxy');
grid on;


%Mxz Diagram Completed!
subplot(6, 1, 3);
plot(x, Mxz, 'r', 'LineWidth', 1.5);
xlabel('Length of shaft (mm)');
ylabel('Moment Mxz (N.mm)');
title('Moment Diagram Mxz');
grid on;


%Mxy Diagram Completed!
subplot(6,1,4);
plot(x,Mxy,'k','LineWidth',1.5);
xlabel('Length of shaft (mm)');
ylabel('Moment Mxy (N.mm)');
title('Moment Diagram Mxy');
grid on;


%Total Moment Diagram Completed!
subplot(6,1,5);
plot(x,M_total,'c','LineWidth',1.5);
xlabel('Length of shaft (mm)');
ylabel('Moment M_total (N.mm)');
title('Moment Diagram M_total');
grid on;


% Torque Diagram
subplot(6,1,6);
plot(x,T,'Color', '#FFA500','LineWidth',1.5)
xlabel('Length of Shaft (mm)');
ylabel('Torque T (N)');
title('Torque Diagram');
grid on;


%AISI 1020 CD Alloy Information
fprintf('------AISI 1020 CD Alloy Information------\n')
Sut=470; %MPa
Sy=390; %MPa
rho=7870; %kg/(m^3)
fprintf('Sut=%2.f MPa, Sy=%2.f MPa and rho=%2.f kg/m^-3\n',Sut,Sy,rho)


fprintf('------Properties of D3------\n')

%Calculating diameter For D3 
Mxy_D3=385.105;
Mxz_D3=167.014;

Mtotal_D3=sqrt((Mxz_D3^2)+(Mxy_D3^2));
fprintf('Mtotal_D3=%2.f N.m\n',Mtotal_D3)


%Calculating surface factor
As=4.51; %For CD or machined materials from table 6-2
Bs=-0.265;
Ka1=As*((Sut)^Bs);
Nf_1=1.72;
Kb1=0.8; %assume
Kc1=1;
Kd1=1;
Ke1=1;
Kt1=2.7;
Kts=1.5;
Kf1=2.7; %Assume
Kfs1=1.5; %assume


%Find Se
Se=Ka1*Kb1*Kd1*Kc1*Ke1*0.5*Sut;
fprintf('Se=%2.f MPa\n',Se)

%Apply goodman criteria
%D3 = (((16 * Nf_1) / pi) * (((2 * Kf1 * Mtotal_D3) / (Se*10^6)) + (sqrt(3 * Kfs1 * (348.05)^2) / (Sut*10^6))))^(1/3);
fprintf('D3=%2.f mm \n',D3*1000)


Kts_2=1.35;
Kt_2=1.6;
%q2=0.85;
%qs2=0.85;
Kf_2=1+(q2*(Kt_2-1));
Kfs_2=1+(qs2*(Kts_2-1));
Kb2=(((D3*1000)/7.62)^(-0.107));

Se_2=Ka1*Kb2*Kc1*Kd1*Ke1*(0.5)*Sut;
fprintf('Se_2=%2.f MPa\n',Se_2)


% Calculating alternating and midpoint Stress for D3
Sa_1=((32*(Kf_2*Mtotal_D3))/(pi*(D3^3)))*(10^-6);
Sm_1=(sqrt(3)*16*Kfs_2*(348.05))/(pi*(D3^3))*(10^-6);

fprintf('Sa_1=%2.f MPa\n',Sa_1)
fprintf('Sm_1=%2.f MPa\n',Sm_1)


%Calculating Nf_2 using goodman criteria
Nf_2=(1/((Sa_1/Se)+(Sm_1/Sut)));

%Calcualting Nf_Sy_2 using yield strength
Nf_Sy_2=(Sy/(Sa_1+Sm_1));

%Checking safety factor 
if Nf_2 >= 1.72 && Nf_Sy_2 >= 1.72
    fprintf('These values are within the limits.\n')
else
    fprintf('Please,check D3 diameter..!\n')
end

%Properties of D4
fprintf('------Properties of D4------\n')


%Find D4 using D3
% D/d=1.2 typical ratio for support at a shoulders.
%D4=D3*1.2; 
fprintf('D4=D3*1.2=%2.f mm\n',D3*1.2*1000)

%Properties for calculating D2
fprintf('------Properties of D2------\n')


%Calculating D2 using D3
%D/d=0.2 typical ratio at the shoulders.
%D2=((D3*1000)/1.2);
fprintf('D2=%2.f mm\n',D2)

%Calculating total moment for calculating D2
Mxy_D2=206.337;
Mxz_D2=84.227;

Mtotal_D2=sqrt(((Mxz_D2)^2)+((Mxy_D2)^2));
fprintf('Mtotal_D2=%2.f N.mm\n',Mtotal_D2)


%q3=0.87;
%qs3=0.88;
Kt_3=1.6;
Kts_3=1.35;
Kf_3=1+(q3*(Kt_3-1));
Kfs_3=1+(qs3*(Kts_3-1));
Kb_3=(D2/7.62)^(-0.107);

%Calculating Se_3
Se_3=Ka1*Kb_3*Kc1*Kd1*Ke1*(0.5)*Sut;
fprintf('Se_3=%2.f MPa \n',Se_3)

% Calculating alternating and midpoint Stress for D2
Sa_2=((32*(Kf_3*Mtotal_D2))/(pi*((D2*10^-3)^3)))*(10^-6);
Sm_2=(sqrt(3)*16*Kfs_3*(348.05))/(pi*((D2*10^-3)^3))*(10^-6);

fprintf('Sa_2=%2.f MPa\n',Sa_2)
fprintf('Sm_2=%2.f MPa\n',Sm_2)

%Calculating Nf_3 using goodman criteria
Nf_3=((1/(Sa_2/Se_3)+(Sm_2/Sut)));
fprintf('Nf_3=%2.f\n',Nf_3)

%Calculating Nf_Sy_3 using Yield Strength
Nf_Sy_3=(Sy/(Sa_2+Sm_2));
fprintf('Nf_Sy_3=%2.f\n',Nf_Sy_3)

if Nf_3 >=1.72 && Nf_Sy_3 >=1.72
    fprintf('These values are within the limits.\n')
else
    fprintf('Please,check D2 diameter..!\n')
end


%Calculating D1 using D2
%Assume D1 as a 35mm.Properties of D1.
%typical r/d ratio is 0.02 from book
fprintf('------Properties of D1-------\n')

%D1=35;
fprintf('D1=%2.f mm\n',D1)

r=0.02*(D1);
%q4=0.85;
%qs4=0.84;
Kt_4=2.14;
Kts_4=3;
Kf_4=1+(q4*(Kt_4-1));
Kfs_4=1+(qs4*(Kts_4-1));

%Calculating total moment for D1
Mxy_D1=52.964;
Mxz_D1=129.011;
Mtotal_D1=sqrt(((Mxz_D1)^2)+((Mxy_D1)^2));
fprintf('Mtotal_D1=%2.f N.m\n',Mtotal_D1)

%Torque is zero because of this part out of torque distribution area...
%So,We will calculate only alternating stress.There is no midpoint stress...
Sa_3=((32*(Kf_4*Mtotal_D1))/(pi*((D1*10^-3)^3)))*(10^-6);
Sm_3=(sqrt(3)*16*Kfs_4*(0))/(pi*((D1*10^-3)^3))*(10^-6);
fprintf('Sa_3=%2.f MPa\n',Sa_3)
fprintf('Sm_3=%2.f MPa\n',Sm_3)

%Calculating Nf_4 using goodman criteria
Nf_4=1/((Sa_3/Se_3)+(Sm_3/Sut));
fprintf('Nf_4=%2.f\n',Nf_4)

%Calculating Nf_Sy_4 using Yield Strength
Nf_Sy_4=(Sy/(Sa_3+Sm_3));
fprintf('Nf_Sy_4=%2.f\n',Nf_Sy_4)

if Nf_4 >=1.72 && Nf_Sy_4 >=1.72
    fprintf('These values are within the limits.\n')
else
    fprintf('Please,check D1 diameter..!\n')
end


%Calculating volume for each diameters
V_1=((pi*((D1*10^-3)^2))*(a*10^-3))/4;
V_2=((pi*((D2*10^-3)^2))*(b*10^-3))/4;
V_3=((pi*((D3*10^-3)^2))*(c*10^-3))/4;
V_4=((pi*((D4*10^-3)^2))*(d*10^-3))/4;

fprintf('V_1=%.6f kg/m^3\n',V_1)
fprintf('V_2=%.6f kg/m^3\n',V_2)
fprintf('V_3=%.6f kg/m^3\n',V_3)
fprintf('V_4=%.6f kg/m^3\n',V_4)

%Calculating mass of each diameters
m_1=rho*V_1;
m_2=rho*V_2;
m_3=rho*V_3;
m_4=rho*V_4;

fprintf('m_1=%.6f kg\n',m_1)
fprintf('m_2=%.6f kg\n',m_2)
fprintf('m_3=%.6f kg\n',m_3)
fprintf('m_4=%.6f kg\n',m_4)























