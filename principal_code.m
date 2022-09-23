%% ARTIGO DA IEEE LATIN AMERICA TRANSACTIONS
% Probabilistic Optimal Power Flow for Balanced Islanded Microgrids
% Wesley Peres - 


%% Fluxo Probabilistico via UNSCENTED TRANSFORM
% Microrrede Ilhada Balanceada
% Wesley Peres
% 17 de Junho de 2022
%%
clear all
close all
clc
%% VARIÁVEIS GLOBAIS 
    global DATA     % estrutura com dados da rede
    global FLUXO    % estrutura com resultados do fluxo de potência
    global DYN      % estrutura com resultados dinâmicos
    global DAE      % estrutura com dados de solução
    global GEN1    AVR1  PSS1 BUS1 SS1 DAE1  LINE1
    global PROJETO PSO
    
%% SISTEMAS
format short g
% --------------------------------------------------
% Sistema Teste 33 Barras - Microrredes
sys_33_busses_novo;
DATA.bref     = 1;       % Barra de Referência
% --------------------------------------------------
DATA.freq_min = 59.7/DATA.freq;    % --> Programa Trabalha em Pu!
DATA.freq_max = 60.3/DATA.freq;     % --> Programa Trabalha em Pu!
% --------------------------------------------------
DATA.KP    = 1*0;          % 0 a 3
DATA.KQ    = -1*0;        % -2 a 0
% --------------------------------------------------
% --------------------------------------------------------------------------
% Solução Ótima - Fluxo de Potência Ótimo Probabilístico (Tabela VI do
% Artigo) --> Geradores 9, 19, 30
Fvzi =  [
     9.972318370386879e-01
     9.972614133732776e-01
     9.969848288555824e-01];
 
Vvzi =  [
     1.071695730271623e+00
     1.071818935989320e+00
     1.066260498893158e+00];
 
DATA.DGEN(:,5) = Fvzi;  % fvznew
DATA.DGEN(:,7) = Vvzi;      % Vvznew   
DATA.DGEN(:,4) = [1e-3 1e-3 1e-3];  % spnew
DATA.DGEN(:,6) = [1e-4 1e-4 1e-4];  % sqnew 
       
%% MÉDIA E COVARIÂNCIA
% Média
Pn = DATA.DBAR(:,7);
Qn = DATA.DBAR(:,8);

% Posições Nulas
wh_01 = find(Pn==0);
wh_02 = find(Qn==0);
Pn(wh_01) = 1e-6;
Qn(wh_02) = 1e-6;

level = 5/100;
% Variância
Px_Pn = level*Pn;
Px_Qn = level*Qn;
vecx = [Px_Pn; Px_Qn];

% Concatenando
xm  = [Pn; Qn]; 
Px  = diag(vecx);
%% SIGMA POINTS
tic
kappa  = 2;
[Xi W]  = SigmaPoints(xm, Px, kappa);

nsigma = length(W);
ncarga  = (length(W)-1)/2;
nbarras = ncarga/2; 

DATA.kappa = kappa;
DATA.Xi = Xi;
DATA.W = W;
DATA.nsigma = nsigma;
DATA.ncarga = ncarga;
DATA.nbarras = nbarras;
%% CÁLCULO DO FLUXO DE POTÊNCIA PARA CADA SIGMA POINT
DATA.DBAR0 = DATA.DBAR;
resolve_sigma_point_01;
%%