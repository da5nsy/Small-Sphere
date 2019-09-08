clear, clc, close all

% Display Settings
set(groot,'defaultfigureposition',[100 100 500 400])
set(groot,'defaultLineLineWidth',2)
set(groot,'defaultAxesFontName', 'Courier')
set(groot,'defaultAxesFontSize',12)
set(groot,'defaultFigureRenderer', 'painters') %renders pdfs as vector graphics
set(groot,'defaultfigurecolor','white')
set(groot,'defaultAxesColorOrder',hsv(10))

%%

r = dir('C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data\Run 2 data\Ocean Optics\201*');

r = rmfield(r,{'date','bytes','isdir','datenum'});

%%
for i=1:length(r)
    disp(r(i).name)
    [~,r(i).xyY,r(i).startP,r(i).endP] = OO_smallSphere_002(r(i).name);
end

% Would be nice to rewrite this so that it could all be loaded from teh
% summary data if someone in the future didn't have access to all the OO
% data. Should be possible.

%% Averages

figure, hold on
drawChromaticity('1931')
for i = 1:length(r)
    r(i).med_xyY = [median(r(i).xyY(1,r(i).startP:r(i).endP)),...
        median(r(i).xyY(2,r(i).startP:r(i).endP)),...
        median(r(i).xyY(3,r(i).startP:r(i).endP))];
    %disp(r(i).med_xyY)
    scatter3(r(i).med_xyY(1),r(i).med_xyY(2),r(i).med_xyY(3),...
        'filled','MarkerFaceAlpha',0.7)
end
daspect([1,1,50])
legend(r.name,'Interpreter','None','Location','best')

%% All (downsampled) points, translucent
ds = 30; %downsample. You don't need all the chromaticities.

figure, hold on
drawChromaticity('1931')
for i = 1:length(r)
    scatter3(r(i).xyY(1,r(i).startP:ds:r(i).endP),r(i).xyY(2,r(i).startP:ds:r(i).endP),r(i).xyY(3,r(i).startP:ds:r(i).endP),...
        'filled','MarkerEdgeAlpha',0.1,'MarkerFaceAlpha',0.1)
end
daspect([1,1,50])

    