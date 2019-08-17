%  Control script for the PhotoResearch PR-650 spectroradiometer
cgloadlib
cgphotometer('open','PR650',1)

PRlambda = zeros(101,1,'uint16');
PRspd = zeros(101,100,'double');
PRn = 0;

while 1

    a = upper(input('''M'' to take a measurement, ''X'' to exit: ','s'));
    
    switch a
        case 'X'
            break
        case 'M'
            PRn = PRn+1;
            PRXYZ = cgphotometer('XYZ');  % Take the measurement
            PRspc = cgphotometer('SPC');  % Download the spectrum
            PRlambda(:) = PRspc(:,1);       % Save wavelength scale
            PRspd(:,PRn) = PRspc(:,2);        % Copy SPD to array


            fname = fullfile(rootdir,sprintf('Spectrum%03d.txt',PRn));
            fid = fopen(fname','w');
            for k = 1:101
              fprintf(fid,'%d %f\n',uint16(PRlambda(k)),PRspd(k,PRn));
            end
            fclose(fid);
            
            fname2 = fullfile(rootdir,sprintf('Spectrum%03d.mat',PRn));
            save(fname2,'spc')
    end
end

cgphotometer('shut');
