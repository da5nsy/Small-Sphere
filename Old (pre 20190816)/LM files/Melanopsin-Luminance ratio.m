%%-------------------------------------------------------------------------
%
%  Plot ratio between melanopsin and luminance responses for illuminants
%
%--------------------------------------------------------------------------

s1 = 341;               % number of values in 1nm spectrum 390-730 nm
lambda1 = 390:1:730;
s5 = 69;                % number of values in 5nm spectrum 390-730 nm
lambda5 = 390:5:730;
ciedir = fullfile('D:','Research at UCL','Colour standards','CIE colorimetric data');
cvrldir = fullfile('D:','Research at UCL','Colour standards','CVRL cone fundamentals');

% Read Stockman-Sharpe 10-deg cone fundamentals (390-730 nm in 1nm intervals)

ssfile = fullfile(cvrldir,'Stockman-Sharpe cone fundamentals - lin-10deg-1nm.txt');
format = '%d %f %f %f';
fid = fopen(ssfile,'r');
[Obs,count] = fscanf(fid,format,[4,inf]);  % read the whole file into array
fclose(fid);

Lambda = Obs(1,:);                 % extract cone response data fields
Lcone = Obs(2,1:s1);
Mcone = Obs(3,1:s1);               % data range 380-730nm
Scone = Obs(4,1:s1);

% Read 10-deg V(lambda) file

vfile = fullfile(ciedir,'CIE2008-V-10deg-1nm.txt');
format = '%d %f';
fid = fopen(vfile,'r');
[Obs,count] = fscanf(fid,format,[2,inf]);  % read the whole file into array
fclose(fid);
Vlambda = Obs(2,1:s1);          % data range 380-730nm

%  Read CIE daylight components file (380-780nm in 5nm intervals)

illfile = fullfile(ciedir,'CIE daylight components 380-730 5nm.txt');
format = '%d %f %f %f';
fid = fopen(illfile,'r');
[D,count] = fscanf(fid,format,[4,inf]);  % read the whole file into array D
fclose(fid);

S0 = D(2,3:s5+2);                 % extract component data 390-730 nm
S1 = D(3,3:s5+2);
S2 = D(4,3:s5+2);

% Read D65 illuminant spectrum file (380-800nm in 1nm intervals)

spec1count = 401;
D65 = zeros(1,spec1count,'double');

illfile = fullfile('D:','Research at UCL','Colour standards',...
                   'CIE colorimetric data','Illuminant-D65-1nm.txt');
format = '%d %f';
fid = fopen(illfile,'r');
[D,count] = fscanf(fid,format,[2,inf]);  % read the whole file into array D
fclose(fid);

D65 = D(2,11:351);             % extract D65 data 390-730 nm
clear D;

% Read standard observer CMFs (1nm intervals)

cmffile = fullfile('D:','Research at UCL','Colour standards',...
    'CIE colorimetric data','StdObs-2deg-1nm.txt');
format = '%d %f %f %f';
fid = fopen(cmffile, 'r');
[A,count] = fscanf(fid, format, [4, inf]);  % read the whole file into array A
fclose(fid);

len = count/4;
Xcmf = A(2,11:351);                   % extract data 390-730 nm
Ycmf = A(3,11:351);
Zcmf = A(4,11:351);
clear A

%% Synthesise photopigment shape for melanopsin (Stockman-Sharpe formula)

%mfile = fullfile(cvrldir,'Melanopsin-1nm.txt');
%format = '%d %f';
%fid = fopen(mfile,'r');
%[Obs,count] = fscanf(fid,format,[2,inf]);  % read the whole file into array
%fclose(fid);
%Mel = Obs(2,1:s1);              % data range 390-730nm

loga = zeros(s1,1,'double');

a = -188862.970810906644;
b = 90228.966712600282;
c = -2483.531554344362;
d = -6675.007923501414;
e = 1813.525992411163;
f = -215.177888526334;
g = 12.487558618387;
h = -0.28954150059;

for lambda = 390:730                      % 390 - 730 nm
  lam = lambda-389;
  x = log10(lambda)-log10(480/558);      % shift to max at 480 nm
  loga(lam) = a+b*x^2+c*x^4+d*x^6+e*x^8+f*x^10+g*x^12+h*x^14;
end
Melpig = 10.^loga;                  % melanopsin pigment

% Read lens density file

lensfile = fullfile(cvrldir,'CVRL lensss_1.txt');
format = '%d %f';
fid = fopen(lensfile,'r');
[Obs,count] = fscanf(fid,format,[2,inf]);  % read the whole file into array
fclose(fid);

Ldens = Obs(2,:);                   % density  D = log10(1/T)
Ltrans = 1./(10.^Ldens);            % transmittance T = 1/10^D

[m,mi] = max(Melpig);
Mel = Melpig.*Ltrans';
%Mel = Mel/max(Mel);
[md,mdi] = max(Mel);
fprintf('Melanopsin unfiltered maximum at %d nm, filtered at %d\n',mi+389,mdi+389);

% Plot curves

figure;  hold on;
title('Melanopsin responsivity and lens density');
plot(lambda1,Ltrans,'--k');
plot(lambda1,Melpig,'-k');
plot(lambda1,Mel,'-c','LineWidth',1.5);
legend('Lens density','Melanopsin pigment','Melanopsin filtered','Location','East');
xlabel('Wavelength (nm)');
ylabel('Relative sensitivity');
axis([390,730,0,1]);

%% Plot cone fundamentals and Mel

Mel = Mel/max(Mel);

figure;  hold on;
%title('CVRL cone fundamentals, Vlambda and melanopsin');
title('CVRL cone fundamentals and melanopsin');
plot(lambda1,Lcone,'-r');
plot(lambda1,Mcone,'-g');
plot(lambda1,Scone,'-b');
%plot(lambda1,Vlambda,'-k');
plot(lambda1,Mel,'-c','LineWidth',1.5);
legend('L cone','M cone','S cone','Melanopsin');
%legend('L cone','M cone','S cone','V lambda','Melanopsin');
xlabel('Wavelength (nm)');
ylabel('Relative sensitivity');
xlim([390,730]);
ylim([0,1.01]);

% Plot region covered by 488nm notch filter

grey = [0.7,0.7,0.7];
filtm = 488;  filtw = 24.4;
filtmin = filtm-filtw/2;
filtmax = filtm+filtw/2;
for k = 0:ceil(filtw)
  f = filtmin+k;
  plot([f,f],[0,1],'Color',grey);
end

%% Calculate ratio of power after filtering
%
% Edmund Optics notch filter 488+/-12nm, blocking range 476-500nm inclusive

trmax = 0.93;                     % maximum transmittance factor of filter
fmin = 87;   fmax = 111;          % index number for min/max filtere wavelengths
Lf = Lcone;  Lf(fmin:fmax) = 0;   % apply filter
Mf = Mcone;  Mf(fmin:fmax) = 0;
Sf = Scone;  Sf(fmin:fmax) = 0;
Vf = Vlambda; Vf(fmin:fmax) = 0;
Melf = Mel;  Melf(fmin:fmax) = 0;
lr = sum(Lf)/sum(Lcone);          % calculate ratio
mr = sum(Mf)/sum(Mcone);
sr = sum(Sf)/sum(Scone);
vr = sum(Vf)/sum(Vlambda);
melr = sum(Melf)/sum(Mel);
fprintf('Filter ratios:  L,M,S,V = %5.3f,%5.3f,%5.3f,%5.3f  Mel %5.3f\n',...
    lr,mr,sr,vr,melr);
fprintf('Inverse ratios:  L,M,S = %5.3f,%5.3f,%5.3f\n',1/lr,1/mr,1/sr);

% Construct filter for colorimetric equivalent of notch filter

Comp = ones(1,length(lambda1),'double');
Comp = Comp-(1-lr)*Lcone;         % multiply each response 
Comp = Comp-(1-mr)*Mcone;
Comp = Comp-(1-sr)*Scone;
figure;  hold on
title('Colorimetric equivalent of notch filter');
%plot([min(lambda1),max(lambda1)],[trmax,trmax],'-k');
plot(lambda1,trmax*Comp,'-b');
xlim([380,730]);  ylim([0.7,1.01]);
xlabel('Wavelength (nm)');
ylabel('Transmittance factor');

%% Calculate CIELAB values of filter

X65 = sum(D65.*Xcmf)/sum(Xcmf);
Y65 = sum(D65.*Ycmf)/sum(Ycmf);
Z65 = sum(D65.*Zcmf)/sum(Zcmf);
D65comp = D65.*Comp*trmax;                 % compensating filter
Xf = sum(D65comp.*Xcmf)/sum(Xcmf);
Yf = sum(D65comp.*Ycmf)/sum(Ycmf);
Zf = sum(D65comp.*Zcmf)/sum(Zcmf);
[L A B] = XYZtoLAB(Xf,Yf,Zf,X65,Y65,Z65);  % convert to LAB

fprintf('LAB of filter rel to D65 = %4.1f, %4.2f, %4.2f\n',L,A,B);

%% Test equivalence of filtration on D65

D65notch = D65;  D65notch(fmin:fmax) = 0;  % notch filter
D65comp = D65.*Comp;                       % compensating filter
figure;  hold on
title('Equivalent illumination');
plot(lambda1,D65notch,'-k');
plot(lambda1,D65comp,'-b');
legend('D65 with notch filter','D65 with metameric filter');
xlabel('Wavelength (nm)');
ylabel('Power');

L1 = sum(D65comp.*Lcone);  L2 = sum(D65notch.*Lcone);
M1 = sum(D65comp.*Mcone);  M2 = sum(D65notch.*Mcone);
S1 = sum(D65comp.*Scone);  S2 = sum(D65notch.*Scone);

%% Calculate coefficients for correlated colour temperature

tmin = 2500;
temprange = tmin:50:10000;
tc = size(temprange,2);

SPD1 = zeros(s1,tc,'double');   % array of colour temperatures

for CCT = temprange
  t = (CCT-(tmin-50))/50;        % array index
  
  if (CCT < 7000)
    xd = -4.607*10^9/(CCT^3) + 2.9678*10^6/(CCT^2) + 0.09911*10^3/CCT + 0.244063;
  else
    xd = -2.0064*10^9/(CCT^3) + 1.9018*10^6/(CCT^2) + 0.24748*10^3/CCT + 0.23704;
  end

  yd = -3*(xd^2) + 2.87*xd - 0.275;

  M1 = (-1.3515-1.7703*xd + 5.9114*yd) / (0.0241+0.2562*xd - 0.7341*yd);
  M2 = ( 0.03-31.4424*xd + 30.0717*yd) / (0.0241+0.2562*xd - 0.7341*yd);

  SPD5 = S0 + M1*S1 + M2*S2;                     % synthesise SPD for daylight
  SPD1(:,t) = interp1(lambda5,SPD5,lambda1);     % interpolate to 1nm intervals
end

%% Take product of melanopsin-luminance and daylight spectra

Vn = Vlambda'/max(Vlambda);
Mn = Mel/max(Mel);
Dn = (Mn-Vn)';                          % difference vector

figure;  hold on;
plot([390 730],[0 0],':k');
xlabel('Wavelength (nm)');
ylabel('Relative response (M-V)');
plot(lambda1,Vn,'-k');
plot(lambda1,Mn,'-c');
plot(lambda1,SPD1(:,81)/100,'-r');

figure;  hold on;
plot([390 730],[0 0],':k');
xlabel('Wavelength (nm)');
ylabel('Relative response (M-V)');
for t = 1:tc
  plot(lambda1,Dn.*SPD1(:,t),'-k');     % plot product 
end
plot(lambda1,Dn.*SPD1(:,81),'-r');      % overplot D65 in red
title('CCT range 4K - 10K');

%% Response of M and V to equi-energy illumination

Ill_E = ones(s1,1,'double');

ME = sum(Mn.*Ill_E);           % dot product over spectrum
VE = sum(Vn'.*Ill_E);
MVE = ME/VE;                    % ratio 

% Plot integrated response against colour temperature

for t = 1:tc
  Resp(t) = sum(Dn.*SPD1(:,t));         % integrate as summation 
end

figure;  hold on;
plot([tmin 10000],[0 0],':k');
xlabel('Correlated colour temperature (K)');
ylabel('Integrated Y-B response relative to D65');
plot(temprange,-Resp/Resp(81),'-k');        % plot response relative to D65

%%  Read illuminant F series spectra (380-780nm in 5nm intervals)

T = zeros(13,s5,'double');
F5 = zeros(s5,1,'double');
Ill_F = zeros(s1,12,'double');
Ill_CCTF = [6428 4224 3462 2938 6343 4148 6495 4997 4149 4988 3999 3000];

illfile = fullfile(ciedir,'Illuminant-F-5nm.txt');
format = '%d %f %f %f %f %f %f %f %f %f %f %f %f';
fid = fopen(illfile,'r');
[T,count] = fscanf(fid,format,[13,inf]);   % read the whole file into array T
fclose(fid);

for n = 1:12
  F5 = T(n+1,1:s5)';                                  % extract F data 380-780 nm
  Ill_F(:,n) = interp1(lambda5,F5,lambda1,'spline');  % interpolate 1nm intervals
end

figure;  hold on;
for n = 1:12
  plot(lambda1,Ill_F(:,n),'-k');
end

%% Read SPDs of sources measured with TSR

s4 = 89;
lambda4 = 380:4:732;
Ill_TSR = zeros(7,s1,'double');
Ill_name = {'tp24' 'Pharox' 'Osram' 'ProLite' 'Philips' 'Bell' 'QeeQ'};
Ill_CCT = [3081 3003 2994 6459 2633 2253 2640];   % pre-calculated CCT

illfile = fullfile('C:','Research at UCL','Colour standards',...
            'TSR measurements','PhotoResearch PR650','Light Sources.txt');            

format = '%d %f %f %f %f %f %f %f';
fid = fopen(illfile,'r');
[T,count] = fscanf(fid,format,[8,inf]);  % read the whole file into array T
fclose(fid);

for n = 1:7
  T4 = T(n+1,1:s4);                         % extract 4nm data 380-780 nm
  Ill_TSR(n,:) = interp1(lambda4,T4,lambda1,'spline');   % interpolate 1nm intervals
end

%% Ratio of M and V responses to each daylight spectrum

MD = zeros(tc,1,'double');
VD = zeros(tc,1,'double');
MVratio = zeros(tc,1,'double');

for t = 1:tc
  MD(t) = sum(Mn.*SPD1(:,t)');          % dot product over spectrum
  VD(t) = sum(Vn.*SPD1(:,t)');
  MVratio(t) = (MD(t)/VD(t))/MVE;             % ratio  
end

figure;  hold on;
xlabel('CCT');
ylabel('M/V ratio');
plot(temprange,MVratio,'-r');            % plot ratio
plot([tmin 10000],[1 1],':k');

%% Calculate and plot MVratio for CIE F series light sources

MVfl = zeros(12,1,'double');

for n = 1:12
  Mfl = sum(Mn'.*Ill_F(:,n));             % dot product over spectrum
  Vfl = sum(Vn'.*Ill_F(:,n));
  MVfl(n) = (Mfl/Vfl)/MVE;               % ratio  
end

for n = 1:12
  x = Ill_CCTF(n);
  y = MVfl(n);
  plot(x,y,'xb');                        % plot individual sources
  text(x+50,y,sprintf('F%d',n));
end

%% Calculate and plot MVratio for measured light sources

MVill = zeros(7,1,'double');

for n = 1:7
  Mill = sum(Mn.*Ill_TSR(n,:));             % dot product over spectrum
  Vill = sum(Vn.*Ill_TSR(n,:));
  MVill(n) = (Mill/Vill)/MVE;               % ratio  
end

for n = 1:7
  x = Ill_CCT(n);
  y = MVill(n);
  plot(x,y,'xk');                           % plot individual sources
  text(x+50,y,Ill_name{n});
end
