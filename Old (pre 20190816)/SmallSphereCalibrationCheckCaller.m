clc, close all
d=2;

% plotCIE(d,xbar2,ybar2,zbar2)
% hold on

%obs={'DG_AU','DG_RB','HC_AU','HC_RB','LW_AU','LW_RB'};


for ob=1:6
    plotCIE(d,xbar2,ybar2,zbar2)
    hold on
    SmallSphereCalibrationCheck(obs{ob},2)%d)
    %     title(obs{ob})
    %     xlabel('Wavelength(nm)')
    %     ylabel('Recombined spectrum - Measured Spectrum')
end


xlabel('1931 x')
ylabel('1931 y')
legend('show')

%set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))])

%%

obs='Characterization without LEDs'

plotCIE(d,xbar2,ybar2,zbar2)
hold on
SmallSphereCalibrationCheck(obs,2)