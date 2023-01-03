%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 48k->400k baseband rational upsampler %
% for the AT86RF215 RF IC               %
%                                       %
% Wojciech Kaczmarski, SP5WWP           %
% M17 Project                           %
% Jan 2023                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc;

%generate baseband, 48kSa/s
flt=rcosdesign(0.5, 8, 10);
sig=(randi([0,3], 1, 800)-1.5)*2;
sig=upsample(sig, 10);
fbsb=filter(flt, 1, sig);

%upsample to 1200kSa/s (3x AT86RF215's minimum f_s)
ufbsb=upsample(fbsb, 25);

%interpolate 25x
eq=design(fdesign.nyquist(25,'N,TW',100,0.06),'kaiserwin'); %L-th band Nyquist, L=25
eq.numerator = eq.numerator*sqrt(25)*1.2; %gain correction
fvtool(eq);
iflt=eq.numerator;
fufbsb=filter(iflt,1,ufbsb);

%decimate 3x
dfufbsb=downsample(fufbsb, 3);

%plots
plot(psd(spectrum.periodogram,fbsb,'Fs',48000,'NFFT',length(fbsb)));
hold on;
plot(psd(spectrum.periodogram,fufbsb,'Fs',1200000,'NFFT',length(fufbsb)));
hold on;
plot(psd(spectrum.periodogram,dfufbsb,'Fs',400000,'NFFT',length(dfufbsb)));
legend("original at 48kSa/s", "48kSa/s upsampled to 1.2M", "1.2MSa/s downsampled to 400k");

%filter and plot the eye diagram
flt=rcosdesign(0.5, 8, 10*25);
ffbsb=filter(flt,1,fufbsb);
eyediagram(ffbsb(200*25:end), 2*10*25);

%convert the taps to VHDL array
one=32768; % 0x8000
fprintf('type coefficients is array (0 to NUM_TAPS-1) of signed(15 downto 0);\nsignal coeff_s: coefficients :=(\n');
for i=2:4:100
    if(i<96)
        fprintf('\tx\"%04X\", x\"%04X\", x\"%04X\", x\"%04X\",\n', typecast(int16(eq.numerator(i)*one),'uint16'), ...
            typecast(int16(eq.numerator(i+1)*one),'uint16'), ...
            typecast(int16(eq.numerator(i+2)*one),'uint16'), ...
            typecast(int16(eq.numerator(i+3)*one),'uint16'))
    else
        fprintf('\tx\"%04X\", x\"%04X\", x\"%04X\"\n', typecast(int16(eq.numerator(i)*one),'uint16'), ...
            typecast(int16(eq.numerator(i+1)*one),'uint16'), ...
            typecast(int16(eq.numerator(i+2)*one),'uint16'))
    end
end
fprintf(');');
