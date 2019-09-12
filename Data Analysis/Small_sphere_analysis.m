function stats = Small_sphere_analysis(obs)

%% Run 2 Data Analysis
% Loads run 2 data
% Calibrates data
% Computes XYZ, xy and CIELAB

%% Pre-flight
clc, clear, close all
obs = 'ALL';

% Display Settings
%plt.disp = 1;         % Display figures?
DGdisplaydefaults;
set(groot,'defaultAxesColorOrder',hsv(10))

rootdir = 'C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data\Run 2 data\Trial Data';
figfile = 'C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data Analysis\figs\';

N  = 30;                             % number of repetitions over time
LN = 5;                             % number of lightness levels per repeat

%% Loads data

cd(rootdir)
files = dir('*.mat');
for j = 1:length(files)
    load(fullfile(rootdir,files(j).name));  % load experimental results
    files(j).dataLAB  = LABmatch;
    files(j).dataRGB  = RGBmatch;
    files(j).RGBstart = RGBstart;
    files(j).Tmatch   = Tmatch;
end
clear LABmatch RGBmatch RGBstart Tmatch j

files = rmfield(files,{'bytes','isdir','datenum'}); %remove unused fields

%% Creates calibrated LAB values

for trial=1:length(files)
    
    %load calibration file
    calFileLocation = fullfile(rootdir(1:end-11),'PR650',files(trial).name(1:end-4),...
        'Large LCD display measurement.mat');
    load(calFileLocation,'sval','XYZ')
    
    %interpolate recorded values (sval) to required vals (0:1:255)
    XYZinterp = zeros(3,256,4);
    for i = 1:3
        for j = 1:4
            XYZinterp(i,:,j) = interp1(sval, XYZ(i,:,j), 0:255, 'spline');
        end
    end
    
    % Calcaulate XYZ for white point of display
    %   This method gives slightly different results to the previous method
    %   (where cie1931 was loaded, and fresh tristimulus were calculated from
    %   the recorded spectra, but this method is much neater and in-ilne with
    %   the use of the PR650 XYZ values elsewhere).
    
    files(trial).screenXYZ  = XYZ;
    for i = 1:21
        for j = 1:4
            files(trial).screenxyY(:,i,j)  = XYZToxyY(squeeze(XYZ(:,i,j)));
        end
    end
    
    % I think the following normalisation is required but I don't have time to think
    % clearly about this now. This might exaplain why, although we
    % specificed L* = 30:10:70 in the experiment, the calibrated values are
    % higher.  
    %
    % files(trial).screenxyY = files(trial).screenxyY/XYZ(2,end,4)*100;
    
    files(trial).screenXYZw = XYZ(:,end,4)/XYZ(2,end,4)*100;
    files(trial).screenxyw  = files(trial).screenxyY(:,end,end);
    
    
    % Thresholding:
    %   Original RGB values included out of gamut (sRGB)
    %   selections, resulting in above 1 and below 0 values. These would
    %   actually have only presented values at 0/1 and so here they are
    %   corrected to represent what would actually have been presented
    
    files(trial).dataRGBgamflag = files(trial).dataRGB > 1 | files(trial).dataRGB < 0; %out of gamut flag
    
    files(trial).dataRGBgamcor  = files(trial).dataRGB; %duplicate
    files(trial).dataRGBgamcor(files(trial).dataRGB < 0) = 0;
    files(trial).dataRGBgamcor(files(trial).dataRGB > 1) = 1;
    
    % Quantization
    files(trial).dataRGBgamcor = uint8(files(trial).dataRGBgamcor*255);
    
    files(trial).dataXYZcal    = zeros(3,LN,N);
    files(trial).dataxycal     = zeros(2,LN,N);
    files(trial).dataLABcal    = zeros(3,LN,N);
    
    for j = 1:LN
        for k = 1:N
            files(trial).dataXYZcal(:,j,k) = ...
                (XYZinterp(:,files(trial).dataRGBgamcor(1,j,k)+1,1)...
                +XYZinterp(:,files(trial).dataRGBgamcor(2,j,k)+1,2)...
                +XYZinterp(:,files(trial).dataRGBgamcor(3,j,k)+1,3));
            
            files(trial).dataxycal(1,j,k) = ...
                files(trial).dataXYZcal(1,j,k)/sum(files(trial).dataXYZcal(:,j,k));
            files(trial).dataxycal(2,j,k) = ...
                files(trial).dataXYZcal(2,j,k)/sum(files(trial).dataXYZcal(:,j,k));
            files(trial).dataxycal(3,j,k) = files(trial).dataXYZcal(2,j,k);
            
            files(trial).dataLABcal(:,j,k) = ...
                XYZToLab(files(trial).dataXYZcal(:,j,k),files(trial).screenXYZw);
        end
    end
end

%% Plot data

if strcmp(obs,'ALL')
    figure, hold on
else
    figure('Position',[100 100 500 600]), hold on
end

colSpace = 'LAB';
markerSize = 20;

if strcmp(colSpace,'LAB')
    for i = 1:length(files)
        if (strcmp(files(i).name(end-8:end-7),obs) || (strcmp(obs,'ALL')))
            if strcmp(obs,'ALL')
                a = scatter3(files(i).dataLABcal(2,:),files(i).dataLABcal(3,:),files(i).dataLABcal(1,:),markerSize,'filled',...
                    'DisplayName',sprintf('%s-%s-%s',files(i).name(end-8:end-7),files(i).name(end-5:end-4),files(i).name(6:10)),...
                    'MarkerFaceAlpha',0.4);
                xlabel('a*')
                ylabel('b*')
                zlabel('L*')
            end
            if ~strcmp(obs,'ALL')
                for j = 1:3 %subplots
                    subplot(3,1,j); hold on
                    if strcmp(files(i).name(end-8:end-7),obs)
                        a = scatter3(files(i).dataLABcal(2,:),files(i).dataLABcal(3,:),files(i).dataLABcal(1,:),markerSize,'filled',...
                            'DisplayName',sprintf('%s-%s-%s',files(i).name(end-8:end-7),files(i).name(end-5:end-4),files(i).name(6:10)),...
                            'MarkerFaceAlpha',0.4);
                        view(2)
                    end
                    if contains(files(i).name,'AU') % If the condition is 1, make it blue
                        a.MarkerFaceColor = 'b';
                    elseif contains(files(i).name,'RB')
                        a.MarkerFaceColor = 'r';
                    else
                        disp('Something gone wrong')
                    end
                    if contains(files(i).name,'2017-10') % If it's a repeat, make it darker
                        a.MarkerFaceColor = (a.MarkerFaceColor/1.5)+[0,0.5,0];
                    end
                    if j == 1
                        view(2)
                        axis equal
                        %xlim(xlim + 30)
                        xlim([-50 200])
                        legend('Location','best')
                    elseif j == 2
                        view(0,0)
                        daspect([1,1,2])
                    elseif j == 3
                        view(-90,0)
                        daspect([1,1,2])
                    end
                    xlabel('a*')
                    ylabel('b*')
                    zlabel('L*')
                end
            end
        end
    end
elseif strcmp(colSpace,'xy')
    %drawChromaticity('1931','line')
    for i = 1:length(files)
        if (strcmp(files(i).name(end-8:end-7),obs) || (strcmp(obs,'ALL')))
            scatter3(files(i).dataxycal(1,:),files(i).dataxycal(2,:),files(i).dataXYZcal(2,:),markerSize,'filled',...
                'DisplayName',sprintf('%s-%s-%s',files(i).name(6:10),files(i).name(end-8:end-7),files(i).name(end-5:end-4)),...
                'MarkerFaceAlpha',0.4);
        end
    end
    axis equal
    % % The below (to get good plotting in 3D is a bit weird currently, needs fiddling with, sure I shouldn't have to call pbaspect
    %daspect([1,1,1000])
    %curfig = gcf;
    %pbaspect([curfig.OuterPosition(1),curfig.OuterPosition(2)*0.8,curfig.OuterPosition(2)*0.8]) %outer position isn't quite what I want here, so I'm just scaling it up manually for now
    xlabel('x')
    ylabel('y')
    zlabel('Y')
end

%save2pdf([figfile,obs])

%% Plot ellipses to summarise all data

figure('Position',[100 100 500 600]), hold on
%drawChromaticity
for i = [9,6,8,3,5,4,10,2,7,1]
    if (strcmp(files(i).name(end-8:end-7),obs) || (strcmp(obs,'ALL')))
        data(:,:,:,i) = files(i).dataLABcal;
        %data(:,:,:,i) = files(i).dataxycal;
        dfe = squeeze(data(2:3,:,:,i)); %data for ellipse (LAB)
        %dfe = squeeze(data(1:2,:,:,i)); %data for ellipse (xy)
        dfe = dfe(:,:);
        
        e = plotEllipse(dfe,0);
        a = plot(e(1,:), e(2,:),...
            'DisplayName',sprintf('%s-%s-%s',files(i).name(end-8:end-7),files(i).name(end-5:end-4),files(i).name(6:10)));
        if contains(files(i).name,'AU') % If the condition is 1, make it blue
            a.Color = 'b';
        elseif contains(files(i).name,'RB')
            a.Color = 'r';
        else
            disp('Something gone wrong')
        end
        if contains(files(i).name,'2017-10') % If it's a repeat, make it darker
            a.Color = (a.Color/1.5)+[0,0.5,0];
        end
        if contains(files(i).name,'HC')
            a.LineStyle = ':';
        elseif contains(files(i).name,'LW')
            a.LineStyle = '--';
        end
    end
end
axis equal
xlim([-20,67])
ylim([-55,55])
xlabel('a*')
ylabel('b*')
legend('Location','southeast')

%save2pdf([figfile,'SSsummary.pdf'])

%% Add Ocean Optics LED values

if ~exist('r','var') % just for debuggling when I'm running this chunk many times over
    r = OOLED;
end

ds = 30; %downsample. You don't need all the chromaticities.

figure, hold on
drawChromaticity('1931')
for i = 1:length(r)
    b = scatter3(r(i).xyY(1,r(i).startP:ds:r(i).endP),r(i).xyY(2,r(i).startP:ds:r(i).endP),r(i).xyY(3,r(i).startP:ds:r(i).endP),...
        'filled','MarkerEdgeAlpha',0.1,'MarkerFaceAlpha',0.1,...
        'DisplayName',r(i).name,'HandleVisibility','off');
    if contains(r(i).name,'AU') % If the condition is 1, make it blue
        b.MarkerFaceColor = 'b';
    elseif contains(r(i).name,'RB')
        b.MarkerFaceColor = 'r';
    else
        disp('Something gone wrong')
    end
end
daspect([1,1,500]) %Neat to see in 3D
legend off
%save2pdf('OOwide')

xlim([0.3775, 0.5161])
ylim([0.1764, 0.3151])
for i = 1:length(r)
    text(r(i).xyY(1,r(i).endP),r(i).xyY(2,r(i).endP),r(i).name,'Interpreter','None');
end
% (Then fiddle around manually with labels so that they don't overlap)
%save2pdf('OO')

%% Add gamut

vals = [1,4,6,8,10,12,15,18,21];

figure('DefaultAxesColorOrder',cbrewer('qual', 'Set1' , length(vals))), hold on
drawChromaticity
daspect([1,1,100])
for j = 1:length(files)
    for i = vals
        plot3(squeeze(files(j).screenxyY(1,i,[1,2,3,1])),...
            squeeze(files(j).screenxyY(2,i,[1,2,3,1])),...
            squeeze(files(j).screenxyY(3,i,[1,2,3,1])),...
            'DisplayName',num2str(sval(i)));
        
    end
    if j == 1
        legend('Location','best','AutoUpdate','off')
    end
end

%figure,
for trial = 1:length(files)
    if trial == length(files)
        legend('AutoUpdate','on')
    end
    scatter3(files(trial).screenxyw(1),files(trial).screenxyw(2),100,'k',...
        'DisplayName','Wt-Pts')   
end
%save2pdf([figfile,'SSgamut.pdf'])

%% Secondary calibration

SmallSphereCalibrationCheck('2017-7-21-9-29_LW_RB')

%save2pdf([figfile,'SSseccal.pdf'])

%% Plot all data in CIE 1931 xy, showing time as marker size
% Needs checking, haven't used in a long time

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

%% Means and standard deviations
for i=1:length(files)
    m(i,:)  = mean(files(i).dataLABcal(:,:),2);
    sd(i,:) = std(files(i).dataLABcal(:,:),[],2);
end

order = [9,6,8,3,5,4,10,2,7,1];
% Getting them in a sensible order
mOrder = m(order,:);
sdOrder = sd(order,:);
for i=1:length(order)
    namesOrder{i} = {sprintf('%s-%s-%s',files(order(i)).name(end-8:end-7),files(order(i)).name(end-5:end-4),files(order(i)).name(6:10))};
end

% figure, hold on
% scatter3(m(:,2),m(:,3),m(:,1),'k')
% daspect([1,1,2])
% 
% xlabel('a*')
% ylabel('b*')
% zlabel('L*')

%% Stats on xy

[Hxy(1), pValuexy(1)] = kstest_2s_2d(files(6).dataxycal(1:2,:)', files(9).dataxycal(1:2,:)', 0.05); %DG
[Hxy(2), pValuexy(2)] = kstest_2s_2d([files(3).dataxycal(1:2,:)';files(8).dataxycal(1:2,:)'],...
    [files(4).dataxycal(1:2,:)';files(5).dataxycal(1:2,:)'], 0.05); %HC
[Hxy(3), pValuexy(3)] = kstest_2s_2d([files(1).dataxycal(1:2,:)';files(7).dataxycal(1:2,:)'],...
    [files(2).dataxycal(1:2,:)';files(10).dataxycal(1:2,:)'], 0.05); %LW

%% Stats on LAB

[HLAB(1), pValueLAB(1)] = kstest_2s_2d(files(6).dataLABcal(2:3,:)', files(9).dataLABcal(2:3,:)', 0.05); %DG
[HLAB(2), pValueLAB(2)] = kstest_2s_2d([files(3).dataLABcal(2:3,:)';files(8).dataLABcal(2:3,:)'],...
    [files(4).dataLABcal(2:3,:)';files(5).dataLABcal(2:3,:)'], 0.05); %HC
[HLAB(3), pValueLAB(3)] = kstest_2s_2d([files(1).dataLABcal(2:3,:)';files(7).dataLABcal(2:3,:)'],...
    [files(2).dataLABcal(2:3,:)';files(10).dataLABcal(2:3,:)'], 0.05); %LW

%megastats

for i = 1:length(files)
    for j = 1:length(files)
        [HLABmega(i,j), pValueLABmega(i,j)] = kstest_2s_2d(files(i).dataLABcal(2:3,:)', files(j).dataLABcal(2:3,:)', 0.05/45);
    end
end
    
stats.m  = m;
stats.sd = sd;
stats.H  = HLAB;
stats.p  = pValueLAB;



end