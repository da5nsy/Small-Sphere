function SPDmean=OO_smallSphere_002(obs)
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
%obs='20170720 LW_AU';
%uncomment the above when using as a script rather than a function

% Set Input Folder
rootdir = fullfile('C:','Users','ucesars','Dropbox','UCL','Data',...
    'Small Sphere','Run 2 Data','Ocean Optics',obs);
cd(rootdir)

try
    load(sprintf('%s.mat',obs));
catch
    
    % Import Data
    txtfls=dir('*.txt');                    %Creates struct of all .txt files
    N = 2048;
    LEDrad = zeros(N,2,length(txtfls),'double');
    
    %
    
    for k = 1:length(txtfls)
        fid = fopen(txtfls(k).name,'r');
        for i = 1:13
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

load(fullfile('C:','Users','ucesars','Dropbox','UCL','Ongoing Work',...
    'Small Sphere','correction vector.mat'));

% %% Plot time course of recording, to select dfc and measurement goalposts
% %Would be nice to plot against time, but this seems tricky
% 
% %figure,
% plot(sum(squeeze(LEDrad(:,2,:))));
%% Plot spectra

%The measurements were taken before and after the experiments
%Here start and end points are set for each run, and times when a dark
%correction was recorded are noted.
if  strcmp(obs,'20170720 LW_AU')
    startP=80;    endP=770; 
    dfc=mean(LEDrad(:,2,20:70),3); 
elseif  strcmp(obs,'20170720 HC_RB')
    startP=830;    endP=1790;
    dfc=mean(LEDrad(:,2,20:70),3); 
elseif  strcmp(obs,'20170720 DG_RB')
    startP=50;    endP=645;  
    dfc=mean(LEDrad(:,2,20:24),3);
elseif  strcmp(obs,'20170721 LW_RB')
    startP=215;    endP=595; 
    dfc=mean(LEDrad(:,2,1:15),3);
elseif      strcmp(obs,'20170721 HC_AU')
    startP=10;    endP=515;
    dfc=mean(LEDrad(:,2,1:3),3);
elseif      strcmp(obs,'20170721 DG_AU')
    startP=40;    endP=650;
    dfc=mean(LEDrad(:,2,2:10),3);
else error('Unknown start/end points')
end

wavelength = LEDrad(:,1,1);

% The following plots the spectra of the first reading, and then
% successively plots the rest of the data (in between startP and endP) to
% allow for comparison over time.

% figure('units','normalized','outerposition',[0 0 1 1]);  hold on;
% grid on
% grid minor
% for k = startP:endP%1:length(txtfls)
%     pause(0.01)
%     cla
%     m = max(LEDrad(:,2,k));
%     
%     %Plot calibrated data (it gets noisy in the extremes)
%     plot(wavelength(107:1231),(LEDrad(107:1231,2,startP)-dfc(107:1231)).*correction_vector(107:1231),'b');
%     plot(wavelength(107:1231),(LEDrad(107:1231,2,k)-dfc(107:1231)).*correction_vector(107:1231),'k');
%     
%     %Plot uncalibrated data
% %     plot(wavelength,LEDrad(:,2,startP)-dfc,'b');
% %     plot(wavelength,LEDrad(:,2,k)-dfc,'k');
%     t=title(txtfls(k).name);
%     
%     xlabel('Wavelength (nm)');
%     ylabel('Ocean Optics DFC Data');
%     %axis([380,780,0,1]);
%     set(t,'Interpreter','none'); %needs named figure -'t'
% end
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
%Loads CIE data if not already stored as variables
%if exist('xbar','var')~=1;[cielambda,xbar,ybar,zbar]=loadCIE(1931);end
%Creates initial plot
%plotCIE(2,xbar,ybar,zbar);

%Interpolates CIEdata to fit OO wavelength intervals
% xbar_int=interp1(cielambda,xbar,wavelength(107:1231),'spline'); %380:780
% ybar_int=interp1(cielambda,ybar,wavelength(107:1231),'spline'); 
% zbar_int=interp1(cielambda,zbar,wavelength(107:1231),'spline'); 

%Calculates XYZ and xy for all points
for i = startP:endP
    
    SPD(:,i) =(LEDrad(107:1231,2,i)-dfc(107:1231)).*correction_vector(107:1231);
    
%     XYZ(:,i) =[((LEDrad(107:1231,2,i)-dfc(107:1231)).*correction_vector(107:1231))'*xbar_int;
%         ((LEDrad(107:1231,2,i)-dfc(107:1231)).*correction_vector(107:1231))'*ybar_int;
%         ((LEDrad(107:1231,2,i)-dfc(107:1231)).*correction_vector(107:1231))'*zbar_int;];
%     
%     xy(:,i)=[XYZ(1,i)/sum(XYZ(:,i));XYZ(2,i)/sum(XYZ(:,i))];
%     scatter(xy(1,i),xy(2,i),'k.');
end

%%
% figure, hold on
% for i=startP:endP
%     plot(SPD(:,i),'k')
% end
% figure
SPDmean=mean(SPD(:,startP:endP),2);

end


