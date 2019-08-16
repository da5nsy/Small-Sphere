%% Loads data

clc, clear, %close all

rootdir = fullfile('C:','Users','ucesars','Dropbox','UCL','Data','Small Sphere','Run 1 data');
cd(rootdir)
files= dir('*.mat');

N = 10;                             % number of repetitions over time
LN = 16;                            % number of lightness levels per repeat

for j=1:length(files)
    
    load(fullfile(rootdir,files(j).name));  % load experimental results
    files(j).dataLAB=LABmatch;                 
    files(j).dataRGB=RGBmatch;
                                            
end

clear LABmatch RGBmatch j

%% Creates calibrated LAB values

%load calibration file
load('C:\Users\ucesars\Dropbox\UCL\Data\Large Sphere\Large LCD display measurement - Oct 2016.mat')

%interpolate recorded values (0:5:255) to required vals (0:1:255)
XYZinterp=zeros(3,256,4);
for i=1:3
    for j=1:4
        XYZinterp(i,:,j)=interp1(sval,XYZ(i,:,j),0:255,'spline');
    end
end

%load CIE data
ciefile = fullfile('C:','Users','ucesars','Dropbox','UCL','Data',...
    'Colour Standards','CIE colorimetric data','CIE_colorimetric_tables.xls');
ciedata= xlsread(ciefile,'1964 col observer','A6:D86');
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
        
        files(i).dataRGBcalgam1(j,:,:)=files(i).dataRGB(j,:,:)>1 ...
            |files(i).dataRGB(j,:,:)<0;
        
    end
end



for i=1:length(files)
    files(i).dataXYZ=zeros(3,16,10);
    files(i).dataxy=zeros(2,16,10);
    files(i).dataLABcal=zeros(3,16,10);
    
    for j=1:16
        for k=1:10
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
    
    load(fullfile(rootdir,files(j).name));  % load experimental results

    b = 40;                         % pixels in box side
    s = 4;                          % spacing between boxes
    w = s+N*(b+s);                  % width of array (iteration axis)
    h = s+LN*(b+s);                 % height of array (lightness axis)
    Im = zeros(h,w,3,'uint8');      % image array

    for n = 1:N
      xp = s+(n-1)*(b+s);                    % x pixel address (iteration axis)
      for i = 1:LN
        rs = RGBmatch(1,i,n);                % get R value (display signal, 8-bit)
        gs = RGBmatch(2,i,n);
        bs = RGBmatch(3,i,n);
        yp = s+(i-1)*(b+s);                  % y pixel address (lightness axis)
        Im(yp:yp+b-1,xp:xp+b-1,1) = uint8(255*rs);  % fill one square in array
        Im(yp:yp+b-1,xp:xp+b-1,2) = uint8(255*gs);
        Im(yp:yp+b-1,xp:xp+b-1,3) = uint8(255*bs);
      end
    end

    iname = fullfile(rootdir,sprintf('%s.tif',files(j).name(1:end-4)));
    %imwrite(Im,iname,'tif');           % write the image
    
end

%% Plot medians by session
%cla
figure,
highL=70;   %max 85
lowL=10;    %min 10
scaler=2;   %size of points

hold on
for i=1:length(files)
    for j=18-highL/5:18-lowL/5
        pause(0.05)

        A(i,j)=median(files(i).dataLABcal(2,j,:));
        B(i,j)=median(files(i).dataLABcal(3,j,:));
        if files(i).name(end-4)=='0'
            if str2num(files(i).date(13:14))>12
                sc1= scatter(A(i,j),B(i,j),(17-j)^scaler,[1,.6,.6],'filled', ...
                    'DisplayName','Light 0, PM'); % light red = light 0, PM
            else
                sc2= scatter(A(i,j),B(i,j),(17-j)^scaler,[.8,.2,.2],'filled',...
                    'DisplayName','Light 0, AM'); % dark red = light 0, AM
            end
        else
            if str2num(files(i).date(13:14))>12
                sc3= scatter(A(i,j),B(i,j),(17-j)^scaler,[.6,.6,1],'filled',...
                    'DisplayName','Light 1, PM'); % light blue = light 1, PM
            else
                sc4= scatter(A(i,j),B(i,j),(17-j)^scaler,[.2,.2,.8],'filled',...
                    'DisplayName','Light 1, AM'); % dark blue = light 1, AM
            end
        end
    end
    %axis([-7 25 -45 5])
    axis('equal')
end



legend([sc1(1),sc2(1),sc3(1),sc4(1)],'location','southwest')
title(sprintf('Median across each session, for L=%d to L=%d',lowL,highL));
xlabel('A')
ylabel('B')

% plot zero lines
currentaxes=gca;
plot([currentaxes.XLim],[0,0],'Color',[.8,.8,.8]);
plot([0,0],[currentaxes.YLim],'Color',[.8,.8,.8]);

%% Plot heavy medians
cla

highL=70;   %max 85
lowL=10;    %min 10
scaler=5;   %size of points

hold on
for i=1:length(files)
        pause(0.05)

        A(i)=median(median(files(i).dataLABcal(2,:,:)));
        B(i)=median(median(files(i).dataLABcal(3,:,:)));
        if files(i).name(end-4)=='0'
            if str2num(files(i).date(13:14))>12
                sc1= scatter(A(i),B(i),2^scaler,[1,.6,.6],'filled', ...
                    'DisplayName','Light 0, PM'); % light red = light 0, PM
            else
                sc2= scatter(A(i),B(i),2^scaler,[.8,.2,.2],'filled',...
                    'DisplayName','Light 0, AM'); % dark red = light 0, AM
            end
        else
            if str2num(files(i).date(13:14))>12
                sc3= scatter(A(i),B(i),2^scaler,[.6,.6,1],'filled',...
                    'DisplayName','Light 1, PM'); % light blue = light 1, PM
            else
                sc4= scatter(A(i),B(i),2^scaler,[.2,.2,.8],'filled',...
                    'DisplayName','Light 1, AM'); % dark blue = light 1, AM
            end
        end

    text(median(median(files(i).dataLABcal(2,:,:)))-30, ...
    median(median(files(i).dataLABcal(3,:,:))),...
    files(i).name(6:end-6))
    axis([-20 35 -60 20])
    axis('equal')
end



legend([sc1(1),sc2(1),sc3(1),sc4(1)],'location','southwest')
title(sprintf('Median across each session, for L=%d to L=%d',lowL,highL));
xlabel('A')
ylabel('B')

% plot zero lines
currentaxes=gca;
plot([currentaxes.XLim],[0,0],'Color',[.8,.8,.8]);
plot([0,0],[currentaxes.YLim],'Color',[.8,.8,.8]);

%% Plot all data
%cla
figure,
highL=85;   %max 85
lowL=10;    %min 10

hold on
for i=1:length(files)
    for j=18-highL/5:18-lowL/5
        pause(0.1)

        if files(i).name(end-4)=='0'
            if str2num(files(i).date(13:14))>12
                sc1= scatter3(   squeeze(files(i).dataLABcal(2,j,:)),...
                                squeeze(files(i).dataLABcal(3,j,:)),...
                                squeeze(files(i).dataLABcal(1,j,:))...
                    ,5,[1,.6,.6],'filled', ...
                    'DisplayName','Light 0, PM'); % light red = light 0, PM
            else
                sc2= scatter3(   squeeze(files(i).dataLABcal(2,j,:)),...
                                squeeze(files(i).dataLABcal(3,j,:)),...
                                squeeze(files(i).dataLABcal(1,j,:))...
                    ,5,[.8,.2,.2],'filled',...
                    'DisplayName','Light 0, AM'); % dark red = light 0, AM
            end
        else
            if str2num(files(i).date(13:14))>12
                sc3= scatter3(   squeeze(files(i).dataLABcal(2,j,:)),...
                                squeeze(files(i).dataLABcal(3,j,:)),...
                                squeeze(files(i).dataLABcal(1,j,:))...
                    ,5,[.6,.6,1],'filled',...
                    'DisplayName','Light 1, PM'); % light blue = light 1, PM
            else
                sc4= scatter3(   squeeze(files(i).dataLABcal(2,j,:)),...
                                squeeze(files(i).dataLABcal(3,j,:)),...
                                squeeze(files(i).dataLABcal(1,j,:))...
                    ,5,[.2,.2,.8],'filled',...
                    'DisplayName','Light 1, AM'); % dark blue = light 1, AM
            end
       end
       
    end
%     text(median(median(files(i).dataLABcal(2,:,:)))-30, ...
%         median(median(files(i).dataLABcal(3,:,:))),...
%         files(i).name(6:end))
   % axis([-20 35 -60 20])
    axis('equal')
end



legend([sc1(1),sc2(1),sc3(1),sc4(1)],'location','southwest')
title(sprintf('All data, for L=%d to L=%d',lowL,highL));
xlabel('A')
ylabel('B')

% plot zero lines
currentaxes=gca;
plot([currentaxes.XLim],[0,0],'Color',[.8,.8,.8]);
plot([0,0],[currentaxes.YLim],'Color',[.8,.8,.8]);

%% Plot all data, by run
cla

highL=85;   %max 85
lowL=10;    %min 10
scaler=20;   %size of points
ptime=0.2;
fadecol=[0.9,0.9,0.9];


hold on
for i=1:length(files)
    for j=1:10

        if files(i).name(end-4)=='0'
            if str2num(files(i).date(13:14))>12
                sc1= scatter(   squeeze(files(i).dataLABcal(2,:,j)),...
                                squeeze(files(i).dataLABcal(3,:,j))...
                    ,scaler,[1,.6,.6],'filled', ...
                    'DisplayName','Light 0, PM'); % light red = light 0, PM
                pause(ptime);sc1.CData=fadecol;
            else
                sc2= scatter(   squeeze(files(i).dataLABcal(2,:,j)),...
                                squeeze(files(i).dataLABcal(3,:,j))...
                    ,scaler,[.8,.2,.2],'filled',...
                    'DisplayName','Light 0, AM'); % dark red = light 0, AM
                pause(ptime);sc2.CData=fadecol;
            end
        else
            if str2num(files(i).date(13:14))>12
                sc3= scatter(   squeeze(files(i).dataLABcal(2,:,j)),...
                                squeeze(files(i).dataLABcal(3,:,j))...
                    ,scaler,[.6,.6,1],'filled',...
                    'DisplayName','Light 1, PM'); % light blue = light 1, PM
                pause(ptime);sc3.CData=fadecol;
            else
                sc4= scatter(   squeeze(files(i).dataLABcal(2,:,j)),...
                                squeeze(files(i).dataLABcal(3,:,j))...
                    ,scaler,[.2,.2,.8],'filled',...
                    'DisplayName','Light 1, AM'); % dark blue = light 1, AM
                pause(ptime);sc4.CData=fadecol;
            end
       end
       
    end
    text(median(median(files(i).dataLABcal(2,:,:)))-30, ...
        median(median(files(i).dataLABcal(3,:,:))),...
        files(i).name(6:end-6))
  %  axis([-20 35 -60 20])
    axis('equal')
end



legend([sc1(1),sc2(1),sc3(1),sc4(1)],'location','southwest')
title(sprintf('Median across each session, for L=%d to L=%d',lowL,highL));
xlabel('A')
ylabel('B')

% plot zero lines
currentaxes=gca;
plot([currentaxes.XLim],[0,0],'Color',[.8,.8,.8]);
plot([0,0],[currentaxes.YLim],'Color',[.8,.8,.8]);

%% Plot average of runs end-3 and end-1

cla

highL=70;   %max 85
lowL=10;    %min 10
scaler=2;   %size of points

hold on
for i=1:length(files)
    %figure, hold on
    for j=18-highL/5:18-lowL/5
        pause(0.02)

        A(i,j)=mean(files(i).dataLABcal(2,j,end-3:end-1));
        B(i,j)=mean(files(i).dataLABcal(3,j,end-3:end-1));
        if files(i).name(end-4)=='0'
            if str2num(files(i).date(13:14))>12
                sc1= scatter(A(i,j),B(i,j),(17-j)^scaler,[1,.9,.9],'filled', ...
                    'DisplayName','Light 0, PM'); % light red = light 0, PM
            else
                sc2= scatter(A(i,j),B(i,j),(17-j)^scaler,[.8,.2,.2],'filled',...
                    'DisplayName','Light 0, AM'); % dark red = light 0, AM
            end
        else
            if str2num(files(i).date(13:14))>12
                sc3= scatter(A(i,j),B(i,j),(17-j)^scaler,[.9,.9,1],'filled',...
                    'DisplayName','Light 1, PM'); % light blue = light 1, PM
            else
                sc4= scatter(A(i,j),B(i,j),(17-j)^scaler,[.2,.2,.8],'filled',...
                    'DisplayName','Light 1, AM'); % dark blue = light 1, AM
            end
        end
    end
    axis([-7 25 -45 5])
    axis('equal')
    text(median(median(files(i).dataLABcal(2,:,:)))-30, ...
        median(median(files(i).dataLABcal(3,:,:))),...
        files(i).name(6:end-6))
end



legend([sc1(1),sc2(1),sc3(1),sc4(1)],'location','southwest')
title(sprintf('Median across each session, for L=%d to L=%d',lowL,highL));
xlabel('A')
ylabel('B')

% plot zero lines
currentaxes=gca;
plot([currentaxes.XLim],[0,0],'Color',[.8,.8,.8]);
plot([0,0],[currentaxes.YLim],'Color',[.8,.8,.8]);

%% Stats
% Two-sample Two-diensional Kolmogorov-Smirnov Test
% kstest_2s_2d(ABs of 1, ABs of 2)
light0=[];
light1=[];

for i=1:length(files)
    if files(i).name(end-4)=='0'
        light0=[light0,files(i).dataLABcal(2:3,:,:)];
    elseif files(i).name(end-4)=='1'
        light1=[light1,files(i).dataLABcal(2:3,:,:)];
    end
end

light0=permute(reshape(light0,[2,1600]),[2,1]);
light1=permute(reshape(light1,[2,1600]),[2,1]);

figure, hold on
scatter(light0(:,1),light0(:,2),'.');
scatter(light1(:,1),light1(:,2),'.');
axis equal

[a1,a2]=kstest_2s_2d(light0,light1)

%% Stats for heavy medians
% Two-sample Two-diensional Kolmogorov-Smirnov Test
% kstest_2s_2d(ABs of 1, ABs of 2)
light0=[];
light1=[];

for i=1:length(files)
    A(i)=median(median(files(i).dataLABcal(2,:,:)));
    B(i)=median(median(files(i).dataLABcal(3,:,:)));
    
    if files(i).name(end-4)=='0'
        light0=[light0;[A(i),B(i)]];
    elseif files(i).name(end-4)=='1'
        light1=[light1;[A(i),B(i)]];
    end
end

figure, hold on
scatter(light0(:,1),light0(:,2),'r');
scatter(light1(:,1),light1(:,2),'b');
axis equal

[a1,a2]=kstest_2s_2d(light0,light1)

%% Plot time course


for run=1:10
    fig=figure('units','normalized','outerposition',[0 0 1 1]); hold on
    for i=1:length(files)
        pause(0.5)
        for j=18-highL/5:18-lowL/5
            
            if files(i).name(end-4)=='0'
                if str2num(files(i).date(13:14))>12
                    sc1= scatter(files(i).dataLABcal(2,j,run),...
                        files(i).dataLABcal(3,j,run)...
                        ,(17-j)^scaler,[1,.6,.6],'filled', ...
                        'DisplayName','Light 0, PM'); % light red = light 0, PM
                else
                    sc2= scatter(files(i).dataLABcal(2,j,run),...
                        files(i).dataLABcal(3,j,run)...
                        ,(17-j)^scaler,[.8,.2,.2],'filled',...
                        'DisplayName','Light 0, AM'); % dark red = light 0, AM
                end
            else
                if str2num(files(i).date(13:14))>12
                    sc3= scatter(files(i).dataLABcal(2,j,run),...
                        files(i).dataLABcal(3,j,run)...
                        ,(17-j)^scaler,[.6,.6,1],'filled',...
                        'DisplayName','Light 1, PM'); % light blue = light 1, PM
                else
                    sc4= scatter(files(i).dataLABcal(2,j,run),...
                        files(i).dataLABcal(3,j,run)...
                        ,(17-j)^scaler,[.2,.2,.8],'filled',...
                        'DisplayName','Light 1, AM'); % dark blue = light 1, AM
                end
            end
        end
        axis([-20 40 -45 5])
        axis('equal')
    end
    
    legend([sc1(1),sc2(1),sc3(1),sc4(1)],'location','southwest')
    title(sprintf('All sessions, Run %d, L=%d to L=%d',run,lowL,highL));
    xlabel('A')
    ylabel('B')
    
    % plot zero lines
    currentaxes=gca;
    plot([currentaxes.XLim],[0,0],'Color',[.8,.8,.8]);
    plot([0,0],[currentaxes.YLim],'Color',[.8,.8,.8]);
    axis([-20 40 -45 5])
    
    saveas(fig,strcat(num2str(run),'.tif'))
end

%% Plot each L* val

highL=85;   %max 85
lowL=10;    %min 10
scaler=32;   %size of points

for j=18-highL/5:18-lowL/5
    fig=figure('units','normalized','outerposition',[0 0 1 1]); hold on
    
    for i=1:length(files)
        pause(0.3)        
        if files(i).name(end-4)=='0'
            if str2num(files(i).date(13:14))>12
                sc1= scatter(files(i).dataLABcal(2,j,:),...
                    files(i).dataLABcal(3,j,:)...
                    ,scaler,[1,.6,.6],'filled', ...
                    'DisplayName','Light 0, PM'); % light red = light 0, PM
            else
                sc2= scatter(files(i).dataLABcal(2,j,:),...
                    files(i).dataLABcal(3,j,:)...
                    ,scaler,[.8,.2,.2],'filled',...
                    'DisplayName','Light 0, AM'); % dark red = light 0, AM
            end
        elseif files(i).name(end-4)=='1'
            if str2num(files(i).date(13:14))>12
                sc3= scatter(files(i).dataLABcal(2,j,:),...
                    files(i).dataLABcal(3,j,:)...
                    ,scaler,[.6,.6,1],'filled',...
                    'DisplayName','Light 1, PM'); % light blue = light 1, PM
            else
                sc4= scatter(files(i).dataLABcal(2,j,:),...
                    files(i).dataLABcal(3,j,:)...
                    ,scaler,[.2,.2,.8],'filled',...
                    'DisplayName','Light 1, AM'); % dark blue = light 1, AM
            end
        else
            error('error: no AM/PM signifier in filename')            
        end
    end
    axis([-40 80 -90 30])
    axis('equal')

    legend([sc1(1),sc2(1),sc3(1),sc4(1)],'location','southwest')
    title(sprintf('All sessions, all runs, L* = %d',-5*(j-18)));
    xlabel('A')
    ylabel('B')
    
    % plot zero lines
    currentaxes=gca;
    plot([currentaxes.XLim],[0,0],'Color',[.8,.8,.8]);
    plot([0,0],[currentaxes.YLim],'Color',[.8,.8,.8]);
    axis([-40 80 -90 30])
    
    %saveas(fig,strcat(num2str(-5*(j-18)),'.tif'))
end




