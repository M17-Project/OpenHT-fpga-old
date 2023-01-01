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
eq=design(fdesign.nyquist(25,'N,TW',200,0.04),'equiripple'); %L-th band Nyquist, L=25
fvtool(eq);
iflt=eq.numerator*25.0;
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