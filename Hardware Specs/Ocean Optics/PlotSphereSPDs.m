

clear, clc, close all

DGdisplaydefaults;

cd('C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data\Run 2 data\Ocean Optics Summary');

%%

figure, hold on

load('20170720 HC_RBsummary.mat')

plot(wl,SPDav,'DisplayName','HC_RB_0720')

clear

load('20170721 HC_AUsummary.mat')

plot(wl,SPDav,'DisplayName','HC_AU_0722')

axis tight
xlim([380 680])
ylim([0 1])

xlabel('Wavelength (nm)')
ylabel('Relative SPD')

legend('Location','best','Interpreter','None')

%%

save2pdf('C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Hardware Specs\Ocean Optics\LED_SPDcontrast.pdf')


