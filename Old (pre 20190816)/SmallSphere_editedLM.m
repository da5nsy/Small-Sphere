%% Plots for Lindsay
clc, clear, close all

%Modify as required:
baselineFolderLocation=fullfile('F:','Research at UCL','Students',...
    'Danny Garside','Experiment','Small Sphere results');

%% Load CIE data
ciefile = fullfile(baselineFolderLocation,'CIE_colorimetric_tables.xls');

ciedata2= xlsread(ciefile,'1931 col observer','A6:D86');
lambdaCie2=ciedata2(:,1);
xbar2=ciedata2(:,2);
ybar2=ciedata2(:,3);
zbar2=ciedata2(:,4);
lambdaCie21=lambdaCie2(1):lambdaCie2(length(lambdaCie2));
xbar21 = interp1(lambdaCie2,xbar2,lambdaCie21,'spline')';
ybar21 = interp1(lambdaCie2,ybar2,lambdaCie21,'spline')';
zbar21 = interp1(lambdaCie2,zbar2,lambdaCie21,'spline')';
xb21 = xbar21./(xbar21+ybar21+zbar21);
yb21 = ybar21./(xbar21+ybar21+zbar21);

ciedata10= xlsread(ciefile,'1964 col observer','A6:D86');
lambdaCie10=ciedata10(:,1);
xbar10=ciedata10(:,2);
ybar10=ciedata10(:,3);
zbar10=ciedata10(:,4);
lambdaCie1=lambdaCie10(1):lambdaCie10(length(lambdaCie10));
xbar1 = interp1(lambdaCie10,xbar10,lambdaCie1,'spline')';
ybar1 = interp1(lambdaCie10,ybar10,lambdaCie1,'spline')';
zbar1 = interp1(lambdaCie10,zbar10,lambdaCie1,'spline')';
xb1 = xbar1./(xbar1+ybar1+zbar1);
yb1 = ybar1./(xbar1+ybar1+zbar1);

%Load melanopsin data
melfile=fullfile(baselineFolderLocation,'Melanopsin response.xlsx');
mel = xlsread(melfile,'Data','E3:E73');
lambdaMel=(380:5:730)';

%% Colorimetric Cross

LEDs =   [467,401,631,594];
spread = 20;           %1 for monochromatic, 20 for realistic values,
range =  [500,600];    %Range over which a contender for LED_4 will be sought

%Create LED SPDs
LED_1 = gaussmf(lambdaCie10,[spread LEDs(1)]);
LED_2 = gaussmf(lambdaCie10,[spread LEDs(2)]);
LED_3 = gaussmf(lambdaCie10,[spread LEDs(3)]);
LED_4 = gaussmf(lambdaCie10,[spread LEDs(4)]);

%Calculate XYZ for LEDs
LED_1_XYZ=[xbar10'*LED_1,ybar10'*LED_1,zbar10'*LED_1];
LED_2_XYZ=[xbar10'*LED_2,ybar10'*LED_2,zbar10'*LED_2];
LED_3_XYZ=[xbar10'*LED_3,ybar10'*LED_3,zbar10'*LED_3];
LED_4_XYZ=[xbar10'*LED_4,ybar10'*LED_4,zbar10'*LED_4];

%Calculate xy for LEDs
LED_1_xy=[LED_1_XYZ(1)/sum(LED_1_XYZ),LED_1_XYZ(2)/sum(LED_1_XYZ)];
LED_2_xy=[LED_2_XYZ(1)/sum(LED_2_XYZ),LED_2_XYZ(2)/sum(LED_2_XYZ)];
LED_3_xy=[LED_3_XYZ(1)/sum(LED_3_XYZ),LED_3_XYZ(2)/sum(LED_3_XYZ)];
LED_4_xy=[LED_4_XYZ(1)/sum(LED_4_XYZ),LED_4_XYZ(2)/sum(LED_4_XYZ)];

%Intersection point
x1 = LED_1_xy(1);  x2 = LED_2_xy(1);  x3 = LED_3_xy(1);  x4 = LED_4_xy(1);
y1 = LED_1_xy(2);  y2 = LED_2_xy(2);  y3 = LED_3_xy(2);  y4 = LED_4_xy(2);
m1 = (y3-y1)/(x3-x1);  m2 = (y4-y2)/(x4-x2);
xc = (y2-y1+m1*x1-m2*x2)/(m1-m2);  yc = m1*(xc-x1)+y1;

%Plot CIE1964, with LED chromaticies
figure; hold on;  axis square
plot([xb1;xb1(1)],[yb1;yb1(1)],'k');
xlim([0,0.8]); ylim([0,0.9]);
scatter(LED_1_xy(1),LED_1_xy(2),'k*');
scatter(LED_2_xy(1),LED_2_xy(2),'k*');
scatter(LED_3_xy(1),LED_3_xy(2),'k*');
scatter(LED_4_xy(1),LED_4_xy(2),'k*');
scatter(xc,yc,'ko');

%Annotate plot
title('CIE1931 chromaticity diagram');xlabel('x'); ylabel('y');
text(LED_1_xy(1)-0.07,LED_1_xy(2),num2str(LEDs(1)));
text(LED_2_xy(1)-0.07,LED_2_xy(2),num2str(LEDs(2)));
text(LED_3_xy(1)+0.02,LED_3_xy(2)+0.02,num2str(LEDs(3)));
text(LED_4_xy(1)+0.02,LED_4_xy(2)+0.02,num2str(LEDs(4)));

%Add line between LED1 and LED3
plot([LED_1_xy(1),LED_3_xy(1)],[LED_1_xy(2),LED_3_xy(2)],'k');

%Add line between LED2 and LED4
plot([LED_2_xy(1),LED_4_xy(1)],[LED_2_xy(2),LED_4_xy(2)],'k');

col=[0.6,0.6,0.9];          % muted blue

for i=range(1):10:range(2)
    
    % Define LED_4, and its mel contributions at different wavelengths
    LED_4 =     gaussmf(lambdaMel,[spread i]);
    LED_4_81 =  gaussmf(lambdaCie10,[spread i]);
    LED_4_mel(i)=mel'*LED_4;
    
    LED_4_XYZ=  [xbar10'*LED_4,ybar10'*LED_4,zbar10'*LED_4];
    LED_4_xy=   [LED_4_XYZ(1)/sum(LED_4_XYZ),LED_4_XYZ(2)/sum(LED_4_XYZ)];
    
    plot(LED_4_xy(1),LED_4_xy(2),'o','Color',col);
    if mod(i,10)==0
        text((LED_4_xy(1)*1.25)-0.1,LED_4_xy(2)*1.06,num2str(i),'Color',col);
    end
    
    plot([LED_2_xy(1),LED_4_xy(1)],[LED_2_xy(2),LED_4_xy(2)],'Color',col);
end

%% LED SPDs, and mel

%Measured with Ocean Optics USB2000+
load(fullfile(baselineFolderLocation,'LED_SPDs.mat'));

figure, hold on
plot(lambdaOO,Data_LEDred/max(Data_LEDred),'r');
plot(lambdaOO,Data_LEDblue/max(Data_LEDblue),'Color',[0,0.5,1]);
plot(lambdaOO,Data_LEDamber/max(Data_LEDamber),'Color',[1,0.6,0]);
plot(lambdaOO,Data_LEDuv/max(Data_LEDuv),'Color',[0.6,0,1]);
plot(lambdaMel,mel/max(mel),'--','Color',[0.6,0.6,0.6],'LineWidth',1);
xlabel('Wavelength(nm)');
ylabel('Relative power');
axis([370 730 0 1])

%% Graph with some results from small sphere

cd(fullfile(baselineFolderLocation,'Trial Data'));
files= dir('*.mat');

N = 30;                             % number of repetitions over time
LN = 5;                             % number of lightness levels per repeat

for j=1:length(files)
    
    load(fullfile(baselineFolderLocation,'Trial Data',files(j).name));  % load experimental results
    files(j).dataLAB=LABmatch;
    files(j).dataRGB=RGBmatch;
    files(j).RGBstart=RGBstart;
    files(j).Tmatch=Tmatch;
    
end

%Calibrate data
for trial=1:length(files)
    
    %load calibration file
    calFileLocation=fullfile(baselineFolderLocation,'PR650',files(trial).name(end-8:end-4),...
        'Large LCD display measurement.mat');
    load(calFileLocation)
    
    %interpolate recorded values (sval) to required vals (0:1:255)
    XYZinterp=zeros(3,256,4);
    for i=1:3
        for j=1:4
            XYZinterp(i,:,j)=interp1(sval,XYZ(i,:,j),0:255,'spline');
        end
    end
   
    
    %Interp screen spectral data to same interval as CIE data
    RGBw_SPD = zeros(length(lambdaCie2),1,'double');
    RGBb_SPD = zeros(length(lambdaCie2),1,'double');
    
    RGBw_SPD = interp1(lambda,Measurement(:,21,4),lambdaCie2,'spline');
    RGBb_SPD = interp1(lambda,Measurement(:,1,4),lambdaCie2,'spline');   
    
    Norm = 100/sum(RGBw_SPD.*ybar2);              % normalising factor
    
    DB = squeeze(RGBb_SPD);
    Xb = sum(RGBb_SPD.*xbar2)*Norm;
    Yb = sum(RGBb_SPD.*ybar2)*Norm;               % calculate white reference
    Zb = sum(RGBb_SPD.*zbar2)*Norm;
    %fprintf('%s Display black XYZ = %5.3f,%5.3f,%5.3f\n',files(trial).name(end-8:end-4),Xb,Yb,Zb);
    
    Xw = sum(RGBw_SPD.*xbar2)*Norm;
    Yw = sum(RGBw_SPD.*ybar2)*Norm;               % calculate white reference
    Zw = sum(RGBw_SPD.*zbar2)*Norm;
    xw = Xw/(Xw+Yw+Zw);  yw = Yw/(Xw+Yw+Zw);
    %fprintf('%s Display white XYZ = %5.3f,%5.3f,%5.3f  xy = %6.4f,%6.4f\n',...
    %    files(trial).name(end-8:end-4),Xw,Yw,Zw,xw,yw);  
    
    for j=1:3
        % Thresholding:
        % - original RGB values included out of gamut
        % selections, resulting in above 1 and below 0 values

        a=files(trial).dataRGB(j,:,:); %Create temporary variable
        a(files(trial).dataRGB(j,:,:)>1)=1; % Threshold to below 1
        a(files(trial).dataRGB(j,:,:)<0)=0; % Threshold to above 0
        files(trial).dataRGBcal(j,:,:)=uint8(a*255); %Rescale
        %dataRGBcal is not actually 'calibrated', perhaps innappropriate
        %naming

        files(trial).dataRGBcalgam(j,:,:)=files(trial).dataRGB(j,:,:)>1 ...
            |files(trial).dataRGB(j,:,:)<0;

    end
    
    files(trial).dataXYZ=zeros(3,LN,N);
    files(trial).dataxy=zeros(2,LN,N);
    files(trial).dataLABcal=zeros(3,LN,N);
    
    for j=1:LN
        for k=1:N
            files(trial).dataXYZ(:,j,k)=...
                (XYZinterp(:,files(trial).dataRGBcal(1,j,k)+1,1)...
                +XYZinterp(:,files(trial).dataRGBcal(2,j,k)+1,2)...
                +XYZinterp(:,files(trial).dataRGBcal(3,j,k)+1,3));
            
            files(trial).dataxy(1,j,k)=...
                files(trial).dataXYZ(1,j,k)/sum(files(trial).dataXYZ(:,j,k));
            files(trial).dataxy(2,j,k)=...
                files(trial).dataXYZ(2,j,k)/sum(files(trial).dataXYZ(:,j,k));
            
            xyz = files(trial).dataXYZ(:,j,k);
            [L,A,B] = XYZtoLAB(xyz(1),xyz(2),xyz(3),Xw,Yw,Zw);
            files(trial).dataLABcal(:,j,k)=[L,A,B];
        end
    end
end

%Plot data
obs = 'DG';       %'DG'/'HC'/'LW' can be used instead
markerSize = 25;
rbcol = [0,0.5,1];  aucol = [0.2,0.2,0.2];

figure, hold on;  rotate3d
plot([xb1;xb1(1)],[yb1;yb1(1)],'k');
%xlim([0.2,0.4]); ylim([0.2,0.4]);    
axis([0,1,0,1]);

for i = 1:length(files)
    for j = 1:LN
        if (strcmp(files(i).name(end-8:end-7),obs) || (strcmp(obs,'ALL')))
            x = squeeze(files(i).dataxy(1,j,:));
            y = squeeze(files(i).dataxy(2,j,:));
            Y = squeeze(files(i).dataXYZ(2,j,:));
            if strcmp(files(i).name(end-5:end-4),'RB')
                sc1 = scatter3(x,y,Y,markerSize,rbcol,'filled');
            elseif strcmp(files(i).name(end-5:end-4),'AU')
                sc2 = scatter3(x,y,Y,markerSize,aucol,'filled');
            end
        end
    end
end

plot3(xw,yw,65,'ok','MarkerFaceColor','w','MarkerSize',7);   % display white point
%title(sprintf('Observer: %s. CIE 1931 2deg obs',obs))
text(0.1,0.9,['Observer ',obs]);
xlabel('x'); ylabel('y'); zlabel('Y');
set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))]);
legend([sc1,sc2],'Mel-high','Mel-low','Location','SouthEast');

%% Analysis of chromaticity cluster

obs = 'LW';       % 'DG'/'HC'/'LW' can be used instead
ct = LN*N;

% Extract datasets for observer

RBdata = zeros(ct,2,'double');
AUdata = zeros(ct,2,'double');

n = 1;
for i = 1:length(files)
    for j = 1:LN
        if strcmp(files(i).name(end-8:end-7),obs)
            x = squeeze(files(i).dataxy(1,j,:));
            y = squeeze(files(i).dataxy(2,j,:));
            if strcmp(files(i).name(end-5:end-4),'RB')
              RBdata(n:n+N-1,1) = x;  RBdata(n:n+N-1,2) = y;
              n = n+N;
            end
        end
    end
end

n = 1;
for i = 1:length(files)
    for j = 1:LN
        if strcmp(files(i).name(end-8:end-7),obs)
            x = squeeze(files(i).dataxy(1,j,:));
            y = squeeze(files(i).dataxy(2,j,:));
            if strcmp(files(i).name(end-5:end-4),'AU')
              AUdata(n:n+N-1,1) = x;  AUdata(n:n+N-1,2) = y;
              n = n+N;
            end
        end
    end
end

% Find lines of best fit

rbmean = mean(RBdata);
aumean = mean(AUdata);
[rbcoeff,rbscore,rblatent] = pca(RBdata);
[aucoeff,auscore,aulatent] = pca(AUdata);
rbslope = rbcoeff(2,1)/rbcoeff(1,1);
auslope = aucoeff(2,1)/aucoeff(1,1);
xx = 0:0.001:1;
rbyy = rbmean(2)+rbslope*(xx-rbmean(1));
auyy = aumean(2)+auslope*(xx-aumean(1));

% Find wavelengths of intersection with locus

xct = length(xx);
rbdiff = zeros(xct,2,'double');
audiff = zeros(xct,2,'double');
for xi = 1:xct
  rbd = sqrt((xb21-xx(xi)).^2+(yb21-rbyy(xi)).^2);
  [dmin,di] = min(rbd);
  rbdiff(xi,1) = dmin;  rbdiff(xi,2) = di;
  aud = sqrt((xb21-xx(xi)).^2+(yb21-auyy(xi)).^2);
  [dmin,di] = min(aud);
  audiff(xi,1) = dmin;  audiff(xi,2) = di;
end

[srbd,srbi] = sort(rbdiff(:,1),'ascend');
rb1 = srbi(1);
i = 2;
while (abs(srbi(i)-rb1)<20) i = i+1;  end
rb2 = srbi(i);
[saud,saui] = sort(audiff(:,1),'ascend');
au1 = saui(1);
i = 2;
while (abs(saui(i)-au1)<20) i = i+1;  end
au2 = saui(i);

wmin = lambdaCie2(1);
wrb1 = wmin+rbdiff(rb1,2)-1;  wrb2 = wmin+rbdiff(rb2,2)-1;
wau1 = wmin+audiff(au1,2)-1;  wau2 = wmin+audiff(au2,2)-1;
fprintf('Observer %s  Mean chromaticity: RB %6.4f,%6.4f  AU %6.4f,%6.4f\n',obs,rbmean,aumean);
fprintf('Intersection wavelengths: RB %d,%d  AU %d,%d\n',wrb1,wrb2,wau1,wau2);

% Plot data in 2D

grey = [0.4,0.4,0.4];
figure, hold on;
plot([xb21;xb21(1)],[yb21;yb21(1)],'k');                % 2-deg monochromatic locus
lmin = 81;  lmax = 241;
xoff = 0.02;  yoff = 0.02;
for i = lmin:10:lmax
  lam = lambdaCie21(i);
  str = num2str(lam);
  plot(xb21(i),yb21(i),'ok','Color',grey);
  text(xb21(i)+xoff,yb21(i)+yoff,str,'Color',grey);
end
h1 = plot(RBdata(:,1),RBdata(:,2),'ok','MarkerFaceColor',rbcol,'MarkerEdgeColor','none','MarkerSize',5);
h2 = plot(AUdata(:,1),AUdata(:,2),'ok','MarkerFaceColor',aucol,'MarkerEdgeColor','none','MarkerSize',5);
plot(xw,yw,'ok','MarkerFaceColor','w','MarkerSize',7);            % display white point
plot(rbmean(1),rbmean(2),'+y');  plot(aumean(1),aumean(2),'+w');  % means
plot(xx,rbyy,'-','Color',rbcol);  plot(xx,auyy,'-','Color',aucol);  % lines

%xlim([0.2,0.4]); ylim([0.2,0.4]);
axis([0,0.75,0,0.85]);
text(0.45,0.75,['Observer ',obs]);
xlabel('x'); ylabel('y'); zlabel('Y');
set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))]);
legend([h1,h2],'Mel-high','Mel-low','Location','SouthEast');


