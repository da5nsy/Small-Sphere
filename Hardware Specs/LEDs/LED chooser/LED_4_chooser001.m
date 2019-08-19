function output = LED_4_chooser(LEDs)
%To use as function, comment out below definition of 'LEDs'
%Note. Where chromaticities are referred to here, they are in the 1964
%chromaticity space, not the 1931 chromaticity space.

LEDs=   [470,400,625];
spread= 20;          %20 for realistic values, 
                     %1 for (roughly) monochromatic light sources
range = [490,600];   %Range over which a contender for LED_4 will be sought

% From CIE website: 'selected colorimetric tables' ('204')
%disp('Select CIE data location')

%cie_data_file=uigetfile('C:\Users\cege-user\Dropbox\UCL\Data\Colour standards\CIE colorimetric data\CIE_colorimetric_tables.xls');
cie_data_file=('C:\Users\cege-user\Dropbox\UCL\Data\Colour standards\CIE colorimetric data\CIE_colorimetric_tables.xls');
CIE1964=xlsread(cie_data_file,'1964 col observer','A6:D86');
ciewavelength=  CIE1964(:,1);
x_bar10=        CIE1964(:,2);
y_bar10=        CIE1964(:,3);
z_bar10=        CIE1964(:,4);

%Generate xy data for chromaticity diagram
x=x_bar10./(x_bar10+y_bar10+z_bar10);
y=y_bar10./(x_bar10+y_bar10+z_bar10);

% From: Royer, M.P., 2011. Tuning optical radiation for visual... 
% and nonvisual impact (Ph.D.). The Pennsylvania State University,... 
% United States -- Pennsylvania.
% (Original source unclear)

%disp('Select melanopsin data location')
%mel_data_file=uigetfile('C:\Users\cege-user\Dropbox\Documents\MATLAB\melanopsin.mat');
mel_data_file=('C:\Users\cege-user\Dropbox\Documents\MATLAB\melanopsin.mat');
load(mel_data_file); mel_bar=i_bar; clear i_bar
melwavelength=  mel_bar(:,1);
mel_bar=        mel_bar(:,2);

%% Generate hypothetical LEDs and further attributes

LED_1 = gaussmf(melwavelength,[spread LEDs(1)]);
LED_2 = gaussmf(melwavelength,[spread LEDs(2)]);
LED_3 = gaussmf(melwavelength,[spread LEDs(3)]);

%Generate as above, but over 81 values, to fit CIE data.
%Should probably interpolate either CIE data or melanopsin data for later
%simplification but this works for now
LED_1_81 = gaussmf(ciewavelength,[spread LEDs(1)]);
LED_2_81 = gaussmf(ciewavelength,[spread LEDs(2)]);
LED_3_81 = gaussmf(ciewavelength,[spread LEDs(3)]);

%Calculate XYZ for LEDs
LED_1_XYZ=[x_bar10'*LED_1_81,y_bar10'*LED_1_81,z_bar10'*LED_1_81];
LED_2_XYZ=[x_bar10'*LED_2_81,y_bar10'*LED_2_81,z_bar10'*LED_2_81];
LED_3_XYZ=[x_bar10'*LED_3_81,y_bar10'*LED_3_81,z_bar10'*LED_3_81];

%Calculate xy for LEDs
LED_1_xy=[LED_1_XYZ(1)/sum(LED_1_XYZ),LED_1_XYZ(2)/sum(LED_1_XYZ)];
LED_2_xy=[LED_2_XYZ(1)/sum(LED_2_XYZ),LED_2_XYZ(2)/sum(LED_2_XYZ)];
LED_3_xy=[LED_3_XYZ(1)/sum(LED_3_XYZ),LED_3_XYZ(2)/sum(LED_3_XYZ)];

%Calculate melanopsin contributions from predefined LEDs
LED_1_mel=mel_bar'*LED_1;
LED_2_mel=mel_bar'*LED_2;
LED_3_mel=mel_bar'*LED_3;

figure, hold on
plot(x,y,'k');
scatter(LED_1_xy(1),LED_1_xy(2),'k*');
scatter(LED_2_xy(1),LED_2_xy(2),'k*');
scatter(LED_3_xy(1),LED_3_xy(2),'k*');
title('CIE1964 chromaticity diagram')
xlabel('x')
ylabel('y')
text(LED_1_xy(1)-0.07,LED_1_xy(2),num2str(LEDs(1)));
text(LED_2_xy(1)-0.07,LED_2_xy(2),num2str(LEDs(2)));
text(LED_3_xy(1)+0.02,LED_3_xy(2),num2str(LEDs(3)));

axis square

%% Calculate results of using different LEDs as LED_4,
%plot on previously generated chroaticity diagram
%gather melanopsin contribution info

plot(   [LED_1_xy(1),LED_3_xy(1)],...
        [LED_1_xy(2),LED_3_xy(2)],'k');

melratio=zeros(2,range(2));
    
for i=range(1):5:range(2)
    
    % Define LED_4, and its mel contributions at different wavelengths
    LED_4 =     gaussmf(melwavelength,[spread i]);
    LED_4_81 =  gaussmf(ciewavelength,[spread i]);
    LED_4_mel(i)=mel_bar'*LED_4;
    
    LED_4_XYZ=  [x_bar10'*LED_4_81,y_bar10'*LED_4_81,z_bar10'*LED_4_81];
    LED_4_xy=   [LED_4_XYZ(1)/sum(LED_4_XYZ),LED_4_XYZ(2)/sum(LED_4_XYZ)];
    
    scatter(LED_4_xy(1),LED_4_xy(2),'b*');
    if mod(i,10)==0
        text((LED_4_xy(1)*1.2)-0.1,LED_4_xy(2)*1.1,num2str(i),'Color','b');
    end
    
    plot(   [LED_2_xy(1),LED_4_xy(1)],...
            [LED_2_xy(2),LED_4_xy(2)],'b');

    L1=LED_1_xy; %Not requisite in loop
    L2=LED_2_xy; %Not requisite in loop
    L3=LED_3_xy; %Not requisite in loop
    L4=LED_4_xy;

    %calculuating side lengths from locations
    L1L2= sqrt(((L1(1)-L2(1))^2)+((L1(2)-L2(2))^2)); %Not requisite in loop
    L1L3= sqrt(((L1(1)-L3(1))^2)+((L1(2)-L3(2))^2)); %Not requisite in loop
    L2L3= sqrt(((L2(1)-L3(1))^2)+((L2(2)-L3(2))^2)); %Not requisite in loop
    L2L4= sqrt(((L2(1)-L4(1))^2)+((L2(2)-L4(2))^2)); 
    L1L4= sqrt(((L4(1)-L1(1))^2)+((L4(2)-L1(2))^2)); 
    
    % Using cosine rule to calculate angle L1L2L4
    AL1L2L4 = acosd((L1L2^2 + L2L4^2 -L1L4^2)/(2*L1L2*L2L4));
    AL2L1L3 = acosd((L1L2^2 + L1L3^2 -L2L3^2)/(2*L1L2*L1L3));
    AL1xL2=180-AL1L2L4-AL2L1L3;

    % Using sine rule to calculate X
    L1x(i)=sind(AL1L2L4)*(L1L2/(sind(AL1xL2)));
    L2x(i)=sind(AL2L1L3)*(L1L2/(sind(AL1xL2)));
    
    %Calculating mel ratios
    melratio(1,i)= LED_1_mel*(1-(L1x(i)/L1L3))...
        + LED_3_mel*(L1x(i)/L1L3); %L1+L3 
    melratio(2,i)= LED_2_mel*(1-(L2x(i)/L2L4))...
        + LED_4_mel(i)*(L2x(i)/L2L4); %L2+L4

end

axis square

% figure, plot(L1x(range(1):5:range(2)))
% figure, plot(L2x(range(1):5:range(2)))

%% Subplot results data

figure,

% melratio(1,:)
subplot(2,2,1),
plot(range(1):5:range(2),...
    melratio(1,range(1):5:range(2)))
title('Mel L1+L3')
xlabel('LED\_4 wavelength (nm)')
ylabel('Arbitrary units')
axis([range(1),range(2),0,25])

subplot(2,2,2),
plot(range(1):5:range(2),...
    melratio(2,range(1):5:range(2)))
title('Mel L2+L4')
xlabel('LED\_4 wavelength (nm)')
ylabel('Arbitrary units')
axis([range(1),range(2),0,25])

subplot(2,2,3),
plot(range(1):5:range(2),...
    LED_4_mel(range(1):5:range(2)))
title('Mel L4')
xlabel('LED\_4 wavelength (nm)')
ylabel('Arbitrary units')
axis([range(1),range(2),0,25])

subplot(2,2,4),
plot(range(1):5:range(2),...
    melratio(1,range(1):5:range(2))...
    ./melratio(2,range(1):5:range(2)))
title('Mel L1+L3 / L2+L4')
xlabel('LED\_4 wavelength (nm)')
ylabel('Arbitrary units')
axis([range(1),range(2),1,10])

%%
output = max(melratio(1,range(1):5:range(2))...
    ./melratio(2,range(1):5:range(2)));