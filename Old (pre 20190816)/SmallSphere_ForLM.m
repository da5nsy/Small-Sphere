%% Plots for Lindsay
clc, clear, close all

%Modify as required:
baselineFolderLocation=fullfile('C:','Users','ucesars','Desktop');

%% Load CIE data
ciefile = fullfile(baselineFolderLocation,'CIE_colorimetric_tables.xls');

ciedata2= xlsread(ciefile,'1931 col observer','A6:D86');
lambdaCie2=ciedata2(:,1);
xbar2=ciedata2(:,2);
ybar2=ciedata2(:,3);
zbar2=ciedata2(:,4);

ciedata10= xlsread(ciefile,'1964 col observer','A6:D86');
lambdaCie10=ciedata10(:,1);
xbar10=ciedata10(:,2);
ybar10=ciedata10(:,3);
zbar10=ciedata10(:,4);

%Load melanopsin data
melfile=fullfile(baselineFolderLocation,'Irradiance Toolbox.xls');
mel = xlsread(melfile,'Reference','F11:F91');
lambdaMel=(380:5:780)';


%% Colorimetric Cross

LEDs =   [490,400,625];
spread = 20;           %20 for realistic values,
range =  [520,600];    %Range over which a contender for LED_4 will be sought

%Create LED SPDs
LED_1 = gaussmf(lambdaCie10,[spread LEDs(1)]);
LED_2 = gaussmf(lambdaCie10,[spread LEDs(2)]);
LED_3 = gaussmf(lambdaCie10,[spread LEDs(3)]);

%Calculate XYZ for LEDs
LED_1_XYZ=[xbar10'*LED_1,ybar10'*LED_1,zbar10'*LED_1];
LED_2_XYZ=[xbar10'*LED_2,ybar10'*LED_2,zbar10'*LED_2];
LED_3_XYZ=[xbar10'*LED_3,ybar10'*LED_3,zbar10'*LED_3];

%Calculate xy for LEDs
LED_1_xy=[LED_1_XYZ(1)/sum(LED_1_XYZ),LED_1_XYZ(2)/sum(LED_1_XYZ)];
LED_2_xy=[LED_2_XYZ(1)/sum(LED_2_XYZ),LED_2_XYZ(2)/sum(LED_2_XYZ)];
LED_3_xy=[LED_3_XYZ(1)/sum(LED_3_XYZ),LED_3_XYZ(2)/sum(LED_3_XYZ)];

%Plot CIE1964, with LED chromaticies
figure, hold on
plot([xbar10./(xbar10+ybar10+zbar10);xbar10(1)/(xbar10(1)+ybar10(1)+zbar10(1))]...
    ,[ybar10./(xbar10+ybar10+zbar10);ybar10(1)./(xbar10(1)+ybar10(1)+zbar10(1))],'k');
scatter(LED_1_xy(1),LED_1_xy(2),'k*');
scatter(LED_2_xy(1),LED_2_xy(2),'k*');
scatter(LED_3_xy(1),LED_3_xy(2),'k*');

%Annotate plot
title('CIE1964 chromaticity diagram');xlabel('x'); ylabel('y');
text(LED_1_xy(1)-0.07,LED_1_xy(2),num2str(LEDs(1)));
text(LED_2_xy(1)-0.07,LED_2_xy(2),num2str(LEDs(2)));
text(LED_3_xy(1)+0.02,LED_3_xy(2),num2str(LEDs(3)));
axis equal

%Add line between LED1 and LED3
plot(   [LED_1_xy(1),LED_3_xy(1)],...
        [LED_1_xy(2),LED_3_xy(2)],'k');

for i=range(1):5:range(2)
    
    % Define LED_4, and its mel contributions at different wavelengths
    LED_4 =     gaussmf(lambdaMel,[spread i]);
    LED_4_81 =  gaussmf(lambdaCie10,[spread i]);
    LED_4_mel(i)=mel'*LED_4;
    
    LED_4_XYZ=  [xbar10'*LED_4,ybar10'*LED_4,zbar10'*LED_4];
    LED_4_xy=   [LED_4_XYZ(1)/sum(LED_4_XYZ),LED_4_XYZ(2)/sum(LED_4_XYZ)];
    
    scatter(LED_4_xy(1),LED_4_xy(2),'b*');
    if mod(i,10)==0
        text((LED_4_xy(1)*1.2)-0.1,LED_4_xy(2)*1.1,num2str(i),'Color','b');
    end
    
    plot(   [LED_2_xy(1),LED_4_xy(1)],...
            [LED_2_xy(2),LED_4_xy(2)],'b');
end

%% LED SPDs, and mel

%Measured with Ocean Optics USB2000+
load(fullfile(baselineFolderLocation,'LED_SPDs.mat'));

figure, hold on
plot(lambdaOO,Data_LEDred/max(Data_LEDred));
plot(lambdaOO,Data_LEDblue/max(Data_LEDblue));
plot(lambdaOO,Data_LEDamber/max(Data_LEDamber));
plot(lambdaOO,Data_LEDuv/max(Data_LEDuv));
plot(lambdaMel,mel/max(mel),'k.','LineWidth',2);
xlabel('Wavelength(nm)')
axis([370 780 0 1])

%% Graph with some results from small sphere

cd(fullfile(baselineFolderLocation,'Trial Data'));
files= dir('*.mat');

N = 30;                             % number of repetitions over time
LN = 5;                            % number of lightness levels per repeat

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
    %fprintf('%s Display white XYZ = %5.3f,%5.3f,%5.3f\n',files(trial).name(end-8:end-4),Xw,Yw,Zw);  
    
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
            
            files(trial).dataLABcal(:,j,k)=...
                XYZToLab(files(trial).dataXYZ(:,j,k),[Xw;Yw;Zw]);
        end
    end
end

%Plot data
obs='ALL'; %'DG'/'HC'/'LW' can be used instead
markerSize=25;

figure, hold on
plot3([xbar2./(xbar2+ybar2+zbar2);xbar2(1)/(xbar2(1)+ybar2(1)+zbar2(1))]...
        ,[ybar2./(xbar2+ybar2+zbar2);ybar2(1)./(xbar2(1)+ybar2(1)+zbar2(1))],ones(length(xbar2)+1,1)*100,'k')
    

for i=1:length(files)
    for j=1:LN
        if (strcmp(files(i).name(end-8:end-7),obs) || (strcmp(obs,'ALL')))
            %pause(1)
            if strcmp(files(i).name(end-5:end-4),'RB')
                sc1= scatter3(   squeeze(files(i).dataxy(1,j,:)),...
                    squeeze(files(i).dataxy(2,j,:)),...
                    squeeze(files(i).dataXYZ(2,j,:))...
                    ,markerSize,[1,.1,.1],'filled');
                
            elseif strcmp(files(i).name(end-5:end-4),'AU')
                sc2= scatter3(   squeeze(files(i).dataxy(1,j,:)),...
                    squeeze(files(i).dataxy(2,j,:)),...
                    squeeze(files(i).dataXYZ(2,j,:))...
                    ,markerSize,[0,.8,0],'filled');
            end
        end
    end
end

title(sprintf('Observer: %s. CIE 1931 2deg obs',obs))
xlabel('x')
ylabel('y')
zlabel('Y')
set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))])

