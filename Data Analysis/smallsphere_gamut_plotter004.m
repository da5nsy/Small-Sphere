%Plot screen gamut and LED chromaticities

clear, clc, close all

[cielambda,xbar,ybar,zbar]=loadCIE(1931);

%% Plot LED chromaticities (3D)
plot1931(3,xbar,ybar,zbar);

load('C:\Users\ucesars\Dropbox\UCL\Ongoing Work\Small Sphere\led_xy.mat')
plot3([U_xy(1),A_xy(1)],[U_xy(2),A_xy(2)],[0,0],'k')
plot3([R_xy(1),B_xy(1)],[R_xy(2),B_xy(2)],[0,0],'k')

scatter3(R_xy(1),R_xy(2),0,'r','filled')
text(R_xy(1)+.03,R_xy(2),0,'R')
scatter3(B_xy(1),B_xy(2),0,'b','filled')
text(B_xy(1)+.03,B_xy(2),0,'B')
scatter3(A_xy(1),A_xy(2),0,'y','filled')
text(A_xy(1)+.03,A_xy(2),0,'A')
scatter3(U_xy(1),U_xy(2),0,'k','filled')
text(U_xy(1)+.03,U_xy(2),0,'U')

%Load screen calibration data
load('C:\Users\ucesars\Dropbox\UCL\Data\Large Sphere\Large LCD display measurement - Oct 2016.mat')
screen_xy=zeros(2,21,4);
for i=1:21
    for j=1:4
        screen_xy(1,i,j)=XYZ(1,i,j)./sum(XYZ(:,i,j));
        screen_xy(2,i,j)=XYZ(2,i,j)./sum(XYZ(:,i,j));
    end
    plot3(squeeze(screen_xy(1,i,[1,2,3,1])),...
        squeeze(screen_xy(2,i,[1,2,3,1])),...
        squeeze(XYZ(2,i,[1,2,3,1])),'k:');
end

set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))])

%%

%3D scatter with gamut flag

highL=85;   %max 85
lowL=10;    %min 10

for j=18-highL/5:18-lowL/5
    
    %temp start
    figure, hold on
    plot3(xbar./(xbar+ybar+zbar),ybar./(xbar+ybar+zbar),ones(length(xbar),1)*100,'k')
    % with purples - not working
    % plot3([xbar./(xbar+ybar+zbar);xbar(1)./(xbar(1)+ybar(1)+zbar(1))]...
    %     ,[ybar./(xbar+ybar+zbar);xbar(1)./(xbar(1)+ybar(1)+zbar(1))]...
    %     ,ones(length(xbar)+1,1)*100,'k')
    
    plot3([U_xy(1),A_xy(1)],[U_xy(2),A_xy(2)],[100,100],'k')
    plot3([R_xy(1),B_xy(1)],[R_xy(2),B_xy(2)],[100,100],'k')
    
    scatter3(R_xy(1),R_xy(2),100,'r','filled')
    text(R_xy(1)+.03,R_xy(2),100,'R')
    scatter3(B_xy(1),B_xy(2),100,'b','filled')
    text(B_xy(1)+.03,B_xy(2),100,'B')
    scatter3(A_xy(1),A_xy(2),100,'y','filled')
    text(A_xy(1)+.03,A_xy(2),100,'A')
    scatter3(U_xy(1),U_xy(2),100,'k','filled')
    text(U_xy(1)+.03,U_xy(2),100,'U')
    
    %Load screen calibration data
    load('C:\Users\ucesars\Dropbox\UCL\Data\Large Sphere\Large LCD display measurement - Oct 2016.mat')
    screen_xy=zeros(2,21,4);
    for k=1:21
        for l=1:4
            screen_xy(1,k,l)=XYZ(1,k,l)./sum(XYZ(:,k,l));
            screen_xy(2,k,l)=XYZ(2,k,l)./sum(XYZ(:,k,l));
        end
        plot3(squeeze(screen_xy(1,k,[1,2,3,1])),...
            squeeze(screen_xy(2,k,[1,2,3,1])),...
            squeeze(XYZ(2,k,[1,2,3,1])),'k:');
    end
    %temp end
    for  i=1:length(files)
        
        %pause(0.2)
        scatter3(   squeeze(files(i).dataxy(1,j,:)),...
            squeeze(files(i).dataxy(2,j,:)),...
            squeeze(files(i).dataXYZ(2,j,:)),...
            [],[squeeze(max(files(i).dataRGBcalgam(:,j,:))),zeros(10,1),zeros(10,1)])
    end
    
    %put following section outside loop if not creating fresh plot for each L*
    %title('All data (small sphere)');
    title(sprintf('L* = %d',(18-j)*5));
    xlabel('x')
    ylabel('y')
    zlabel('Y')
    %haven't gone through what the below means but it seems to work
    %...for setting x and y equal but scaling z (Y)
    %from: https://uk.mathworks.com/matlabcentral/newsreader/view_thread/303179
    set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))])
    
end

%1:3 not good, lots of out of gamut - 85,80,75 = no good
% 5 bottom ones look pretty low down, but no definitive reason for
% excluding - 10,15,20,25,30,
%35:5:70


% %2D gscatter
% figure, hold on
% 
% highL=85;   %max 85
% lowL=10;    %min 10
% 
% for i=1:length(files)
%     for j=18-highL/5:18-lowL/5
%         pause(0.1)
%         gscatter(   squeeze(files(i).dataxy(1,j,:)),...
%             squeeze(files(i).dataxy(2,j,:)),...
%             squeeze(max(files(i).dataRGBcalgam1(:,1,:))))
%     end
% end


% Struggled because gscatter3 cannot accept logicals as group, I think
% gscatter can

% highL=85;   %max 85
% lowL=10;    %min 10
% 
% for i=1:length(files)
%     for j=18-highL/5:18-lowL/5
%         pause(0.1)
%         gscatter3(   squeeze(files(i).dataxy(1,j,:)),...
%             squeeze(files(i).dataxy(2,j,:)),...
%             squeeze(files(i).dataXYZ(2,j,:)),...
%         any(files(1).dataRGBcalgam1(:,1,:))...
%             ,5,'k','filled')
%     end
% end

%% 3d scatter for light0/1/AM/PM
highL=85;   %max 85
lowL=10;    %min 10

hold on
for i=1:length(files)
    for j=18-highL/5:18-lowL/5
        pause(0.1)

        if files(i).name(end-4)=='0'
            if str2num(files(i).date(13:14))>12
                sc1= scatter3(   squeeze(files(i).dataxy(1,j,:)),...
                                squeeze(files(i).dataxy(2,j,:)),...
                                squeeze(files(i).dataXYZ(2,j,:))...
                    ,5,[1,.6,.6],'filled', ...
                    'DisplayName','Light 0, PM'); % light red = light 0, PM
            else
                sc2= scatter3(   squeeze(files(i).dataxy(1,j,:)),...
                                squeeze(files(i).dataxy(2,j,:)),...
                                squeeze(files(i).dataXYZ(2,j,:))...
                    ,5,[.8,.2,.2],'filled',...
                    'DisplayName','Light 0, AM'); % dark red = light 0, AM
            end
        else
            if str2num(files(i).date(13:14))>12
                sc3= scatter3(   squeeze(files(i).dataxy(1,j,:)),...
                                squeeze(files(i).dataxy(2,j,:)),...
                                squeeze(files(i).dataXYZ(2,j,:))...
                    ,5,[.6,.6,1],'filled',...
                    'DisplayName','Light 1, PM'); % light blue = light 1, PM
            else
                sc4= scatter3(   squeeze(files(i).dataxy(1,j,:)),...
                                squeeze(files(i).dataxy(2,j,:)),...
                                squeeze(files(i).dataXYZ(2,j,:))...
                    ,5,[.2,.2,.8],'filled',...
                    'DisplayName','Light 1, AM'); % dark blue = light 1, AM
            end
       end
       
    end
%     text(median(median(files(i).dataLABcal(2,:,:)))-30, ...
%         median(median(files(i).dataLABcal(3,:,:))),...
%         files(i).name(6:end))
   % axis([-20 35 -60 20])
    %axis('equal')
end



legend([sc1(1),sc2(1),sc3(1),sc4(1)],'location','southwest')
title('All data (small sphere)');
xlabel('x')
ylabel('y')
zlabel('Y')

%haven't gone through what the below means but it seems to work
%...for setting x and y equal but scaling z (Y)
%from: https://uk.mathworks.com/matlabcentral/newsreader/view_thread/303179
set(gca, 'DataAspectRatio', [repmat(min(diff(get(gca, 'XLim')), diff(get(gca, 'YLim'))), [1 2]) diff(get(gca, 'ZLim'))])

%% Run 2 data

figure, hold on
for i=1:length(files)
    for  j=1:5
        scatter3(   squeeze(files(i).dataxy(1,j,:)),...
            squeeze(files(i).dataxy(2,j,:)),...
            squeeze(files(i).dataXYZ(2,j,:)),...
            [],[squeeze(max(files(i).dataRGBcalgam(:,j,:))),zeros(30,1),zeros(30,1)])
    end
end

%
%Using reshape such as below could avoid the j loop above, if that was ever
%particularly useful

%reshape(files(2).dataxy,2,150);
