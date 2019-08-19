function Small_sphere_analysis(obs)

%% Run 2 Data Analysis
% Loads run 2 data
% Calibrates data
% Computes XYZ, xy and CIELAB

%% Pre-flight
%clc, clear, close all

% Display Settings
plt.disp = 1;         % Display figures?
d.s=25;               % display, size
d.MFA = 0.2;          % Marker Face Alpha
d.mktrns = 0.3;       % Marker transparency
set(groot,'defaultfigureposition',[100 100 500 400])
set(groot,'defaultLineLineWidth',2)
set(groot,'defaultAxesFontName', 'Courier')
set(groot,'defaultAxesFontSize',12)
set(groot,'defaultFigureRenderer', 'painters') %renders pdfs as vector graphics
set(groot,'defaultfigurecolor','white')
cols = hsv(10); rng(2);
set(groot,'defaultAxesColorOrder',cols(randperm(size(cols,1)),:))

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
        files(trial).dataRGBcal(j,:,:)   = uint8(a*255); %Rescale
        %dataRGBcal is not actually 'calibrated', perhaps innappropriate
        %naming
        
        files(trial).dataRGBcalgam(j,:,:) = files(trial).dataRGB(j,:,:)>1 ...
            |files(trial).dataRGB(j,:,:)<0; %out of gamut flag
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

% figure, hold on
% drawChromaticity('1931')
% scatter(xw,yw,'k')

%% Create image files from rgb values
%Could be made quicker by using already loaded data perhaps?

for j=1:length(files)
    
    %load(fullfile(rootdir,files(j).name));  % load experimental results
    
    b = 40;                         % pixels in box side
    s = 4;                          % spacing between boxes
    w = s+N*(b+s);                  % width of array (iteration axis)
    h = s+LN*(b+s);                 % height of array (lightness axis)
    Im = zeros(h,w,3,'uint8');      % image array
    
    for n = 1:N
        xp = s+(n-1)*(b+s);                    % x pixel address (iteration axis)
        for i = 1:LN
            rs = files(j).dataRGBcal(1,i,n);                % get R value (display signal, 8-bit)
            gs = files(j).dataRGBcal(2,i,n);
            bs = files(j).dataRGBcal(3,i,n);
            yp = s+(i-1)*(b+s);                  % y pixel address (lightness axis)
            Im(yp:yp+b-1,xp:xp+b-1,1) = rs;  % fill one square in array
            Im(yp:yp+b-1,xp:xp+b-1,2) = gs;
            Im(yp:yp+b-1,xp:xp+b-1,3) = bs;
        end
    end
    
    iname = fullfile(rootdir,sprintf('%s.tif',files(j).name(1:end-4)));
    %imwrite(Im,iname,'tif');           % write the image
    
end


%% Plot data in LAB
figure, hold on
%obs = 'DG';
markerSize=25;

for i=1:length(files)
    if (strcmp(files(i).name(end-8:end-7),obs) || (strcmp(obs,'ALL')))
        if strcmp(files(i).name(end-5:end-4),'RB')
            scatter3(squeeze(files(i).dataLABcal(2,:)),...
                squeeze(files(i).dataLABcal(3,:)),...
                squeeze(files(i).dataLABcal(1,:))...
                ,markerSize,'filled',...
                'MarkerFaceAlpha',0.4);
            
        elseif strcmp(files(i).name(end-5:end-4),'AU')
            scatter3(squeeze(files(i).dataLABcal(2,:)),...
                squeeze(files(i).dataLABcal(3,:)),...
                squeeze(files(i).dataLABcal(1,:))...
                ,markerSize,'filled',...
                'MarkerFaceAlpha',0.4);
        end
    end
end

legend
xlabel('a*')
ylabel('b*')
zlabel('L*')
set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))])

axis equal
plot(xlim,[0,0],'Color',[.8,.8,.8],'HandleVisibility','off');
axis tight
plot([0,0],ylim,'Color',[.8,.8,.8],'HandleVisibility','off');

%%

figure, hold on
colSpace='xy';
markerSize=20;
view(3)

if strcmp(colSpace,'LAB')
    for i = 1:length(files)        
        if (strcmp(files(i).name(end-8:end-7),obs) || (strcmp(obs,'ALL')))
            d = reshape(files(i).dataLABcal,3,150);
            scatter3(d(2,:),d(3,:),d(1,:),markerSize,'filled','DisplayName',...
                sprintf('%s-%s',files(i).name(end-8:end-7),files(i).name(end-5:end-4)));
        end
    end
    set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))])
    xlabel('a*')
    ylabel('b*')
    zlabel('L*')
elseif strcmp(colSpace,'xy')
    drawChromaticity('1931','line')
    for i = 1:length(files)        
        if (strcmp(files(i).name(end-8:end-7),obs) || (strcmp(obs,'ALL')))
            d=reshape(files(i).dataxy,2,150);
            d2=reshape(files(i).dataXYZ,3,150);
            scatter3(d(1,:),d(2,:),d2(2,:),markerSize,'filled','DisplayName',...
                sprintf('%s-%s',files(i).name(end-8:end-7),files(i).name(end-5:end-4)));
        end
    end
    set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))])
    xlabel('x')
    ylabel('y')
end
legend('show')
%set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))])

%% Plot all data in CIE 1931 xy, showing time as marker size
%obs = 'DG';
markerSize=(1:150).^1.5;

figure, hold on

for i=1:length(files)
    if (strcmp(files(i).name(end-8:end-7),obs) || (strcmp(obs,'ALL')))
        if strcmp(files(i).name(end-5:end-4),'RB')
            scatter3(squeeze(files(i).dataxy(1,:)),...
                squeeze(files(i).dataxy(2,:)),...
                squeeze(files(i).dataXYZ(2,:)),...
                markerSize,'filled',...
                'MarkerFaceAlpha',0.4);
            
        elseif strcmp(files(i).name(end-5:end-4),'AU')
            scatter3(squeeze(files(i).dataxy(1,:)),...
                squeeze(files(i).dataxy(2,:)),...
                squeeze(files(i).dataXYZ(2,:)),...
                markerSize,'filled',...
                'MarkerFaceAlpha',0.4);
        end
    end
end
%axis('equal')
xlabel('x')
ylabel('y')
zlabel('Y')
set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))])

end