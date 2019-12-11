clear, clc, close all

rootdir = 'C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data\Run 2 data\PR650';
cd(rootdir)
d = dir();
d = d(3:13); %remove unwanted files/folders

%%

lev = 12;%6;

%mean = 115, sval 12 = 111
%min = 24, sval 6 = 25

for i = 1:length(d)
    load([d(i).folder,'/',d(i).name,'/','Large LCD display measurement.mat'])
    xy(:,i) = [XYZ(1,lev,4)/sum(XYZ(:,lev,4)),XYZ(2,lev,4)/sum(XYZ(:,lev,4))];
end

%%
figure, hold on
DrawChromaticity
scatter(xy(1,1:end-1),xy(2,1:end-1),'r*')
scatter(xy(1,end),xy(2,end),'k*')

%save2pdf(['C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data Analysis\figs\','ScreenShieldingAnalysis'])