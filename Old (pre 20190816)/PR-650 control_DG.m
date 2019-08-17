%  Control script for the PhotoResearch PR-650 spectroradiometer

rootdir = fullfile('C:','Test','PR-650','DG_Test_BasementWhiteSprayPaints');
cd(rootdir)

cgloadlib
cgphotometer('open','PR650',1)

lambda = zeros(101,1,'uint16');
spd = zeros(101,100,'double');
n = 0;

while 1

    a = upper(input('''M'' to take a measurement, ''X'' to exit: ','s'));
    
    switch a
        case 'X'
            break
        case 'M'
            n = n+1;
            XYZ = cgphotometer('XYZ');  % Take the measurement
            spc = cgphotometer('SPC');  % Download the spectrum
            spcplot(spc,3);             % Plot the spectrum graphically
            lambda(:) = spc(:,1);       % Save wavelength scale
            spd(:,n) = spc(:,2);        % Copy SPD to array
            %clear spc;
            %
            % Display big XYZ
            %
            disp(sprintf('XYZ: %.4f %.4f %.4f',XYZ))
            %
            % Display xyY
            %
            %xyz2 = XYZ/sum(XYZ);
            %
            %disp(sprintf('xyY: %.4f %.4f %.4f cd/m2',xyz2(1),xyz2(2),XYZ(2)))
            %
            % Calculate and display the integrated radiance
            %
            %disp(sprintf('Integrated radiance:%.4f mW/sr/m2',4000*sum(spc(:,2))))
            % Save data in file

            fname = fullfile(rootdir,sprintf('Spectrum%03d.txt',n));
            fid = fopen(fname','w');
            for k = 1:101
              fprintf(fid,'%d %f\n',uint16(lambda(k)),spd(k,n));
            end
            fclose(fid);
            
            fname2 = fullfile(rootdir,sprintf('Spectrum%03d.mat',n));
            save(fname2,'spc')
    end
end

cgphotometer('shut');
