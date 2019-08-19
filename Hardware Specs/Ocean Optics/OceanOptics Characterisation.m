%% Written to obtain calibrated spectral/colorimetric data from Ocean Optics USB2000+
% Using calibration data taken from CD provided with HL lamp

%% Load Data

clc, clear, close all

rootdir = 'C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Hardware Specs\Ocean Optics';
cd(rootdir)

try
    load('OceanOptics Characterisation.mat')
    
catch %if the above file isn't available, create data set from excel
    filename=fullfile(rootdir,'OceanOptics Characterisation.xlsx');
    Data_HL_cal  = xlsread(filename, 1,'A1:D25');
    Data_HL_on   = xlsread(filename, 2,'A2:B2049');
    Data_HL_off  = xlsread(filename, 3,'A2:B2049');
    Data_SPH_off = xlsread(filename, 4,'A2:B2049');
    Data_SPH_RB  = xlsread(filename, 5,'A2:B2049');
    Data_SPH_UVA = xlsread(filename, 6,'A2:B2049');
    save('OceanOptics Characterisation.mat')
end


%% Dark field correction
Data_HL_dfc       =   Data_HL_on(:,2)-Data_HL_off(:,2);
Data_SPH_RB_dfc   =   Data_SPH_RB(:,2)-Data_SPH_off(:,2);
Data_SPH_UVA_dfc  =   Data_SPH_UVA(:,2)-Data_SPH_off(:,2);

% figure, hold on, 
% plot(Data_HL_on(:,1),Data_HL_on(:,2))
% plot(Data_HL_on(:,1),Data_HL_dfc)
% 
% figure, hold on, 
% plot(Data_SPH_RB(:,1),Data_SPH_RB(:,2))
% plot(Data_SPH_RB(:,1),Data_SPH_RB_dfc)
% 
% figure, hold on, 
% plot(Data_SPH_UVA(:,1),Data_SPH_UVA(:,2))
% plot(Data_SPH_UVA(:,1),Data_SPH_UVA_dfc)

%% interpolate lamp calibration data

Data_HL_cal_interp=zeros(2048,4); %pre-allocation
Data_HL_cal_interp(:,1)=Data_HL_off(:,1); %lambda
Data_HL_cal_interp(:,3)=Data_HL_off(:,1); %lambda 
%(sticking to 4 columns to mimic Data_HL_cal)

Data_HL_cal_interp(29:end,2) = ...  %from 29 bc HL_cal starts at 350nm, (:,2) = Cosine corrector
    interp1(Data_HL_cal(:,1),...    %lambda in original
    Data_HL_cal(:,2),...            %power in original
    Data_HL_off(29:end,1),...       %lambda in new
    'spline');

Data_HL_cal_interp(29:end,4) = ...  %(:,4) = bare optical fibre
    interp1(Data_HL_cal(:,3),...    %lambda in original
    Data_HL_cal(:,4),...            %power in original
    Data_HL_off(29:end,1),...       %lambda in new
    'spline');

figure, hold on
plot(Data_HL_cal(:,1),Data_HL_cal(:,2),'o')
plot(Data_HL_cal_interp(:,1),Data_HL_cal_interp(:,2))

figure, hold on
plot(Data_HL_cal(:,3),Data_HL_cal(:,4),'o')
plot(Data_HL_cal_interp(:,3),Data_HL_cal_interp(:,4))

%% Create correction vector
correction_vector=zeros(2048,1); 
correction_vector = Data_HL_cal_interp(:,4)./Data_HL_dfc;
figure,
plot(correction_vector)
%save('correction vector','correction_vector')

%differences if 
%Data_HL_cal_interp(:,4) (nomimally bare fibre)
%replaced with
%Data_HL_cal_interp(:,2) (nominally Cosine corrected)

%% Apply correction vector to SPH data

Data_SPH_RB_cor     =Data_SPH_RB_dfc.*correction_vector;
Data_SPH_UVA_cor    =Data_SPH_UVA_dfc.*correction_vector;

figure, hold on
plot(Data_HL_off(:,1),Data_SPH_RB_dfc./max(Data_SPH_RB_dfc),'b');
plot(Data_HL_off(:,1),Data_SPH_RB_cor./max(Data_SPH_RB_cor),'r');
axis([300 1100 -.5 1])

figure, hold on
plot(Data_HL_off(:,1),Data_SPH_UVA_dfc./max(Data_SPH_UVA_dfc),'b');
plot(Data_HL_off(:,1),Data_SPH_UVA_cor./max(Data_SPH_UVA_cor),'r');
axis([300 1100 -.5 1])

figure, hold on
plot(Data_HL_off(:,1),Data_SPH_RB_cor,'r'); %tiwce for stripy graph
plot(Data_HL_off(:,1),Data_SPH_RB_cor,'b--');

plot(Data_HL_off(:,1),Data_SPH_UVA_cor,'b');
plot(Data_HL_off(:,1),Data_SPH_UVA_cor,'y--');
axis([350 700 -.1 1.5]);

%% split LEDs
Data_LEDred=zeros(size(Data_SPH_RB_cor));
Data_LEDred(565:920)=Data_SPH_RB_cor(565:920); %550:675nm

Data_LEDblue=zeros(size(Data_SPH_RB_cor));
Data_LEDblue(226:565)=Data_SPH_RB_cor(226:565); %425:550nm

Data_LEDamber=zeros(size(Data_SPH_UVA_cor));
Data_LEDamber(565:847)=Data_SPH_UVA_cor(565:847); %550:650nm

Data_LEDuv=zeros(size(Data_SPH_UVA_cor));
Data_LEDuv(81:360)=Data_SPH_UVA_cor(81:360); %370:475nm

figure, hold on, 
plot(Data_HL_off(:,1),Data_LEDred/max(Data_LEDred),'r');
plot(Data_HL_off(:,1),Data_LEDblue/max(Data_LEDblue),'b');
plot(Data_HL_off(:,1),Data_LEDamber/max(Data_LEDamber),'y');
plot(Data_HL_off(:,1),Data_LEDuv/max(Data_LEDuv),'Color',[0.5,0,0.5]);

xlim([350 700])
xlabel('Wavlength (nm)')
ylim([0 1])
yticks(ylim)
ylabel('Normalised SPD')

%save2pdf('LED_SPDs')
%% Calculate chromaticity

%load CIE data
ciefile = fullfile('C:','Users','cege-user','Dropbox','UCL','Data',...
    'Colour Standards','CIE colorimetric data','CIE_colorimetric_tables.xls');
ciedata= xlsread(ciefile,'1964 col observer','A6:D86');
% figure, plot(ciedata(:,1),ciedata(:,2),...
%     ciedata(:,1),ciedata(:,3),
%     ciedata(:,1),ciedata(:,4))
% legend('show')
cielambda=ciedata(:,1);
xbar=ciedata(:,2);
ybar=ciedata(:,3);
zbar=ciedata(:,4);

xbar_int=zeros(2048,1);
xbar_int(107:1231)= interp1(cielambda,xbar,Data_HL_off(107:1231,1));
ybar_int=zeros(2048,1);
ybar_int(107:1231)= interp1(cielambda,ybar,Data_HL_off(107:1231,1));
zbar_int=zeros(2048,1);
zbar_int(107:1231)= interp1(cielambda,zbar,Data_HL_off(107:1231,1));

RB_XYZ=zeros(3,1);
RB_XYZ(1)=xbar_int'*Data_SPH_RB_cor;
RB_XYZ(2)=ybar_int'*Data_SPH_RB_cor;
RB_XYZ(3)=zbar_int'*Data_SPH_RB_cor;
RB_xy(1)=RB_XYZ(1)/sum(RB_XYZ);
RB_xy(2)=RB_XYZ(2)/sum(RB_XYZ);

UVA_XYZ=zeros(3,1);
UVA_XYZ(1)=xbar_int'*Data_SPH_UVA_cor;
UVA_XYZ(2)=ybar_int'*Data_SPH_UVA_cor;
UVA_XYZ(3)=zbar_int'*Data_SPH_UVA_cor;
UVA_xy(1)=UVA_XYZ(1)/sum(UVA_XYZ);
UVA_xy(2)=UVA_XYZ(2)/sum(UVA_XYZ);

figure, hold on
drawChromaticity('1931') % github.com/da5nsy/General

scatter(RB_xy(1),RB_xy(2),'r')
text(RB_xy(1),RB_xy(2),'RB')
scatter(UVA_xy(1),UVA_xy(2),'b')
text(UVA_xy(1),UVA_xy(2),'UVA')

%% Calculate chromaticity of indvidual channels

%load CIE data
ciefile = fullfile('C:','Users','cege-user','Dropbox','UCL','Data',...
    'Colour Standards','CIE colorimetric data','CIE_colorimetric_tables.xls');
ciedata= xlsread(ciefile,'1964 col observer','A6:D86');
% figure, plot(ciedata(:,1),ciedata(:,2),...
%     ciedata(:,1),ciedata(:,3),
%     ciedata(:,1),ciedata(:,4))
% legend('show')
cielambda=ciedata(:,1);
xbar=ciedata(:,2);
ybar=ciedata(:,3);
zbar=ciedata(:,4);

xbar_int=zeros(2048,1);
xbar_int(107:1231)= interp1(cielambda,xbar,Data_HL_off(107:1231,1));
ybar_int=zeros(2048,1);
ybar_int(107:1231)= interp1(cielambda,ybar,Data_HL_off(107:1231,1));
zbar_int=zeros(2048,1);
zbar_int(107:1231)= interp1(cielambda,zbar,Data_HL_off(107:1231,1));
R_XYZ=zeros(3,1);
R_XYZ(1)=xbar_int'*Data_LEDred;
R_XYZ(2)=ybar_int'*Data_LEDred;
R_XYZ(3)=zbar_int'*Data_LEDred;
R_xy(1)=R_XYZ(1)/sum(R_XYZ);
R_xy(2)=R_XYZ(2)/sum(R_XYZ);

B_XYZ=zeros(3,1);
B_XYZ(1)=xbar_int'*Data_LEDblue;
B_XYZ(2)=ybar_int'*Data_LEDblue;
B_XYZ(3)=zbar_int'*Data_LEDblue;
B_xy(1)=B_XYZ(1)/sum(B_XYZ);
B_xy(2)=B_XYZ(2)/sum(B_XYZ);

A_XYZ=zeros(3,1);
A_XYZ(1)=xbar_int'*Data_LEDamber;
A_XYZ(2)=ybar_int'*Data_LEDamber;
A_XYZ(3)=zbar_int'*Data_LEDamber;
A_xy(1)=A_XYZ(1)/sum(A_XYZ);
A_xy(2)=A_XYZ(2)/sum(A_XYZ);

U_XYZ=zeros(3,1);
U_XYZ(1)=xbar_int'*Data_LEDuv;
U_XYZ(2)=ybar_int'*Data_LEDuv;
U_XYZ(3)=zbar_int'*Data_LEDuv;
U_xy(1)=U_XYZ(1)/sum(U_XYZ);
U_xy(2)=U_XYZ(2)/sum(U_XYZ);

figure, hold on
drawChromaticity('1931')

plot([U_xy(1),A_xy(1)],[U_xy(2),A_xy(2)],'k')
plot([R_xy(1),B_xy(1)],[R_xy(2),B_xy(2)],'k')

scatter(R_xy(1),R_xy(2),'r','filled')
text(R_xy(1)+.03,R_xy(2),'R')
scatter(B_xy(1),B_xy(2),'b','filled')
text(B_xy(1)+.03,B_xy(2),'B')
scatter(A_xy(1),A_xy(2),'y','filled')
text(A_xy(1)+.03,A_xy(2),'A')
scatter(U_xy(1),U_xy(2),[],[0.5,0,0.5],'filled')
text(U_xy(1)+.03,U_xy(2),'U')

save led_xy.mat R_xy B_xy A_xy U_xy ;

%save2pdf('LED_cross')
