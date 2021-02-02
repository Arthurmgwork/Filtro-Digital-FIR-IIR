close all
clear all
clc


%% Sinal de Entrada


resposta = questdlg('Deseja gravar um arquivo de audio?', ...
    'Reproduzir','Sim', 'N�o','N�o');
if strcmp(resposta,'Sim')   % Compara as strings
    Fs = 16000; %frequ�ncia de amostragem
    bits = 16; %quantidade de bits do sinal de audio
    channel = 1; %quantidade de canais
    audio = audiorecorder(Fs, bits, channel); %audiorecordar(frequ�ncia de amostragem, n�mero de bits do sinal, n�mero de canais)
    disp('Gravando') %avisa quando come�a a gravar
    record(audio,5); %vai gravar 5 segundos de audio
    pause(5) %pausa para gravar os 5 segundos de audio
    x = getaudiodata(audio)'; %salvando o audio gravado na variavel x
    disp('Grava��o Encerrada')
    t = 0:1/Fs:length(x)*(1/Fs)-(1/Fs);  %criando eixo do tempo
    ruido = (0.05*sin(4000*2*pi*t))+(0.05*sin(5000*2*pi*t))+(0.05*sin(6000*2*pi*t));%(0.5-rand(1,length(x)))./20; %criando ru�do para an�lise do sinal
    x = x+ruido; % adicionando ru�do no sinal
    resposta1 = questdlg('Deseja reproduzir este arquivo de audio?', ...
    'Reproduzir','Sim', 'N�o','N�o');
    if strcmp(resposta1,'Sim')   % Compara as strings
        sound(x,Fs);
    end
else
    Fs = 16000; 

    t = 0:1/Fs:5-(1/Fs);    %eixo do tempo
    x = sin(1000*2*pi*t)+sin(2000*2*pi*t)+sin(3000*2*pi*t)+sin(3500*2*pi*t)+sin(4000*2*pi*t)+sin(5000*2*pi*t)+sin(6000*2*pi*t);  %Entrada
end    



% [x,Fs] = audioread('sinal_de_entrada.wav');
% x = x';
% t = 0:1/Fs:length(x)*(1/Fs)-(1/Fs); 


%%
%%%%%%% PLOT %%%%%%%%
figure (1)
subplot(2,1,1)
plot(t,x)
grid on
title('Sinal de Entrada')
xlabel('Tempo(s)')
ylabel('Amplitude')
%xlim([1 1.003])
%%%%%%%%%%%%%%%%%%%%%

fftx= abs(fft(x)); %FFT do capeta
freq = Fs*[1:length(fftx)/2]/length(fftx); %eixo da frequ�ncia da fft do capeta

%%%%%%% PLOT %%%%%%%%
subplot(2,1,2)
plot(freq,fftx(1:length(freq)))
grid on
title('Espectro da Frequ�ncia do Sinal de Entrada')
xlabel('Frequ�ncia(Hz)')
ylabel('Magnitude')
%%%%%%%%%%%%%%%%%%%%%


%% Parametros Pagina 305 do Proakis 2012
fp = 2900;    %frequ�ncia de passagem (passa baixa)
fs = 4000;     %frequ�ncia de parada (passa baixa)
fc = (fs+fp)/2; %frequ�ncia de corte
ft = fs-fp;      %frequ�ncia de transi��o

wp = (fp/(Fs/2))*pi; %frequ�ncia de passagem normalizada em pi
ws = (fs/(Fs/2))*pi;  %frequ�ncia de parada normalizada em pi
wc = (fc/(Fs/2))*pi;   %frequ�ncia de corte normalizada em pi
wt = ws-wp;             %frequ�ncia de transi��o

Rp = 1;    %Parametro de inicializa��o do Ripple da faixa de passagem
As = 1;     %Parametro de inicializa��o do Ripple da faixa de parada
sigma1 = 0;  %Parametro de inicializa��o do sigma 1
sigma2 = 0;   %Parametro de inicializa��o do sigma 2

while Rp <= 0.2 || Rp >= 0.25   %faixa de tolerancia para o meu Rippler de faixa de passagem
    sigma1 = sigma1 + 0.0001;
    Rp = -20*log10((1-sigma1)/(1+sigma1));
end

while As <= 15 || As >= 20      %faixa de tolerancia para o meu Rippler de faixa de parada
    sigma2 = sigma2 + 0.0001;
    As = -20*log10(sigma2/(1+sigma1));
end

M = ceil(1.8*pi/wt);    %ordem do filtro, vai depender da janela que foi usada, olhar a p�gina 330 do livro proakis 2012
L = length(x);               %tamanho do sinal de entrada
window = rectwin(M);          %janela retangular


%% Cria��o do Filtro

%%%%% P�gina 332 PDF Proakis 2012 %%%%%
alpha = (M-1)/2;        
n = (0:1:(M-1));
m = (n - alpha);  %eixo pro lado negativo e positivo
wc_d = (wc/pi);    %frequ�ncia de corte desnormalizada
hd = wc_d*(sin(pi*wc_d*m)./(pi*wc_d*m));  %Filtro Ideal   x=fc*m  %%%  passa baixa: fc * sen(pi*x)/(pi*x) %%%%% passa alta: fc * -cos(pi*x)/(pi*x) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hd = hd;
h = hd.*(window');    %filtro real = filtro ideal * janela
% plot(h)
fvtool(h)

%% Caracteristicas do Filtro

% for k=1:M               %Substitui as amostras NaN do filtro por 0
%     if pi*fc*m(k) == 0
%         h(k)=1;
%     end
% end
% M = length(h);


%%%%%%% PLOT %%%%%%%%
figure(2)
subplot(2,1,1)
plot(0:length(h)-1,h,'b-s','MarkerFaceColor', [0 0 0])
grid on
hold on
stem(0:length(h)-1,h,'k--s' )
title('Filtro')
xlabel('Amostras')
ylabel('Amplitude')
hold off
%%%%%%%%%%%%%%%%%%%%%

%%%%%%% PLOT %%%%%%%%
subplot(2,1,2)
zplane(h,1)
grid on
title('Plano Z do Filtro')
xlabel('Polo Real')
ylabel('Polo Imaginario')
%%%%%%%%%%%%%%%%%%%%%


%% Convolu��o

% signal = conv(x,h); %Convolu��o do sinal de entrada com o sinal de entrada
% 
% %%%%%%% PLOT %%%%%%%%
% figure(3)
% subplot(2,1,1)
% plot(0:1/Fs:(1/Fs)*length(signal)-(1/Fs),signal)
% grid on
% title('Sinal de Entrada Convolu�do com o Filtro')
% xlabel('Tempo(s)')
% ylabel('Amplitude')
% %%%%%%%%%%%%%%%%%%%%%
% 
% 
% fftx= abs(fft(signal)); %FFT do capeta
% 
% if (floor(length(fftx)/2)-(length(fftx)/2)) == 0
%     freq = Fs*[1:length(fftx)/2 -length(fftx)/2:-1]/length(fftx); %eixo da frequ�ncia da fft do capeta
% else
%     freq = Fs*[1:length(fftx)/2 -length(fftx)/2:0]/length(fftx); %eixo da frequ�ncia da fft do capeta
% end
% 
% %%%%%%% PLOT %%%%%%%%
% subplot(2,1,2)
% plot(freq,fftx)
% grid on
% title('Espectro da Frequ�ncia do Sinal Filtrado Pela Convolu��o')
% xlabel('Frequ�ncia(Hz)')
% ylabel('Magnitude')
% %%%%%%%%%%%%%%%%%%%%%


%% Implementa��o com Equa��o de Diferen�as

figure(4)

for k=M:L %Equa��o de diferen�a
    x_filtrado(k) = sum(x(k:-1:k-M+1).*h(1:end));
end

%%%%%%% PLOT %%%%%%%%
subplot(2,1,1)
plot(t,x_filtrado)
grid on
title('Sinal de Entrada Filtrado')
xlabel('Tempo(s)')
ylabel('Amplitude')
%xlim([1 1.003])
%%%%%%%%%%%%%%%%%%%%%


fftx= abs(fft(x_filtrado)); %FFT do capeta
freq = Fs*[1:length(fftx)/2]/length(fftx); %eixo da frequ�ncia da fft do capeta

%%%%%%% PLOT %%%%%%%%
subplot(2,1,2)
plot(freq,fftx(1:length(freq)))
grid on
title('Espectro da Frequ�ncia do Sinal de Entrada Filtrado')
xlabel('Frequ�ncia(Hz)')
ylabel('Magnitude')
axis([1 8000 0 max(fftx)*1.15])
%%%%%%%%%%%%%%%%%%%%%

fvtool(h) % Respsota do Filtro







