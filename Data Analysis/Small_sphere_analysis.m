function stats = Small_sphere_analysis(obs)

%% Run 2 Data Analysis
% Loads run 2 data
% Calibrates data
% Computes XYZ, xy and CIELAB

% TO DO

% Compare with LED measurements
% Put into pretty subplot with different angles of view

%% Pre-flight
%clc, clear, close all

% Display Settings
plt.disp = 1;         % Display figures?
d = DGdisplaydefaults;
set(groot,'defaultAxesColorOrder',hsv(10))

rootdir = 'C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data\Run 2 data\Trial Data';

N = 30;                             % number of repetitions over time
LN = 5;                             % number of lightness levels per repeat

%% Loads data

cd(rootdir)
files= dir('*.mat');
for j=1:length(files)
    load(fullfile(rootdir,files(j).name));  % load experimental results
    files(j).dataLAB=LABmatch;
    files(j).dataRGB=RGBmatch;
    files(j).RGBstart=RGBstart;
    files(j).Tmatch=Tmatch;
end
clear LABmatch RGBmatch RGBstart Tmatch j

%% Creates calibrated LAB values

%load CIE data
ciefile = 'C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Old (pre 20190816)\LM files\CIE colorimetric data\CIE_colorimetric_tables.xls';
ciedata = xlsread(ciefile,'1931 col observer','A6:D86');
% figure, plot(ciedata(:,1),ciedata(:,2),...
%     ciedata(:,1),ciedata(:,3),
%     ciedata(:,1),ciedata(:,4))
% legend('show')
cielambda=ciedata(:,1);
Xcmf=ciedata(:,2);
Ycmf=ciedata(:,3);
Zcmf=ciedata(:,4);

xw = zeros(length(files),1);
yw = zeros(length(files),1);

for trial=1:length(files)
    
    %load calibration file
    calFileLocation=fullfile(rootdir(1:end-11),'PR650',files(trial).name(1:end-4),...
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
    RGBw_SPD = interp1(lambda,Measurement(:,21,4),cielambda,'spline');
    RGBb_SPD = interp1(lambda,Measurement(:,1,4),cielambda,'spline');
    
    Norm = 100/sum(RGBw_SPD.*Ycmf);              % normalising factor
    
    DB = squeeze(RGBb_SPD);
    Xb = sum(RGBb_SPD.*Xcmf)*Norm;
    Yb = sum(RGBb_SPD.*Ycmf)*Norm;               % calculate white reference
    Zb = sum(RGBb_SPD.*Zcmf)*Norm;
    fprintf('%s Display black XYZ = %5.3f,%5.3f,%5.3f\n',files(trial).name(end-8:end-4),Xb,Yb,Zb);
    
    Xw = sum(RGBw_SPD.*Xcmf)*Norm;
    Yw = sum(RGBw_SPD.*Ycmf)*Norm;               % calculate white reference
    Zw = sum(RGBw_SPD.*Zcmf)*Norm;
    fprintf('%s Display white XYZ = %5.3f,%5.3f,%5.3f\n',files(trial).name(end-8:end-4),Xw,Yw,Zw);
    xw(trial) = Xw/(Xw+Yw+Zw);
    yw(trial) = Yw/(Xw+Yw+Zw);
    
    for j = 1:3
        % Thresholding:
        % - original RGB values included out of gamut
        % selections, resulting in above 1 and below 0 values
        
        a = files(trial).dataRGB(j,:,:); %Create temporary variable
        a(files(trial).dataRGB(j,:,:)>1) = 1; % Threshold to below 1
        a(files(trial).dataRGB(j,:,:)<0) = 0; % Threshold to above 0
        files(trial).dataRGBgam(j,:,:)   = uint8(a*255); %Rescale
        
        files(trial).dataRGBgamgam(j,:,:) = files(trial).dataRGB(j,:,:)>1 ...
            |files(trial).dataRGB(j,:,:)<0; %out of gamut flag
    end
    
    files(trial).dataXYZ=zeros(3,LN,N);
    files(trial).dataxy=zeros(2,LN,N);
    files(trial).dataLABcal=zeros(3,LN,N);
    
    for j=1:LN
        for k=1:N
            files(trial).dataXYZ(:,j,k)=...
                (XYZinterp(:,files(trial).dataRGBgam(1,j,k)+1,1)...
                +XYZinterp(:,files(trial).dataRGBgam(2,j,k)+1,2)...
                +XYZinterp(:,files(trial).dataRGBgam(3,j,k)+1,3));
            
            files(trial).dataxy(1,j,k)=...
                files(trial).dataXYZ(1,j,k)/sum(files(trial).dataXYZ(:,j,k));
            files(trial).dataxy(2,j,k)=...
                files(trial).dataXYZ(2,j,k)/sum(files(trial).dataXYZ(:,j,k));
            
            files(trial).dataLABcal(:,j,k)=...
                XYZToLab(files(trial).dataXYZ(:,j,k),[Xw;Yw;Zw]);
        end
    end
end

% % Plot display white points
% figure, hold on
% drawChromaticity('1931')
% scatter(xw,yw,'k')

%%

figure, hold on
colSpace = 'xy';
markerSize = 20;

if strcmp(colSpace,'LAB')
    for i = 1:length(files)        
        if (strcmp(files(i).name(end-8:end-7),obs) || (strcmp(obs,'ALL')))
            scatter3(files(i).dataLABcal(2,:),files(i).dataLABcal(3,:),files(i).dataLABcal(1,:),markerSize,'filled',...
                'DisplayName',sprintf('%s-%s-%s',files(i).name(6:10),files(i).name(end-8:end-7),files(i).name(end-5:end-4)),...
                'MarkerFaceAlpha',0.4);
        end
    end
    set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))])
    xlabel('a*')
    ylabel('b*')
    zlabel('L*')
elseif strcmp(colSpace,'xy')
    %drawChromaticity('1931','line')
    for i = 1:length(files)        
        if (strcmp(files(i).name(end-8:end-7),obs) || (strcmp(obs,'ALL')))
            scatter3(files(i).dataxy(1,:),files(i).dataxy(2,:),files(i).dataXYZ(2,:),markerSize,'filled',...
                'DisplayName',sprintf('%s-%s-%s',files(i).name(6:10),files(i).name(end-8:end-7),files(i).name(end-5:end-4)),...
                'MarkerFaceAlpha',0.4);
        end
    end
    daspect([1,1,1000])
    curfig = gcf;
    pbaspect([curfig.OuterPosition(1),curfig.OuterPosition(2)*0.8,curfig.OuterPosition(2)*0.8]) %outer position isn't quite what I want here, so I'm just scaling it up manually for now
    xlabel('x')
    ylabel('y')
    zlabel('Y')
end
legend('Location','best')

save2pdf(['C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data Analysis\figs\',obs])


%% Plot all data in CIE 1931 xy, showing time as marker size

% %obs = 'DG';
% markerSize=(1:150).^1.5;
% 
% figure, hold on
% 
% for i=1:length(files)
%     if (strcmp(files(i).name(end-8:end-7),obs) || (strcmp(obs,'ALL')))
%         if strcmp(files(i).name(end-5:end-4),'RB')
%             scatter3(squeeze(files(i).dataxy(1,:)),...
%                 squeeze(files(i).dataxy(2,:)),...
%                 squeeze(files(i).dataXYZ(2,:)),...
%                 markerSize,'filled',...
%                 'MarkerFaceAlpha',0.4);
%             
%         elseif strcmp(files(i).name(end-5:end-4),'AU')
%             scatter3(squeeze(files(i).dataxy(1,:)),...
%                 squeeze(files(i).dataxy(2,:)),...
%                 squeeze(files(i).dataXYZ(2,:)),...
%                 markerSize,'filled',...
%                 'MarkerFaceAlpha',0.4);
%         end
%     end
% end
% %axis('equal')
% xlabel('x')
% ylabel('y')
% zlabel('Y')
% set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))])

%% Stats
for i=1:length(files)
    m(i,:)  = mean(files(i).dataxy(:,:),2);
    sd(i,:) = std(files(i).dataxy(:,:),[],2);
end

% figure, hold on
% drawChromaticity
% scatter(m(:,1),m(:,2),'k')

[H(1), pValue(1)] = kstest_2s_2d(files(6).dataxy(:,:)', files(9).dataxy(:,:)', 0.05); %DG
[H(2), pValue(2)] = kstest_2s_2d([files(1).dataxy(:,:)';files(7).dataxy(:,:)'],...
    [files(2).dataxy(:,:)';files(10).dataxy(:,:)'], 0.05); %LW
[H(3), pValue(3)] = kstest_2s_2d([files(3).dataxy(:,:)';files(8).dataxy(:,:)'],...
    [files(4).dataxy(:,:)';files(5).dataxy(:,:)'], 0.05); %HC

stats.m  = m;
stats.sd = sd;
stats.H  = H;
stats.p  = pValue;

end