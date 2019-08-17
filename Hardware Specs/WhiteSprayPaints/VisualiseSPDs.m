% Should specify folders with uigetdir(start_path,dialog_title) and make
% into a run-able script...

% Load Pr650 measurements

clear, clc, close all

%% Pre run commands:

rootdir = 'C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Hardware Specs\WhiteSprayPaints';

%titles={'tungsten','tungsten refs (df and macbeth)','uvamber','uvamber refs (df and macbeth)'};
titles={'tungstenanduvamber','tunsgstenanduvamber refs (df and macbeth)'}; %Using these because tungsten alone has very low output below 400nm, uv should give a nice little boost

for i=1:length(titles)
    filename{i}=fullfile(rootdir,titles{i});
end

clear i j

%% Load data

for j=1:length(filename)
    cd(filename{j});
    files= dir('*.mat');
    
    for file = 1:length(files)
        load(files(file).name);
        data(1:101,file,j)=spc(:,2);
        %fig=figure; plot(spc(:,1),spc(:,2));
        %title(files(file).name);
        %saveas(fig,strcat(files(file).name(1:end-4),'.tif'))
        %close
        
    end
end

lambda=spc(:,1);
clear spc

%% DFC

%create
DFC=mean(data(:,7:9,2),2);
figure,plot(lambda,DFC)
title('Dark Field Correction')

%apply
dataDFC=data;
for i=1:24
    dataDFC(:,i,1)=data(:,i,1)-DFC;
    %figure, hold on
    %plot(dataDFC(:,i,1),'r')
    %plot(data(:,i,1),'k')
end

for i=4:6
    dataDFC(:,i,2)=data(:,i,2)-DFC;
end


% %create
% DFCtungsten=mean(data(:,1:3,2),2);
% %figure,plot(DFCtungsten)
% DFCuvamber=mean(data(:,1:3,4),2);
% %figure,plot(DFCuvamber)
% 
% %apply
% dataDFC=data;
% for i=1:24
%     dataDFC(:,i,1)=data(:,i,1)-DFCtungsten;
%     dataDFC(:,i,3)=data(:,i,3)-DFCuvamber;
%     %figure, hold on
%     %plot(dataDFC(:,i,1),'r')
%     %plot(data(:,i,1),'k')
% end
% 
% for i=4:6
%     dataDFC(:,i,2)=data(:,i,2)-DFCtungsten;
%     dataDFC(:,i,4)=data(:,i,4)-DFCuvamber;
% end

%% Calculate reflectance (taking colourchecker as perfect white)

%calculate reference whites under each illumination
mbcc=mean(dataDFC(:,1:6,2),2);
figure,
plot(lambda,mbcc)
title('MacBeth Colour Checker white')

reflectance=zeros(size(dataDFC));

%col={'r','b','g','y','k','c','m',[0,.5,0]};
col={[0,.1,.9],[1,.9,.3],[.7,.9,.2],[.8,.8,.9],...
    [.4,.5,.5],[.1,.7,.5],[.7,0,0],[0,.5,.9],[0,0,0]};

% figure, hold on
% for i=1:size(data,2)
%     reflectance(:,i,1)=dataDFC(:,i,1)./mbcc;
%     plot(lambda,reflectance(:,i,1),'Color',col{ceil(i/3)})
% end

figure('Position',[100 100 500 800]),
hold on
for i=1:3:size(data,2)-1
    reflectance(:,i,1)=dataDFC(:,i,1)./mbcc;
    plot(lambda,reflectance(:,i,1),'Color',col{ceil(i/3)})
end

i=size(data,2);
reflectance(:,i,1)=dataDFC(:,i,1)./mbcc;
plot(lambda,reflectance(:,i,1),':','Color',col{ceil(i/3)})

legend({'Flame Blue FB-900 pure white'
'Montana Gold Sh. White Cream'
'Montana Gold Pebble'
'Montana Gold Sh. White Pure'
'MTN 94 RV-198 Stardust Grey'
'MTN 94 Matt White'
'Montana Black BLK400-9100 Snow White'
'MTN Water Based W9010 Titanium White'
'White Paper'},...
    'Location','northoutside')
xlabel('Wavelength(nm)')
ylabel('Reflectance, relative to MBCC white')

save2pdf('VisualiseSPDs_result.pdf')


% for i=1:3:24
%     figure, hold on
%     plot(lambda,reflectance(:,i,1))
%     plot(lambda,reflectance(:,i+1,1))
%     plot(lambda,reflectance(:,i+2,1))
% end


% %calculate reference whites under each illumination
% tungstenref=mean(dataDFC(:,4:6,2),2);
% uvamberref=mean(dataDFC(:,4:6,4),2);
% %plot(tungstenref)
% %plot(uvamberref)
% 
% reflectance=dataDFC;
% col={'r','b','g','y','k','c','m','g'};
% 
% figure, hold on
% for i=[1,2,3,22,23,24]%1:24  
%     reflectance(:,i,1)=dataDFC(:,i,1)./tungstenref;
%     plot(lambda,reflectance(:,i,1),col{ceil(i/3)})
% end
% figure, hold on
% for i=[1,2,3,22,23,24]%1:24 
%     reflectance(:,i,3)=dataDFC(:,i,3)./uvamberref;
%     plot(lambda,reflectance(:,i,3),col{ceil(i/3)})
% end
% 
% % for i=1:3:24
% %     figure, hold on
% %     plot(lambda,reflectance(:,i,1))
% %     plot(lambda,reflectance(:,i+1,1))
% %     plot(lambda,reflectance(:,i+2,1))
% % end


