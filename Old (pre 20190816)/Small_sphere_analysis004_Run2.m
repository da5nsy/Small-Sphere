%Run 2
%Need to load the correct calibration file for each run

%% Loads data

clc, clear, close all

rootdir = fullfile('C:','Users','ucesars','Dropbox','UCL','Data',...
    'Small Sphere','Run 2 Data','Trial Data');
cd(rootdir)
files= dir('*.mat');

N = 30;                             % number of repetitions over time
LN = 5;                            % number of lightness levels per repeat

for j=1:length(files)
    
    load(fullfile(rootdir,files(j).name));  % load experimental results
    files(j).dataLAB=LABmatch;
    files(j).dataRGB=RGBmatch;
    files(j).RGBstart=RGBstart;
    files(j).Tmatch=Tmatch;
    
end

clear LABmatch RGBmatch RGBstart Tmatch j

%% Creates calibrated LAB values

%load calibration file
load('C:\Users\ucesars\Dropbox\UCL\Data\Large Sphere\Large LCD display measurement - Oct 2016.mat')

%interpolate recorded values (sval) to required vals (0:1:255)
XYZinterp=zeros(3,256,4);
for i=1:3
    for j=1:4
        XYZinterp(i,:,j)=interp1(sval,XYZ(i,:,j),0:255,'spline');
    end
end

%load CIE data
ciefile = fullfile('C:','Users','ucesars','Dropbox','UCL','Data',...
    'Colour Standards','CIE colorimetric data','CIE_colorimetric_tables.xls');
ciedata= xlsread(ciefile,'1931 col observer','A6:D86');
% figure, plot(ciedata(:,1),ciedata(:,2),...
%     ciedata(:,1),ciedata(:,3),
%     ciedata(:,1),ciedata(:,4))
% legend('show')
cielambda=ciedata(:,1);
Xcmf=ciedata(:,2);
Ycmf=ciedata(:,3);
Zcmf=ciedata(:,4);

%Intrep screen spectral data to same interval as CIE data
RGB_SPD = zeros(length(cielambda),4,'double');
for k = 1:4
    RGB_SPD(:,k) = interp1(lambda,RGBW_spectrum(:,k),cielambda,'spline');
end

DW = squeeze(RGB_SPD(:,4));
Norm = 100/sum(DW.*Ycmf);              % normalising factor
Xw = sum(DW.*Xcmf)*Norm;
Yw = sum(DW.*Ycmf)*Norm;               % calculate white reference
Zw = sum(DW.*Zcmf)*Norm;
fprintf('Display white XYZ = %5.3f,%5.3f,%5.3f\n',Xw,Yw,Zw);

for i=1:length(files)
    for j=1:3
        % Thresholding:
        % - original RGB values included out of gamut
        % selections, resulting in above 1 and below 0 values
        
        a=files(i).dataRGB(j,:,:); %Create temporary variable
        a(files(i).dataRGB(j,:,:)>1)=1; % Threshold to below 1
        a(files(i).dataRGB(j,:,:)<0)=0; % Threshold to above 0
        files(i).dataRGBcal(j,:,:)=uint8(a*255); %Rescale
        %dataRGBcal is not actually 'calibrated', perhaps innappropriate
        %naming
        
        files(i).dataRGBcalgam1(j,:,:)=files(i).dataRGB(j,:,:)>1 ...
            |files(i).dataRGB(j,:,:)<0;
        
    end
end



for i=1:length(files)
    files(i).dataXYZ=zeros(3,16,10);
    files(i).dataxy=zeros(2,16,10);
    files(i).dataLABcal=zeros(3,16,10);
    
    for j=1:LN
        for k=1:N
            files(i).dataXYZ(:,j,k)=...
                (XYZinterp(:,files(i).dataRGBcal(1,j,k)+1,1)...
                +XYZinterp(:,files(i).dataRGBcal(2,j,k)+1,2)...
                +XYZinterp(:,files(i).dataRGBcal(3,j,k)+1,3));
            
            files(i).dataxy(1,j,k)=...
                files(i).dataXYZ(1,j,k)/sum(files(i).dataXYZ(:,j,k));
            files(i).dataxy(2,j,k)=...
                files(i).dataXYZ(2,j,k)/sum(files(i).dataXYZ(:,j,k));
            
            files(i).dataLABcal(:,j,k)=...
                XYZToLab(files(i).dataXYZ(:,j,k),[Xw;Yw;Zw]);
        end
    end
end

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
    imwrite(Im,iname,'tif');           % write the image
    
end


%% Plot all data
obs='DG';

figure, hold on

for i=1:length(files)
    for j=1:LN
        if (strcmp(files(i).name(end-8:end-7),obs) || (strcmp(obs,'ALL')))
            %pause(1)
            if strcmp(files(i).name(end-5:end-4),'RB')
                sc1= scatter3(   squeeze(files(i).dataLABcal(2,j,:)),...
                    squeeze(files(i).dataLABcal(3,j,:)),...
                    squeeze(files(i).dataLABcal(1,j,:))...
                    ,10,[1,.1,.1],'filled');
                
            elseif strcmp(files(i).name(end-5:end-4),'AU')
                sc2= scatter3(   squeeze(files(i).dataLABcal(2,j,:)),...
                    squeeze(files(i).dataLABcal(3,j,:)),...
                    squeeze(files(i).dataLABcal(1,j,:))...
                    ,10,[0,.8,0],'filled');
            end
        end
    end
end

title(obs)
axis('equal')
xlabel('a*')
ylabel('b*')
zlabel('L*')
set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))])

