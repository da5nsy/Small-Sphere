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

N = 30;                             % number of repetitions over time
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

% % Plot display white points


figure, hold on
drawChromaticity('1931')
for trial = 1:length(files)
    scatter(files(trial).screenxyw(1),files(trial).screenxyw(2),'k')
end

%%

figure, hold on
colSpace = 'LAB';
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
    axis equal
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

%save2pdf(['C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data Analysis\figs\',obs])

%% Plot ellipses to summarise all data

figure, hold on
drawChromaticity
for i = [9,6,8,3,5,4,10,2,7,1]
    %data(:,:,:,i) = files(i).dataLABcal;
    data(:,:,:,i) = files(i).dataxycal;
    %dfe = squeeze(data(2:3,:,:,i)); %data for ellipse (LAB)
    dfe = squeeze(data(1:2,:,:,i)); %data for ellipse (xy)
    dfe = dfe(:,:);
    
    e = plotEllipse(dfe,0);
    a = plot(e(1,:), e(2,:),...
        'DisplayName',sprintf('%s-%s-%s',files(i).name(6:10),files(i).name(end-8:end-7),files(i).name(end-5:end-4)));
    if contains(files(i).name,'AU') % If the condition is 1, make it blue
        a.Color = 'b';
    elseif contains(files(i).name,'RB')
        a.Color = 'r';
    else
        disp('Something gone wrong')
    end
    if contains(files(i).name,'2017-10') % If it's a repeat, make it darker
        a.Color = a.Color/2;
    end
    if contains(files(i).name,'HC')
        a.LineStyle = ':';
    elseif contains(files(i).name,'LW')
        a.LineStyle = '--';
    end
end
axis equal
legend('Location','best')


%% Add Ocean Optics LED values

if ~exist('r','var') % just for debuggling when I'm running this chunk many times over
    r = OOLED;
end

ds = 30; %downsample. You don't need all the chromaticities.

%figure, hold on
%drawChromaticity('1931')
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

%%

xlim([0.3775, 0.5161])
ylim([0.1764, 0.3151])
for i = 1:length(r)
text(r(i).xyY(1,r(i).endP),r(i).xyY(2,r(i).endP),r(i).name,'Interpreter','None'); 
end
% (Then fiddle around manually with labels so that they don't overlap)
%save2pdf('OO')

%% Add gamut

%figure, hold on
%drawChromaticity
daspect([1,1,100])
for j = 1:length(files)
    for i = 1:3:size(files(j).screenxyY,2)        
        plot3(squeeze(files(j).screenxyY(1,i,[1,2,3,1])),...
            squeeze(files(j).screenxyY(2,i,[1,2,3,1])),...
            squeeze(files(j).screenxyY(3,i,[1,2,3,1])));
        
    end
    ax = gca;
    ax.ColorOrderIndex = 1;
end

% make it one colour per file


% % Note that this is just for the last loaded characterization
% figure, hold on
% screen_xy = zeros(2,21,4);
% for i=21%1:21
%     for j=1:4
%         screen_xy(1,i,j) = XYZ(1,i,j)./sum(XYZ(:,i,j));
%         screen_xy(2,i,j) = XYZ(2,i,j)./sum(XYZ(:,i,j));
%     end
%     plot3(squeeze(screen_xy(1,i,[1,2,3,1])),...
%         squeeze(screen_xy(2,i,[1,2,3,1])),...
%         squeeze(XYZ(2,i,[1,2,3,1])),'k:');
% end




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