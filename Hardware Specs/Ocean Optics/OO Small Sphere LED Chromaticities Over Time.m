clear, clc, close all

r = dir('C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data\Run 2 data\Ocean Optics\201*');

r = rmfield(r,{'date','bytes','isdir','datenum'});

%%
for i=1:length(r)
    disp(r(i).name)
    [~,r(i).xyY,r(i).startP,r(i).endP] = OO_smallSphere_002(r(i).name);
end

%% Averages

figure, hold on
drawChromaticity('1931')
for i = 1:length(r)
    r(i).med_xyY = [median(r(i).xyY(1,r(i).startP:r(i).endP)),...
        median(r(i).xyY(2,r(i).startP:r(i).endP)),...
        median(r(i).xyY(3,r(i).startP:r(i).endP))];
    disp(r(i).med_xyY)
    scatter3(r(i).med_xyY(1),r(i).med_xyY(2),r(i).med_xyY(3),...
        'k','filled','MarkerFaceAlpha',0.5)
end
daspect([1,1,50])

%% All (downsampled) points, translucent
ds = 30; %downsample. You don't need all the chromaticities.

figure, hold on
drawChromaticity('1931')
for i = 1:length(r)
    scatter3(r(i).xyY(1,r(i).startP:ds:r(i).endP),r(i).xyY(2,r(i).startP:ds:r(i).endP),r(i).xyY(3,r(i).startP:ds:r(i).endP),...
        'k','filled','MarkerEdgeAlpha',0.1,'MarkerFaceAlpha',0.1)
end
daspect([1,1,50])
    