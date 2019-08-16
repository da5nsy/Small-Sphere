function output = LED_4_chooser(input)

%clear all; clc

%LEDs=[480,390,670];
LEDs=input;

% From CIE website: 'selected colorimetric tables' ('204')
CIE1964=xlsread('C:\Users\ucesars\Dropbox\Documents\MATLAB\Selected Colorimetric Tables.xls',...
    '1964 col observer','A6:D86');
CIEwv=  CIE1964(:,1);
x_bar10=        CIE1964(:,2);
y_bar10=        CIE1964(:,3);
z_bar10=        CIE1964(:,4);

% From: Royer, M.P., 2011. Tuning optical radiation for visual and nonvisual impact (Ph.D.). The Pennsylvania State University, United States -- Pennsylvania.
% Original source unclear
load('C:\Users\ucesars\Dropbox\Documents\MATLAB\melanopsin.mat')
mel_bar=i_bar; clear i_bar
melwavelength=  mel_bar(:,1);
mel_bar=        mel_bar(:,2);

%plot(CIEwavelength,x_bar10,CIEwavelength,y_bar10,CIEwavelength,z_bar10)

% Hypothetical LEDs (gaussians with sigma of 20)
% LED_1 = gaussmf(CIEwv,[20 LEDs(1)]);
% LED_2 = gaussmf(CIEwv,[20 LEDs(2)]);
% LED_3 = gaussmf(CIEwv,[20 LEDs(3)]);
%LED_4 = gaussmf(CIEwavelength,[20 ?]);

%plot(CIEwavelength,LED_1,CIEwavelength,LED_2,CIEwavelength,LED_3)

%% Calculate potential melanopsin input of LED_4

range =[490,600];

for i=range(1):5:range(2) %candidates for LED_4 in nm

end

LED_1 = gaussmf(melwavelength,[20 LEDs(1)]);
LED_2 = gaussmf(melwavelength,[20 LEDs(2)]);
LED_3 = gaussmf(melwavelength,[20 LEDs(3)]);
LED_1_mel=mel_bar'*LED_1;
LED_2_mel=mel_bar'*LED_2;
LED_3_mel=mel_bar'*LED_3;


%%
x=x_bar10./(x_bar10+y_bar10+z_bar10);
y=y_bar10./(x_bar10+y_bar10+z_bar10);

figure,plot(x,y,'k')
hold on
scatter(x(CIEwv==LEDs(1)),y(CIEwv==LEDs(1)),'k*');
scatter(x(CIEwv==LEDs(2)),y(CIEwv==LEDs(2)),'k*');
scatter(x(CIEwv==LEDs(3)),y(CIEwv==LEDs(3)),'k*');

plot(   [x(CIEwv==LEDs(1)),x(CIEwv==LEDs(3))],...
        [y(CIEwv==LEDs(1)),y(CIEwv==LEDs(3))],'k');

melratio=zeros(2,range(2));
    
for i=range(1):5:range(2)
    scatter(x(CIEwv==i),y(CIEwv==i),'b*')
    plot(   [x(CIEwv==LEDs(2)),x(CIEwv==i)],...
            [y(CIEwv==LEDs(2)),y(CIEwv==i)],'b');

    L1=[x(CIEwv==LEDs(1)),y(CIEwv==LEDs(1))]; %Not requisite in loop
    L2=[x(CIEwv==LEDs(2)),y(CIEwv==LEDs(2))]; %Not requisite in loop
    L3=[x(CIEwv==LEDs(3)),y(CIEwv==LEDs(3))]; %Not requisite in loop
    L4=[x(CIEwv==i),y(CIEwv==i)];

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
    
    % LED_4 mel contributions at different wavelengths
    LED_4 = gaussmf(melwavelength,[20 i]);
    LED_4_mel(i)=mel_bar'*LED_4;
    
    %Calculating mel ratios
    melratio(1,i)= LED_1_mel*(1-(L1x(i)/L1L3))...
        + LED_3_mel*(L1x(i)/L1L3); %L1+L3 
    melratio(2,i)= LED_2_mel*(1-(L2x(i)/L2L4))...
        + LED_4_mel(i)*(L2x(i)/L2L4); %L2+L4

end

axis square

% figure, plot(L1x(range(1):5:range(2)))
% figure, plot(L2x(range(1):5:range(2)))

%%
figure,

% melratio(1,:)
subplot(2,2,1),
plot(range(1):5:range(2),...
    melratio(1,range(1):5:range(2)))
title('Mel L1+L3')
xlabel('LED\_4 wavelength (nm)')
axis([range(1),range(2),0,25])

subplot(2,2,2),
plot(range(1):5:range(2),...
    melratio(2,range(1):5:range(2)))
title('Mel L2+L4')
xlabel('LED\_4 wavelength (nm)')
axis([range(1),range(2),0,25])

subplot(2,2,3),
plot(range(1):5:range(2),...
    LED_4_mel(range(1):5:range(2)))
title('Mel L4')
xlabel('LED\_4 wavelength (nm)')
axis([range(1),range(2),0,25])

subplot(2,2,4),
plot(range(1):5:range(2),...
    melratio(1,range(1):5:range(2))...
    ./melratio(2,range(1):5:range(2)))
title('Mel L1+L3 / L2+L4')
xlabel('LED\_4 wavelength (nm)')

%%
output = max(melratio(1,range(1):5:range(2))...
    ./melratio(2,range(1):5:range(2)));