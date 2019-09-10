function SmallSphereCalibrationCheck(obs,d)
%% Check calibration of small sphere APS (achromatic point setting) data
% 
% I have recorded values from the PR650, and from within matlab.
% 
% From the PR650 I have spectra and XYZ.
% From matlab, I have RGB values, which I can convert, using the general calibration file into tristimulus values.

% Notes: 
% Only 3 out of gamut points

% Plan:
% Load fake APS data
% Calibrate APS data, using same method as for real data
% Load PR650 measurements
% Convert to tristimulus values
% Compare the above

clc, clear, close all
obs = 'Characterization without LEDs'; 

rootdir = fullfile('C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data\Run 2 data\PR650',obs);

N  = 3;                             % number of repetitions over time
LN = 5;                             % number of lightness levels per repeat

%% Load and calibrtae "observer" data, exactly as done in Small_sphere_analysis

cd(rootdir)
files = dir('2017*.mat'); % This picks out the correct file, and ignore many others
files = rmfield(files,{'bytes','isdir','datenum'}); %remove unused fields
for j = 1:length(files)
    load(fullfile(rootdir,files(j).name));  % load experimental results
    files(j).dataLAB  = LABmatch;
    files(j).dataRGB  = RGBmatch;
    files(j).RGBstart = RGBstart;
    files(j).Tmatch   = Tmatch;
end
clear LABmatch RGBmatch RGBstart Tmatch j

%Calibrate data
for trial=1%:length(files) %only ever 1, but copying over from the actual analysis
    
    %load calibration file
    calFileLocation=fullfile(rootdir,'Large LCD display measurement.mat');
    load(calFileLocation,'sval','XYZ')
    
    %interpolate recorded values (sval) to required vals (0:1:255)
    XYZinterp = zeros(3,256,4);
    for i = 1:3
        for j = 1:4
            XYZinterp(i,:,j) = interp1(sval, XYZ(i,:,j), 0:255, 'spline');
        end
    end
    
    % Calcaulate XYZ for white point of display
    %   This method gives slightly different results to the previous method
    %   (where cie1931 was loaded, and fresh tristimulus were calculated from
    %   the recorded spectra, but this method is much neater and in-ilne with
    %   the use of the PR650 XYZ values elsewhere).
    
    files(trial).screenXYZ  = XYZ;
    for i = 1:21
        for j = 1:4
            files(trial).screenxyY(:,i,j)  = XYZToxyY(squeeze(XYZ(:,i,j)));
        end
    end
    
    files(trial).screenXYZw = XYZ(:,end,4)/XYZ(2,end,4)*100;
    files(trial).screenxyw  = files(trial).screenxyY(:,end,end);
    
    
    % Thresholding:
    %   Original RGB values included out of gamut (sRGB)
    %   selections, resulting in above 1 and below 0 values. These would
    %   actually have only presented values at 0/1 and so here they are
    %   corrected to represent what would actually have been presented
    
    files(trial).dataRGBgamflag = files(trial).dataRGB > 1 | files(trial).dataRGB < 0; %out of gamut flag
    
    files(trial).dataRGBgamcor  = files(trial).dataRGB; %duplicate
    files(trial).dataRGBgamcor(files(trial).dataRGB < 0) = 0;
    files(trial).dataRGBgamcor(files(trial).dataRGB > 1) = 1;
    
    % Quantization
    files(trial).dataRGBgamcor = uint8(files(trial).dataRGBgamcor*255);
    
    files(trial).dataXYZcal    = zeros(3,LN,N);
    files(trial).dataxycal     = zeros(2,LN,N);
    files(trial).dataLABcal    = zeros(3,LN,N);
    
    for j = 1:LN
        for k = 1:N
            files(trial).dataXYZcal(:,j,k) = ...
                (XYZinterp(:,files(trial).dataRGBgamcor(1,j,k)+1,1)...
                +XYZinterp(:,files(trial).dataRGBgamcor(2,j,k)+1,2)...
                +XYZinterp(:,files(trial).dataRGBgamcor(3,j,k)+1,3));
            
            files(trial).dataxycal(1,j,k) = ...
                files(trial).dataXYZcal(1,j,k)/sum(files(trial).dataXYZcal(:,j,k));
            files(trial).dataxycal(2,j,k) = ...
                files(trial).dataXYZcal(2,j,k)/sum(files(trial).dataXYZcal(:,j,k));
            files(trial).dataxycal(3,j,k) = files(trial).dataXYZcal(2,j,k);
            
            files(trial).dataLABcal(:,j,k) = ...
                XYZToLab(files(trial).dataXYZcal(:,j,k),files(trial).screenXYZw);
        end
    end
end

%% Load PR650 data, and calculate tristimulus values

load T_xyz1931.mat T_xyz1931 S_xyz1931
S_PR650 = MakeItS([380:4:780]');
T_xyz1931 = SplineCmf(S_xyz1931, T_xyz1931,S_PR650);
S_xyz1931 = S_PR650;

PR650 = dir('Spectrum*.mat');
PR650 = rmfield(PR650,{'bytes','isdir','datenum'}); %remove unused fields
for i=1:length(PR650)
    load(PR650(i).name,'PRspc');
    PR650(i).dataSPC = PRspc(:,2);
    PR650(i).dataXYZ = T_xyz1931*PRspc(:,2);
    PR650(i).dataxy  = XYZToxyY(PR650(i).dataXYZ);
end

%% Compare

figure, hold on
drawChromaticity

files_xyr  = reshape(files.dataxycal,3,15);
scatter3(files_xyr(1,1:14),files_xyr(2,1:14),files_xyr(3,1:14),'r*','DisplayName','Internally saved')

PR650_xyr  = [PR650.dataxy];
scatter3(PR650_xyr(1,2:15),PR650_xyr(2,2:15),PR650_xyr(3,2:15),'b*','DisplayName','PR650 measurements')
%     for i=2:15
%         scatter3(PR650(i).dataxy(1),PR650(i).dataxy(2),PR650(i).dataXYZ(2),'b*','DisplayName','PR650')
%     end

%daspect([1 1 10])
%title(obs);
legend


end
