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


%% Parametros

Fs = 16000; 

t = 0:1/Fs:5-(1/Fs);    %eixo do tempo
x = sin(1000*2*pi*t)+sin(2000*2*pi*t)+sin(4000*2*pi*t)+sin(9000*2*pi*t)+sin(10000*2*pi*t);  %Entrada

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

fp = 3800; %frequência de passagem
fs = 5000; %frequência de corte

wp=(fp/(Fs/2))*pi; %frequência de passagem normalizada em pi
ws=(fs/(Fs/2))*pi; %frequência de corte normalizada em pi

wt=ws-wp;       %frequência de transição
wc=(ws+wp)/2;   %frequência de corte intermediária

M=ceil(6.6*pi/wt);    %ordem do filtro, olhar a página 330 do livro proakis 2012
L = length(x);          %tamanho do sinal de entrada
window = hamming(M);    %janela de hamming


%% Criação do Filtro

%%%%% Página 332 PDF Proakis 2012 %%%%%
alpha = (M-1)/2;        
n = (0:1:(M-1));
m = n - alpha;  %eixo pro lado negativo e positivo
fc = wc/pi;     %frequência de corte desnormalizada
hd = fc*(sin(pi*fc*m)./(pi*fc*m));  %Filtro Ideal fc * sen(pi*x)/(pi*x)  x=fc*m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = hd.*window';    %filtro real = filtro ideal * janela



%% Caracteristicas do Filtro

for k=1:M               %Substitui as amostras NaN do filtro por 0
    if pi*fc*m(k) == 0
        h(k)=1;
    end
end

%%%%%%% PLOT %%%%%%%%
figure(2)
subplot(2,1,1)
plot(0:length(hd)-1,h,'b-s')
grid on
title('Filtro')
xlabel('Amostras')
ylabel('Amplitude')
%%%%%%%%%%%%%%%%%%%%%

%%%%%%% PLOT %%%%%%%%
subplot(2,1,2)
zplane(h,1)
grid on
title('Plano Z do Filtro')
xlabel('')
ylabel('')
%%%%%%%%%%%%%%%%%%%%%


%% Convolução

signal = conv(h,x); %Convolução do sinal de entrada com o sinal de entrada

%%%%%%% PLOT %%%%%%%%
figure(3)
subplot(2,1,1)
plot(0:1/Fs:(1/Fs)*length(signal)-(1/Fs),signal)
grid on
title('Sinal de Entrada Convoluído com o Filtro')
xlabel('Tempo(s)')
ylabel('Amplitude')
%%%%%%%%%%%%%%%%%%%%%


fftx= abs(fft(signal)); %FFT do capeta

if (floor(M/2)-(M/2)) == 0
    freq = Fs*[1:length(fftx)/2 -length(fftx)/2:0]/length(fftx); %eixo da frequência da fft do capeta
else
    freq = Fs*[1:length(fftx)/2 -length(fftx)/2:-1]/length(fftx); %eixo da frequência da fft do capeta
end

%%%%%%% PLOT %%%%%%%%
subplot(2,1,2)
plot(freq,fftx)
grid on
title('Espectro da Frequência do Sinal Filtrado Pela Convolução')
xlabel('Frequência(Hz)')
ylabel('Magnitude')
%%%%%%%%%%%%%%%%%%%%%


%% Implementação com Equação de Diferenças

figure(5)

for k=M:L %Equação de diferença
    x_filtrado(k) = sum(x(k:-1:k-M+1).*h(end:-1:1)); %Tenho de inverter o filtro?
end

%%%%%%% PLOT %%%%%%%%
subplot(2,1,1)
plot(t,x_filtrado)
grid on
title('Sinal Filtrado Pela Equação de Diferenças')
xlabel('Tempo(s)')
ylabel('Amplitude')
%%%%%%%%%%%%%%%%%%%%%


fftx= abs(fft(x_filtrado)); %FFT do capeta
if (floor(M/2)-(M/2)) == 0
    freq = Fs*[1:length(fftx)/2 -length(fftx)/2:-1]/length(fftx); %eixo da frequência da fft do capeta
else
    freq = Fs*[1:length(fftx)/2 -length(fftx)/2:0]/length(fftx); %eixo da frequência da fft do capeta
end

%%%%%%% PLOT %%%%%%%%
subplot(2,1,2)
plot(freq,fftx)
grid on
title('Espectro da Frequência do Sinal Filtrado Pela Convolução')
xlabel('Frequência(Hz)')
ylabel('Magnitude')
%%%%%%%%%%%%%%%%%%%%%


%% Testes futuros


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CLASSIFICADOR DE TIPOS DE KRL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if (floor(M/2)-(M/2)) == 0
%     simetria = x(1:floor(M/2)) - x(round(M/2)+1:M);
%     if x(1:floor(M/2)) == x(M:-1:round(M/2)+1)
%         disp('Tipo 2 - Simetrico Par(Descentralizado)')
%         [Hr,w,d,L]=Hr_Type2(x);
%     else
%         disp('Tipo 4 - Assimetrico Par(Descentralizado)')
%         [Hr,w,d,L]=Hr_Type4(x);
%     end
% else
%     if x(1:floor(M/2)) == x(M:-1:round(M/2)+1)%mean(simetria) == zeros
%         disp('Tipo 1 - Simetrico Impar(Centralizado)')
%         [Hr,w,d,L]=Hr_Type1(x);
%     else
%         disp('Tipo 3 - Assimetrico Impar(Centralizado)') 
%         [Hr,w,d,L]=Hr_Type3(x);
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% a = d;
% n=0:M-1;
% h=x;
% amax = max(a)+1; amin = min(a)-1;
% subplot(2,2,1); stem(n,h); axis([-1 2*L+1 amin amax])
% xlabel('n'); ylabel('h(n)'); title('Impulse Response')
% subplot(2,2,3); stem(0:length(a)-1,a); axis([-1 2*L+1 amin amax])
% xlabel('n'); ylabel('a(n)'); title('a(n) coefficients')
% subplot(2,2,2); plot(w/pi,Hr);grid
% xlabel('frequency in pi units'); ylabel('Hr')
% title('Type-X Amplitude Response')
% subplot(2,2,4); zplane(h,1)











