function r = OOLED

% Small Sphere LED Chromaticities Over Time
% OOLED - Ocean Optics LED

%%
%clear, clc, close all

% Display Settings
DGdisplaydefaults;

plt = 0;

%%

r = dir('C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data\Run 2 data\Ocean Optics\201*');
r = rmfield(r,{'date','bytes','isdir','datenum'});

%%
for i=1:length(r)
    disp(r(i).name)
    [~,r(i).xyY,r(i).startP,r(i).endP,r(i).MP] = OO_smallSphere_002(r(i).name);
end

% Would be nice to rewrite this so that it could all be loaded from the
% summary data if someone in the future didn't have access to all the OO
% data. Should be possible.

%% Averages

if plt
    figure, hold on
    DrawChromaticity('1931')
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
end

%% All (downsampled) points, translucent
if plt
    ds = 30; %downsample. You don't need all the chromaticities.
    
    figure, hold on
    DrawChromaticity('1931')
    for i = 1:length(r)
        scatter3(r(i).xyY(1,r(i).startP:ds:r(i).endP),r(i).xyY(2,r(i).startP:ds:r(i).endP),r(i).xyY(3,r(i).startP:ds:r(i).endP),...
            'filled','MarkerEdgeAlpha',0.1,'MarkerFaceAlpha',0.1)
    end
    daspect([1,1,50])
end

    