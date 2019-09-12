% Computing the melanopic contrast between conditions for each observer

clear, clc, close all

% Load data
r = OOLED;

%% General contrast

DG_MP = r(1).MP/r(4).MP*100;
LW_MP = mean([r(6).MP,r(8).MP]) / mean([r(7).MP,r(3).MP])*100;
HC_MP = mean([r(2).MP,r(10).MP]) / mean([r(9).MP,r(5).MP])*100;

%% Weber contrast

DG_MPw = (r(1).MP - r(4).MP)/r(4).MP*100;
LW_MPw = (mean([r(6).MP,r(8).MP]) - mean([r(7).MP,r(3).MP]))/ mean([r(7).MP,r(3).MP])*100;
HC_MPw = (mean([r(2).MP,r(10).MP]) - mean([r(9).MP,r(5).MP]))/ mean([r(9).MP,r(5).MP])*100;

