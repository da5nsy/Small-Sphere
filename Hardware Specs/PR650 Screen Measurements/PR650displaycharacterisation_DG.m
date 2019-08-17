%% ------------------------------------------------------------------
%
%  Measure display with PR-650 for colour characterisation
%
% -------------------------------------------------------------------
pause(30) %scarper time
DEBUG = 1;                     % set = 0 to suppress messages
pause on;                      % enable pausing

% Initialise PR-650 spectroradiometer

cgloadlib;
cgphotometer('open','PR650',1);

N = 101;                       % length of spectral data vector
lambda = zeros(N,1,'uint16');  % sampling wavelengths
spc = zeros(N,1,'double');     % vector returned by instrument

% Measurement arrays

sval = [0:5:25 31:16:255];      % signal values for each channel
scnt = length(sval);            % number of measurements per channel
RGBW_XYZ = zeros(3,4);
RGBW_spectrum = zeros(N,4,'double');
XYZ = zeros(3,scnt,4,'double');  % XYZ values, order R,G,B,W
Measurement = zeros(N,scnt,4,'double');  % spectra, order R,G,B,W

%% Set up measurement panel on display

%px = 800;  py = 400;  pw = 1000;  ph = 400;  % window location and dimensions
%px = 1295;  py = 409;  pw = 1000;  ph = 400;  % window location and dimensions
px = 1705;  py = 330;  pw = 1000;  ph = 400;
%px = 1850;  py = 330;  pw = 1000;  ph = 400;
ph2 = floor(ph/2);  s = 8;
pw2 = floor(pw/2);  w = 200;
ax1 = pw2-w;  ax2 = pw2+w;              % active area
fh = figure('Visible','on','Position',[px,py,pw,ph]);  % create figure
set(fh,'Color','k','MenuBar','none');   % set figure background to black
vbuf = zeros(ph,pw,3,'uint8');          % image buffer
dbuf = zeros(ph,ph,3,'uint8');          % display template
tbuf = zeros(ph,ph,3,'uint8');          % circular template

rad = 47;%100;                              % radius of circular target
for i = 1:pw
  for j = 1:ph
    r = sqrt((ph2-i)^2+(ph2-j)^2);      % distance from centre
    if (r<=rad) tbuf(j,i,:) = 1; end    % 1 inside circle
  end
end
Tcircle = (tbuf==1);                    % logical 'true' inside circle

dbuf(Tcircle) = 255;                    % set white in central field
dbuf(ph2-s:ph2+s,ph2-s:ph2+s,:) = 0;    % small black square at centre
vbuf(:,ax1:ax2-1,:) = dbuf;             % fill only circle
image(vbuf);                            % display target for setup

%% Measure RGBW primaries

sbuf = zeros(ph,ph,3,'uint8');
rgbtab = [1 0 0; 0 1 0; 0 0 1; 1 1 1]';
ctab = {'Red','Green','Blue','White'};
pause(3);

for i = 1:4
  sbuf(:,:,1) = uint8(255*rgbtab(1,i));  % fill target with colour
  sbuf(:,:,2) = uint8(255*rgbtab(2,i));
  sbuf(:,:,3) = uint8(255*rgbtab(3,i));
  dbuf(Tcircle)=sbuf(Tcircle);
  vbuf(:,ax1:ax2-1,:) = dbuf;           
  set(0,'CurrentFigure',fh);            % set display window as current
  image(vbuf);                          % display target for setup
  pause(0.1);                           % wait for display to settle
  xyz = cgphotometer('XYZ');            % Take the measurement
  RGBW_XYZ(:,i) = xyz;
  spc = cgphotometer('SPC');            % Download the spectrum
  RGBW_spectrum(:,i) = spc(:,2);        % save in array
  figure;  hold on;
  spcplot(spc,3);                       % Plot the spectrum graphically
  title(sprintf('%s display primary',ctab{i}));
end

lambda = spc(:,1);                      % save wavelength scale

%% Plot spectra of primaries

Red = RGBW_XYZ(:,1);             % extract red XYZ
Green = RGBW_XYZ(:,2);           % extract green XYZ
Blue = RGBW_XYZ(:,3);            % extract blue XYZ
White = RGBW_XYZ(:,4);           % extract white XYZ
fprintf('Display red   XYZ = %5.2f,%5.2f,%5.2f\n',Red);
fprintf('Display green XYZ = %5.2f,%5.2f,%5.2f\n',Green);
fprintf('Display blue  XYZ = %5.2f,%5.2f,%5.2f\n',Blue);
fprintf('Display white XYZ = %5.2f,%5.2f,%5.2f\n',White);
fprintf('Reference white XYZ = %5.2f,%5.2f,%5.2f\n',100*White/White(2));

figure;  hold on;
title('Spectra of display primaries');
plot(lambda,RGBW_spectrum(:,1),'-r');
plot(lambda,RGBW_spectrum(:,2),'-g');
plot(lambda,RGBW_spectrum(:,3),'-b');
plot(lambda,RGBW_spectrum(:,4),'-k');
xlabel('Wavelength (nm)');
ylabel('Radiant power');

%% Measure red series spectra

pause(10);
vbuf(:,:,:) = 0;
sbuf(:,:,:) = 0;
dbuf(:,:,:) = 0;
 for i = 1:scnt
  sbuf(:,:,1) = uint8(sval(i));         % only red
  dbuf(Tcircle)=sbuf(Tcircle);
  vbuf(:,ax1:ax2-1,:) = dbuf;  
  set(0,'CurrentFigure',fh);            % set display window as current
  image(vbuf);                          % display target for setup
  pause(0.1);                           % wait for display to settle
  xyz = cgphotometer('XYZ');            % take the measurement
  XYZ(:,i,1) = xyz;                     % save results
  spc = cgphotometer('SPC');            % get spectrum
  Measurement(:,i,1) = spc(:,2);        % copy SPD to array
  clear spc;
end
fprintf('Completed red series measurements\n');

% Measure green series spectra

pause(10);
sbuf(:,:,:) = 0;
for i = 1:scnt
  sbuf(:,:,2) = uint8(sval(i));         % only green
  dbuf(Tcircle)=sbuf(Tcircle);
  vbuf(:,ax1:ax2-1,:) = dbuf;
  set(0,'CurrentFigure',fh);            % set display window as current
  image(vbuf);                          % display target for setup
  pause(0.1);                           % wait for display to settle
  xyz = cgphotometer('XYZ');            % take the measurement
  XYZ(:,i,2) = xyz;                     % save results
  spc = cgphotometer('SPC');            % take the measurement
  Measurement(:,i,2) = spc(:,2);        % copy SPD to array
  clear spc;
end
fprintf('Completed green series measurements\n');

% Measure blue series spectra

pause(10);
sbuf(:,:,:) = 0;
for i = 1:scnt
  sbuf(:,:,3) = uint8(sval(i));         % only blue
  dbuf(Tcircle)=sbuf(Tcircle);
  vbuf(:,ax1:ax2-1,:) = dbuf;
  set(0,'CurrentFigure',fh);            % set display window as current
  image(vbuf);                          % display target for setup
  pause(0.1);                           % wait for display to settle
  xyz = cgphotometer('XYZ');            % take the measurement
  XYZ(:,i,3) = xyz;                     % save results
  spc = cgphotometer('SPC');            % take the measurement
  Measurement(:,i,3) = spc(:,2);        % copy SPD to array
  clear spc;
end
fprintf('Completed blue series measurements\n');

% Measure white series spectra

pause(10);
for i = 1:scnt
  sbuf(:,:,1) = uint8(sval(i)); 
  sbuf(:,:,2) = uint8(sval(i)); 
  sbuf(:,:,3) = uint8(sval(i));         % all channels equal
  dbuf(Tcircle)=sbuf(Tcircle);
  vbuf(:,ax1:ax2-1,:) = dbuf;
  set(0,'CurrentFigure',fh);            % set display window as current
  image(vbuf);                          % display target for setup
  pause(0.1);                           % wait for display to settle
  xyz = cgphotometer('XYZ');            % take the measurement
  XYZ(:,i,4) = xyz;                     % save results
  spc = cgphotometer('SPC');            % take the measurement
  Measurement(:,i,4) = spc(:,2);        % copy SPD to array
  clear spc;
end
fprintf('Completed white series measurements\n');

%% Plot results

% Linear luminance

figure;  hold on;
title('Display luminance');
v = squeeze(XYZ(2,:,:));       % extract luminance values
plot(sval,v(:,1),'-r');
plot(sval,v(:,2),'-g');
plot(sval,v(:,3),'-b');
plot(sval,v(:,4),'-k');
xlabel('Input signal (8-bit)');
ylabel('Screen luminance');

% Log-linear

figure;  hold on;
title('Display luminance');
v = squeeze(XYZ(2,:,:));       % extract luminance values
plot(sval,log10(v(:,1)),'-r');
plot(sval,log10(v(:,2)),'-g');
plot(sval,log10(v(:,3)),'-b');
plot(sval,log10(v(:,4)),'-k');
xlabel('Input signal (8-bit)');
ylabel('Log screen luminance');

% Log luminance

figure;  hold on;
title('Display luminance');
v = squeeze(XYZ(2,:,:));          % extract luminance values
sv = log10(sval/255);
plot(sv,log10(v(:,1)/v(scnt,1)),'-r');
plot(sv,log10(v(:,2)/v(scnt,2)),'-g');
plot(sv,log10(v(:,3)/v(scnt,3)),'-b');
plot(sv,log10(v(:,4)/v(scnt,4)),'-k');
plot([-2 0],[-2 0],':k');
xlabel('Log input signal (8-bit)');
ylabel('Log relative screen luminance');

%% Make lookup tables for tone curve

RGBlut = zeros(3,256,'uint8');

for k = 1:3
  RGBlut(k,:) = interp1(sval,XYZ(2,:,k),0:255,'spline');
end

%% Save data file and close PR-650

%fname = 'LCD display measurement.mat';
%fname = 'Large LCD display measurement.mat';
fname = 'Large LCD display measurement - LW_AU.mat';

save(fname,'RGBW_XYZ','RGBW_spectrum','sval','lambda','XYZ','Measurement');
cgphotometer('shut');
