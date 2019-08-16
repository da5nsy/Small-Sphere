function SmallSphereCalibrationCheck(obs,d)
%% Check calibration of small sphere APS (achromatic point setting) data
% 
% I have recorded values from the PR650, and from within matlab.
% 
% From the PR650 I have spectra.
% From matlab, I have RGB values, which I can convert, using the general calibration file into tristimulus values.

% Notes: 
% Only 3 out of gamut points

% Plan:
% Load fake APS data
% Calibrate APS data, using same method as for real data
% Load PR650 measurements
% Convert to tristimulus values
% Compare the above

%clc, clear, %close all
%obs='Characterization without LEDs'; 

%% Load CIE data
ciefile = fullfile('C:','Users','ucesars','Dropbox','UCL','Data',...
    'Colour Standards','CIE colorimetric data','CIE_colorimetric_tables.xls');

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

xbar2_101=interp1(lambdaCie2,xbar2,380:4:780,'spline');
ybar2_101=interp1(lambdaCie2,ybar2,380:4:780,'spline');
zbar2_101=interp1(lambdaCie2,zbar2,380:4:780,'spline');

%% Load fake APS data

rootdir = fullfile('C:','Users','ucesars','Dropbox','UCL','Data',...
    'Small Sphere','Run 2 Data','PR650',obs);
cd(rootdir)
files= dir('2017*.mat');

N = 3;                             % number of repetitions over time
LN = 5;                            % number of lightness levels per repeat

for j=1:length(files)
    
    load(fullfile(rootdir,files(j).name));  % load experimental results
    files(j).dataLAB=LABmatch;
    files(j).dataRGB=RGBmatch;
    files(j).RGBstart=RGBstart;
    files(j).Tmatch=Tmatch;
    
end

clear LABmatch RGBmatch RGBstart Tmatch j

%Calibrate data
for trial=1:length(files)
    
    %load calibration file
    calFileLocation=fullfile(rootdir,'Large LCD display measurement.mat');
    load(calFileLocation)
    
%     %interpolate recorded values (sval) to required vals (0:1:255)
%     XYZinterp=zeros(3,256,4);
%     for i=1:3
%         for j=1:4
%             XYZinterp(i,:,j)=interp1(sval,XYZ(i,:,j),0:255,'spline');
%         end
%     end
    

    %Try interpolating spectra instead
    SPCinterp=zeros(101,256,4);
    for i=1:101
        for j=1:4
            SPCinterp(i,:,j)=interp1(sval,Measurement(i,:,j),0:255,'spline');
        end
    end
   
    
    %Interp screen spectral data to same interval as CIE data
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
            %Using XYZinterp:
%             files(trial).dataXYZ(:,j,k)=...
%                 (XYZinterp(:,files(trial).dataRGBcal(1,j,k)+1,1)...
%                 +XYZinterp(:,files(trial).dataRGBcal(2,j,k)+1,2)...
%                 +XYZinterp(:,files(trial).dataRGBcal(3,j,k)+1,3));
            
            R=files(trial).dataRGBcal(1,j,k);
            G=files(trial).dataRGBcal(2,j,k);
            B=files(trial).dataRGBcal(3,j,k);
            files(trial).combinedSpectrum(:,j,k)=SPCinterp(:,R+1,1)+SPCinterp(:,G+1,2)+SPCinterp(:,B+1,3);
   
            files(trial).dataXYZ(:,j,k)=[...
                xbar2_101*files(trial).combinedSpectrum(:,j,k);
                ybar2_101*files(trial).combinedSpectrum(:,j,k);
                zbar2_101*files(trial).combinedSpectrum(:,j,k)];
            
            files(trial).dataxy(1,j,k)=...
                files(trial).dataXYZ(1,j,k)/sum(files(trial).dataXYZ(:,j,k));
            files(trial).dataxy(2,j,k)=...
                files(trial).dataXYZ(2,j,k)/sum(files(trial).dataXYZ(:,j,k));
            
            files(trial).dataLABcal(:,j,k)=...
                XYZToLab(files(trial).dataXYZ(:,j,k),[Xw;Yw;Zw]);
        end
    end
end

% i=1;
% d=reshape(files(i).dataLABcal,3,15);
% scatter3(d(2,:),d(3,:),d(1,:),'filled');

%% Load PR650 data, and calculate tristimulus values

PR650 = dir('Spectrum*.mat');
for i=1:length(PR650)
    load(PR650(i).name);
    PR650(i).dataSPC=PRspc(:,2);
    PR650(i).dataXYZ=[...
        xbar2_101*PR650(i).dataSPC;...
        ybar2_101*PR650(i).dataSPC;...
        zbar2_101*PR650(i).dataSPC];      
    PR650(i).dataxy=[PR650(i).dataXYZ(1)/sum(PR650(i).dataXYZ(:));...
        PR650(i).dataXYZ(2)/sum(PR650(i).dataXYZ(:))];
end

%% Compare SPDs
% %close all
% 
% spcr=reshape(files(1).combinedSpectrum,101,15);
% figure, hold on
% for i=1:14
%     
%     plot(lambda,spcr(:,i),'r:');
%     plot(lambda,PR650(i+1).dataSPC,'b:');
%     plot(lambda,Measurement(:,21,4),'k')
% end
% % figure; 
% % for i=1:14
% %     %semilogy(lambda,spcr(:,i)./PR650(i+1).dataSPC,'k'); hold on
% %     plot(lambda,spcr(:,i)-PR650(i+1).dataSPC,'k'); hold on
% % end
% plot([400,800],[0,0],'r')
% %plot([400,800],[1,1],'r')

%% Compare XYZ

if d==3
    
    %figure, hold on;
    
    XYZr=reshape(files.dataXYZ,3,15);
    xyr=reshape(files.dataxy,2,15);
    
    for i=1:14
        scatter3(xyr(1,i),xyr(2,i),XYZr(2,i),'r*','DisplayName','Internally saved')
    end
    %figure, hold on;
    for i=2:15
        scatter3(PR650(i).dataxy(1),PR650(i).dataxy(2),PR650(i).dataXYZ(2),'b*')
    end
    
    %title(obs);
    
    % Compare xy
elseif d==2
    %plotCIE(2,xbar2,ybar2,zbar2)
    %hold on
    
    xyr=reshape(files.dataxy,2,15);
    
    for i=1:14
        h1=scatter(xyr(1,i),xyr(2,i),'r*','DisplayName','Internally saved');
        %text(xyr(1,i),xyr(2,i),num2str(i),'Color','r')
    end
    %figure, hold on;
    for i=2:15
        h2=scatter(PR650(i).dataxy(1),PR650(i).dataxy(2),'b*','DisplayName','Externally saved (PR650)');
        %text(PR650(i).dataxy(1),PR650(i).dataxy(2),num2str(i-1),'Color','b')
    end
    
    %title(obs);
end

legend([h1 h2])
