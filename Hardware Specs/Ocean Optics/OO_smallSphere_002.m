function [SPDav,xyY,startP,endP] = OO_smallSphere_002(obs)
%Handles data collected with the Ocean Optics USB 2000+ during small sphere
%experiments, measuring the interior chromaticity of the sphere at 5 second
%intervals

%Loads data
%Plots sum of radiance values (for telling when lights were on/off)
%Specifies when each session started and ended
%Plots spectra
%Calculates XYZ and xy
%Plots xy

%% Read data
%clear, clc, close all
%obs = '20171019 HC_RB'; 
%uncomment the above when using as a script rather than a function

% Set Input Folder
rootdir = fullfile('C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data\Run 2 data\Ocean Optics\',obs);
cd(rootdir)

try
    load(sprintf('%s.mat',obs));
catch
    
    % Import Data
    txtfls = dir('*.txt');                    %Creates struct of all .txt files
    N = 2048;
    LEDrad = zeros(N,2,length(txtfls),'double');
    
    %
    
    for k = 1:length(txtfls)
        fid = fopen(txtfls(k).name,'r');
        for i = 1:14
            tline = fgetl(fid);                 % skip header (17 lines)
        end
        
        for n = 1:N
            tline = fgetl(fid);                 % read one line of data
            LEDrad(n,:,k) = sscanf(tline,'%f %f');
        end
        fprintf('%d/%d\n',k,length(txtfls));
        fclose(fid);
        clear k i n tline fid                  %cleanup
    end
    save(obs)
end

load('C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Hardware Specs\Ocean Optics\correction vector.mat');

% %% Plot time course of recording, to select dfc and measurement goalposts
% %Would be nice to plot against time, but this seems tricky
% 
% %figure,
% plot(sum(squeeze(LEDrad(:,2,:))));
%% Plot spectra

% The measurements were taken before, during and after the experiments
% Here start and end points are set for each run, and times when a dark
% correction was recorded are noted.
if  strcmp(obs,'20170720 LW_AU')
    startP = 80;    
    endP = 770; 
    dfc = median(LEDrad(:,2,20:70),3); 
elseif strcmp(obs,'20170720 HC_RB')
    startP = 830;    
    endP = 1790;
    dfc = median(LEDrad(:,2,20:70),3); 
elseif strcmp(obs,'20170720 DG_RB')
    startP = 50;    
    endP = 645;  
    dfc = median(LEDrad(:,2,20:24),3);
elseif strcmp(obs,'20170721 LW_RB')
    startP = 215;    
    endP = 595; 
    dfc = median(LEDrad(:,2,1:15),3);
elseif strcmp(obs,'20170721 HC_AU')
    startP = 10;    
    endP = 515;
    dfc = median(LEDrad(:,2,1:3),3);
elseif strcmp(obs,'20170721 DG_AU')
    startP = 40;    
    endP = 650;
    dfc = median(LEDrad(:,2,2:10),3);
elseif strcmp(obs,'20171011 LW_AU')
    startP = 150;
    endP = 544;
    dfc = median(LEDrad(:,2,2566:2578),3);
elseif strcmp(obs,'20171012 LW_RB')
    startP = 75;
    endP = 405;
    dfc = median(LEDrad(:,2,[2490:2493,2497:2508]),3);
elseif strcmp(obs,'20171018 HC_AU')
    startP = 50;
    endP = 314;
    % there does not seem to be any dark time in this recording
elseif strcmp(obs,'20171019 HC_RB') %%%
    startP = 90;
    endP = 457;
    dfc = median(LEDrad(:,2,1206:1217),3);
else
    error('Unknown start/end points')
end

wavelength = LEDrad(:,1,1);

% The following plots the spectra of the first reading, and then
% successively plots the rest of the data (in between startP and endP) to
% allow for comparison over time.
%
% Same goes for chromaticity except all the chromaticities are shown.

load T_xyz1931.mat T_xyz1931 S_xyz1931

wlSi = 107;  %wavelength start
wlEi = 1231; %wavelength end

%Interpolates CIEdata to fit OO wavelength intervals
% T_xyz1931 = SplineCmf(S_xyz1931,T_xyz1931,wavelength(wlSi:wlEi)); %can't do this  because PTB needs evenly spaced samples
T_xyz1931 = interp1(SToWls(S_xyz1931),T_xyz1931',wavelength(wlSi:wlEi),'spline'); % roughly 380:780

if exist('dfc','var')
    SPD = squeeze((LEDrad(wlSi:wlEi,2,:)-dfc(wlSi:wlEi)).*correction_vector(wlSi:wlEi));
else
    SPD = squeeze(LEDrad(wlSi:wlEi,2,:).*correction_vector(wlSi:wlEi));
end

XYZ = SPD'*T_xyz1931;
xyY = XYZToxyY(XYZ');

plt_SPDs = 0;

if plt_SPDs        
    figure('units','normalized','outerposition',[0 0 1 1]);  hold on;

    s(1) = subplot(1,2,1);
    hold on
    grid on
    grid minor
    xlabel('Wavelength (nm)');
    ylabel('Ocean Optics DFC Data');
    %ylim([0 1])
    %axis([380,780,0,1]);
    
    plot(s(1),wavelength(wlSi:wlEi),SPD(:,startP),'k') % first measurement as reference
    
    s(2) = subplot(1,2,2);
    hold on
    axis equal    
    xlabel('x')
    ylabel('y')

    for k = startP:endP
        pause(0.1)
        title(s(1),[obs,' ', txtfls(k).name(end-15:end-8)],'Interpreter','none');
        
        %Plot calibrated data (it gets noisy in the extremes)
        %plot(wavelength(wlSi:wlEi),(LEDrad(wlSi:wlEi,2,k)-dfc(wlSi:wlEi)).*correction_vector(wlSi:wlEi),'k');  
        cla(s(1))
        plot(s(1),wavelength(wlSi:wlEi),SPD(:,startP),'k')
        plot(s(1),wavelength(wlSi:wlEi),SPD(:,k),'b')
        
        %Plot uncalibrated data
        %     plot(wavelength,LEDrad(:,2,startP)-dfc,'b');
        %     plot(wavelength,LEDrad(:,2,k)-dfc,'k');
        
        %scatter(s(2),xyY(1,k),xyY(2,k),'k.');
        drawnow

    end
end
% 
% %Notes
% 
% %LW_AU
% %Both UV and A slowly shift to slightly longer wavelengths
% %Amber drops slightly
% %something interrupts around 8:50, just below amber peak, unknown source
% %there's a break in the data 9:00-9:15 where the laptop went to sleep
% 
% %HC_RB
% %Both R and B increase, with R shifting to a slightly lower wavelength
% 
% %DG_RB
% %Both increase, only slightly
% 
% %LW_RB
% %Both increase, slightly
% 
% %HC_UA
% %A drops considerably  and shifts slightly higher
% %U increases slightly, and shifts slightly higher

%%
% figure, hold on
% for i = startP:endP
%     plot(SPD(:,i),'k')
% end
% figure
wl = wavelength(wlSi:wlEi);
%SPDshort = SPD(:,startP:endP);
SPDav = median(SPD(:,startP:endP),2);

save(['C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data\Run 2 data\Ocean Optics Summary\',obs,'summary.mat'],'wl','SPDav','xyY')

end


