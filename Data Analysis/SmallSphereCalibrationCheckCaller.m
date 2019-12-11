clear, clc, close all

rootdir = 'C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data\Run 2 data\PR650';
cd(rootdir)
d = dir('2017*');
%%

for ob = 1:length(d)
    SmallSphereCalibrationCheck(d(ob).name)
end


%%

SmallSphereCalibrationCheck('Characterization without LEDs')
