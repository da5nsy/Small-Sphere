%% Read Ocean Optics data
clear

% Set Input Folder
rootdir = fullfile('C:','OO');
% Set current directory to root folder
cd(rootdir)

try
    load('spectra123454346.mat');
catch
    txtfls=dir('*.txt');                    %Creates struct of all .txt files
    N = 2048;
    LEDrad = zeros(N,2,length(txtfls),'double');
    
    % Read from text files    
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
    save('spectra123454346.mat')
end

%% Plot
figure, hold on
for i=1:length(txtfls)
    plot(LEDrad(:,1,i),LEDrad(:,2,i))
    pause(1)
    drawnow
end

%% Sort

t= squeeze(mean(LEDrad));
figure,
plot(t(2,:))

grid('on')

%% Plot Flash Data
figure, hold on
for i = [15,17,18,20,21,22,24,25,27,28]
    plot(LEDrad(:,1,i),LEDrad(:,2,i))
end

%% DFC

figure, hold on
DFCt=LEDrad(:,:,[16,19,23,26,29]);

for i = 1:5
    plot(DFCt(:,1,i),DFCt(:,2,i))
end

DFC=mean(DFCt,3);

plot(DFC(:,1),DFC(:,2),'k')

%% Apply DFC
LEDradDFC=LEDrad;

for i=1:length(txtfls)
    LEDradDFC(:,2,i)=LEDradDFC(:,2,i)-DFC(:,2);
end

figure, hold on
for i = 15%[15,17,18,20,21,22,24,25,27,28]
    plot(LEDrad(:,1,i),LEDrad(:,2,i),'r')
end

for i = 15%[15,17,18,20,21,22,24,25,27,28]
    plot(LEDradDFC(:,1,i),LEDradDFC(:,2,i),'k')
end