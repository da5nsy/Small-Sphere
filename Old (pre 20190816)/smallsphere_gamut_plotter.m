%clear, clc, close all
%add some data

%Plot screen gamut and LED chromaticities

%load CIE data
ciefile = fullfile('C:','Users','ucesars','Dropbox','UCL','Data',...
    'Colour Standards','CIE colorimetric data','CIE_colorimetric_tables.xls');
ciedata= xlsread(ciefile,'1964 col observer','A6:D86');
% figure, plot(ciedata(:,1),ciedata(:,2),...
%     ciedata(:,1),ciedata(:,3),
%     ciedata(:,1),ciedata(:,4))
% legend('show')
cielambda=ciedata(:,1);
xbar=ciedata(:,2);
ybar=ciedata(:,3);
zbar=ciedata(:,4);


%% Plot LED chromaticities
load('C:\Users\ucesars\Dropbox\UCL\Ongoing Work\Small Sphere\led_xy.mat')

figure, hold on
plot(xbar./(xbar+ybar+zbar),ybar./(xbar+ybar+zbar),'k')

plot([U_xy(1),A_xy(1)],[U_xy(2),A_xy(2)],'k')
plot([R_xy(1),B_xy(1)],[R_xy(2),B_xy(2)],'k')

scatter3(R_xy(1),R_xy(2),1,'r','filled')
text(R_xy(1)+.03,R_xy(2),1,'R')
scatter3(B_xy(1),B_xy(2),1,'b','filled')
text(B_xy(1)+.03,B_xy(2),1,'B')
scatter3(A_xy(1),A_xy(2),1,'y','filled')
text(A_xy(1)+.03,A_xy(2),1,'A')
scatter3(U_xy(1),U_xy(2),1,'k','filled')
text(U_xy(1)+.03,U_xy(2),1,'U')


%

load('C:\Users\ucesars\Dropbox\UCL\Data\Large Sphere\Large LCD display measurement - Oct 2016.mat')

RGBW_xy=zeros(2,4);

for i=1:4
    RGBW_xy(1,i)=RGBW_XYZ(1,i)/sum(RGBW_XYZ(:,i));
    RGBW_xy(2,i)=RGBW_XYZ(2,i)/sum(RGBW_XYZ(:,i));
end

plot3(RGBW_xy(1,[1,2,3,1]),RGBW_xy(2,[1,2,3,1]),[1,1,1,1],'k:')
scatter3(RGBW_xy(1,4),RGBW_xy(2,4),1,'k*')

%Plot the screen gamut
%Make sure they're both using 10 degree observer
%Plot some of the data (perhaps just the ones which hit gamut edge?)

axis square
xlabel('x_6_4')
ylabel('y_6_4')