clear, clc, close all

d = dir('C:\Users\cege-user\Dropbox\Documents\MATLAB\SmallSphere\Data\Run 2 data\Ocean Optics\201*');
names = {d.name}';

%%
for i=1:6
    disp(names{i})
    OO_smallSphere_002(names{i})
end
