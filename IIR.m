close all
clear all
clc

%% Sinal de Entrada

% Fs = 16000; %frequência de amostragem
% bits = 16; 
% channel = 1;
% audio = audiorecorder(Fs, bits, channel);
% disp('Gravando')
% record(audio,5);
% pause(5)
% x = getaudiodata(audio)';
% disp('Gravação Encerrada')
% t = 0:1/Fs:length(x)*(1/Fs)-(1/Fs); 
% ruido = (0.5-rand(1,length(x)))./10;
% x = x+ruido;

[x,Fs] = audioread('sinal_de_entrada.wav');
x = x';
t = 0:1/Fs:length(x)*(1/Fs)-(1/Fs); 


%% Teste

% Fs = 16000; 

% t = 0:1/Fs:5-(1/Fs);    %eixo do tempo
% x = sin(1000*2*pi*t)+sin(2000*2*pi*t)+sin(4000*2*pi*t)+sin(9000*2*pi*t)+sin(10000*2*pi*t);   %Entrada

%%%%%%% PLOT %%%%%%%%
figure (1)
subplot(2,1,1)
plot(t,x)
grid on
title('Sinal de Entrada')
xlabel('Tempo(s)')
ylabel('Amplitude')
%%%%%%%%%%%%%%%%%%%%%

fftx= abs(fft(x)); %FFT do capeta
freq = Fs*[1:length(fftx)/2 -length(fftx)/2:-1]/length(fftx); %eixo da frequência da fft do capeta

%%%%%%% PLOT %%%%%%%%
subplot(2,1,2)
plot(freq,fftx)
grid on
title('Espectro da Frequência do Sinal de Entrada')
xlabel('Frequência(Hz)')
ylabel('Magnitude')
%%%%%%%%%%%%%%%%%%%%%

%% Parametros 

fp = 45; %frequência de passagem
fs = 55; %frequência de parada
fc = (fs+fp)/2; %frequência de corte
ft = fs-fp; %frequência de transição

wp=(fp/(Fs/2)); %frequência de passagem normalizada em pi
ws=(fs/(Fs/2)); %frequência de corte normalizada em pi
wc =(fc/(Fs/2)); %frequência de corte normalizada em pi
wt=ws-wp;       %frequência de transição

% M= log10((10.^(Rp/10) - 1)./(10.^(As/10) -1));    %ordem do filtro - to be continued
M = 10; %M/(2*log10(wp./ws));  %continued here - ordem do filtro. Olhar pagina 406(425) do livro proakis 2012
L = length(x);          %tamanho do sinal de entrada


Rp = -10*log10(1/(1+(wp/ws).^2*M));
Ripple = 10^(-Rp/20);
   
As = -10*log10(1/(1+(ws/wc).^2*M));
Attn = 10^(-As/20);

% window = hamming(M);    %janela de hamming

%% Filtro Butter-Worth

k = 0:M-1;

if (floor(M/2)-(M/2)) == 0
   pk = wc*exp(j*k*pi/M);   %par
else
   pk = wc*exp(j*((pi/(2*M))+((k*pi)/M)));   %impar
end

%%%%%%%%%%%%%%%%%%%%%%% pag 436(455) Proakis - 2012 %%%%%%%%%%%%%%%%%%%%%%
% [z,p,k] = buttap(M);

% omegap = (2)*tan(wp/2);
% omegas = (2)*tan(wp/2);

% M=ceil((log10((10^(Rp/10)-1)/(10^(As/10)-1)))./(2*log10(wp/ws)));
% omegac = omegap/((10.^(Rp/10)-1)).^(1/(2*M));

% [M,wc] = buttord(fp/(Fs),fs/(Fs),Rp,As);
% [B,A] = butter(M,wc,'low');
% p = p*wc;
% k = k*wc.^M;
% Bzao = real(poly(z)); 
% b0 = k; b = k*Bzao; a = real(poly(p));
% 
[z,p,k] = buttap(M);
[num,den] = zp2tf(z,p,k);
[B,A] = bilinear(num,den,1);

% fvtool(B,A)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%% pag 406 (425) %%%%%%%%%%%%%%%%%%%%%%%
omegap = (wp)*pi;
omegas = (ws)*pi;

M=ceil((log10((10^(Rp/10)-1)/(10^(As/10)-1)))./(2*log10(omegap/omegas)));
omegac = omegap/((10.^(Rp/10)-1).^(1/(2*M)));

[z,p,k] = butter(M,wc);
p = p*omegac;
k = k*omegac.^M;
Bzao = real(poly(z));
b0 = k; b = k*Bzao; a = real(poly(p));

[B,A] = bilinear(b,a,1);

fvtool(B,A)
% [c,b,a] = sdir2cas(b,a);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% PLOT %%%%%%%%
figure(2)
subplot(2,1,1)
plot(0:length(A)-1,A,'b-s','MarkerFaceColor', [0 0 0])
grid on
hold on
stem(0:length(A)-1,A,'k--s' )
title('Filtro')
xlabel('Amostras')
ylabel('Amplitude')
hold off
%%%%%%%%%%%%%%%%%%%%%

%%%%%%% PLOT %%%%%%%%
subplot(2,1,2)
zplane(B,A)
grid on
title('Plano Z do Filtro')
xlabel('Polo Real')
ylabel('Polo Imaginario')
legend('Polos','Zeros')
%%%%%%%%%%%%%%%%%%%%%

%% Equação de diferenças

for i=M:length(x)
    x_filtrado(i) = sum(x(i:-1:i-M+1).*B(1:end-1) + B(end));
    x_filtrado(i) = sum(x_filtrado(i)*A(1) - x_filtrado(i-1:-1:i-M+1).*A(2:end-1) -A(end));
end
x_filtrado = x_filtrado/M;
x_filtrado = mean(x_filtrado)-x_filtrado;

figure(3)
subplot(2,1,1)
plot(t,x_filtrado)
grid on
title('Sinal de Entrada Filtrado')
xlabel('Tempo(s)')
ylabel('Amplitude')

fftx= abs(fft(x_filtrado)); %FFT do capeta
fftx(1)=[];
freq = Fs*[1:length(fftx)/2 -length(fftx)/2:0]/length(fftx); %eixo da frequência da fft do capeta

subplot(2,1,2)
plot(freq,fftx);
grid on
title('Espectro da Frequência do Sinal de Entrada Filtrado')
xlabel('Frequência(Hz)')
ylabel('Magnitude')



%% Matlob
[b_matlab,a_matlab]=butter(M,wc);

%%%%%%% PLOT %%%%%%%%
figure(2)
subplot(2,1,1)
plot(0:length(a_matlab)-1,b_matlab,'-sr')
hold on
plot(0:length(b_matlab)-1,a_matlab,'-sb')
hold off
grid on
title('Sinal de Entrada Filtrado')
xlabel('Frequência(Hz)')
ylabel('Magnitude')
%%%%%%%%%%%%%%%%%%%%%

%%%%%%% PLOT %%%%%%%%
subplot(2,1,2)
zplane(b_matlab,a_matlab)
grid on
title('Espectro da Frequência do Sinal de Entrada Filtrado')
xlabel('Frequência(Hz)')
ylabel('Magnitude')
%%%%%%%%%%%%%%%%%%%%%

%% Implementação do Filtro

x_filtro(1:M)=0;
for i=M:L
    x_filtro(i) = sum(x(i:-1:i-M+1).*b_matlab(1:end-1));
    x_filtro(i) = sum(x_filtro(i)*a_matlab(1) - x_filtro(i-1:-1:i-M+1).*a_matlab(2:end-1));
end
x_filtro = x_filtro/M;
% x_filtro = filter(b,a,x);


%%%%%%% PLOT %%%%%%%%
figure(4)
subplot(2,1,1)
plot(t,x_filtro)
grid on
title('Sinal de Entrada Filtrado')
xlabel('Frequência(Hz)')
ylabel('Magnitude')
%%%%%%%%%%%%%%%%%%%%%

fftx= abs(fft(x_filtro)); %FFT do capeta
freq = Fs*[1:length(fftx)/2 -length(fftx)/2:-1]/length(fftx); %eixo da frequência da fft do capeta

%%%%%%% PLOT %%%%%%%%
subplot(2,1,2)
plot(freq,fftx)
grid on
title('Espectro da Frequência do Sinal de Entrada Filtrado')
xlabel('Frequência(Hz)')
ylabel('Magnitude')
%%%%%%%%%%%%%%%%%%%%%
