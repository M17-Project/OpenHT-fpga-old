%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NCO phase dither simulator     %
%                                %
% Wojciech Kaczmarski, SP5WWP    %
% M17 Project                    %
% Feb 2023                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc;

fs=48000;               %sample rate
N=10000;                %number of samples
%d=80;                   %phase dither magnitude
b=8;                    %LUT size in bits
dp=hex2dec("0x0CCD");   %tuning word

                        %period = 1536
dither_size=16;         %dither source bit width
seed=128;               %seed value
m=47;                   %rnd := m*rnd+b % (2^dither_size)
b=7;                    %

phase=0;    %phase accumulator
x=linspace(0, fs/2, N/2);

for i=1:N
    sig(i) = round(sin(bitshift(phase, -(16-b))/(2^b) * 2*pi)*(2^b-1));
    phase = phase + dp;
    if phase > hex2dec("0x0FFFF")
        phase = phase - hex2dec("0x10000");
    end
end

F_lin=abs(fft(sig))/N/(2^(b-1));
F_log=20*log10(F_lin);
p1=plot(x, F_log(1:N/2));
hold on;

for i=1:N
    if i==1
        val=seed;
    else
        val=mod(m*prev_val+b, 2^dither_size);
    end
    prev_val=val;

    sig(i) = round(sin(bitshift(phase, -(16-b))/(2^b) * 2*pi)*(2^b-1));
    phase = phase + dp + (bitshift(val, -8)-128); %round(rand(1)*d-d/2);
    if phase > hex2dec("0x0FFFF")
        phase = phase - hex2dec("0x10000");
    end
end

F_lin=abs(fft(sig))/N/(2^(b-1));
F_log=20*log10(F_lin);
plot(x, F_log(1:N/2));

grid on;
xlim([0, fs/2]);
ylim([-100, 0]);
legend("no phase dithering", "with dithering");
uistack(p1,'top');
