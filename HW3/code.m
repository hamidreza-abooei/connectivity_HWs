clc;
clear;
close all;

% Analysis of sensor- and source-level connectivity

%% Simulation data preperation and visualization
% always start with the same random numbers to make the figures reproducible
rng default
rng(50)

cfg             = [];
cfg.ntrials     = 500;
cfg.triallength = 1;
cfg.fsample     = 200;
cfg.nsignal     = 3;
cfg.method      = 'ar';

% x(t) = 0.8x(t-1) - 0.5x(t-2)
% y(t) = 0.9y(t-1) + 0.5z(t-1) - 0.8*y(t-2)
% z(t) = 0.5z(t-1) + 0.4x(t-1) - 0.2*z(t-2)

cfg.params(:,:,1) = [ 0.8    0    0 ;
                        0  0.9  0.5 ;
                      0.4    0  0.5];

cfg.params(:,:,2) = [-0.5    0    0 ;
                        0 -0.8    0 ;
                        0    0 -0.2];

cfg.noisecov      = [ 0.3    0    0 ;
                        0    1    0 ;
                        0    0  0.2];

data              = ft_connectivitysimulation(cfg);

% Visualize data
figure
plot(data.time{1}, data.trial{1})
legend(data.label)
xlabel('time (s)')


%% computation of the multivariate autoregressive model using bsmart toolbox
cfg = [];
cfg.viewmode = 'vertical';  % you can also specify 'butterfly'
ft_databrowser(cfg, data);

cfg         = [];
cfg.order   = 5;
cfg.toolbox = 'bsmart';
mdata       = ft_mvaranalysis(cfg, data);


%% Computation of the spectral transfer function
% Parametric approach
cfg        = [];
cfg.method = 'mvar';
mfreq      = ft_freqanalysis(cfg, mdata);

% Non-Parametric approach
cfg           = [];
cfg.method    = 'mtmfft';
cfg.taper     = 'dpss';
cfg.output    = 'fourier';
cfg.tapsmofrq = 2;
freq          = ft_freqanalysis(cfg, data);

%% Computation and inspection of the connectivity measures
% COH, Symmetry
cfg           = [];
cfg.method    = 'coh';
coh           = ft_connectivityanalysis(cfg, freq);
cohm          = ft_connectivityanalysis(cfg, mfreq);

% ‌‌Visualization
cfg           = [];
cfg.parameter = 'cohspctrm';
cfg.zlim      = [0 1];
ft_connectivityplot(cfg, coh, cohm);

% Granger Causality, 
cfg           = [];
cfg.method    = 'granger';
grangerm       = ft_connectivityanalysis(cfg, mfreq);

%Visualization
figure()
cfg           = [];
cfg.parameter = 'grangerspctrm';
cfg.zlim      = [0 1];
ft_connectivityplot(cfg, grangerm);

%% Exercise
cfg           = [];
cfg.method    = 'granger';
granger       = ft_connectivityanalysis(cfg, freq);

% Visualization
% figure()
% cfg           = [];
% cfg.parameter = 'grangerspctrm';
% cfg.zlim      = [0 1];
% ft_connectivityplot(cfg, granger,grangerm);
figure
for row=1:3
    for col=1:3
        subplot(3,3,(row-1)*3+col);
        plot(granger.freq, squeeze(granger.grangerspctrm(row,col,:)))
        hold on;
        plot(grangerm.freq, squeeze(grangerm.grangerspctrm(row,col,:)),'r')
        ylim([0 1])
    end
end
legend("granger","grangerm")



%% Exercise: Computation of pdc, dtf, psi with mfreq
% pdc
cfg           = [];
cfg.method    = 'pdc';
pdcm       = ft_connectivityanalysis(cfg, mfreq);

%Visualization
figure()
cfg           = [];
cfg.parameter = 'pdcspctrm';
cfg.zlim      = [0 1];
ft_connectivityplot(cfg, pdcm);

% dtf
cfg           = [];
cfg.method    = 'dtf';
dtfm       = ft_connectivityanalysis(cfg, mfreq);

%Visualization
figure()
cfg           = [];
cfg.parameter = 'dtfspctrm';
cfg.zlim      = [0 1];
ft_connectivityplot(cfg, dtfm);


% psi
cfg           = [];
cfg.method    = 'psi';
cfg.bandwidth = 10;
psim       = ft_connectivityanalysis(cfg, mfreq);

%Visualization
figure()
cfg           = [];
cfg.parameter = 'psispctrm';
cfg.zlim      = [0 1];
ft_connectivityplot(cfg, psim);

%% Simulated data with common pick-up and different noise levels
% create some instantaneously mixed data

% define some variables locally
nTrials  = 100;
nSamples = 1000;
fsample  = 1000;

% mixing matrix
mixing   = [0.8 0.2 0;
              0 0.2 0.8];

data       = [];
data.trial = cell(1,nTrials);
data.time  = cell(1,nTrials);
for k = 1:nTrials
  dat = randn(3, nSamples);
  dat(2,:) = ft_preproc_bandpassfilter(dat(2,:), 1000, [15 25]);
  dat = 0.2.*(dat-repmat(mean(dat,2),[1 nSamples]))./repmat(std(dat,[],2),[1 nSamples]);
  data.trial{k} = mixing * dat;
  data.time{k}  = (0:nSamples-1)./fsample;
end
data.label = {'chan1' 'chan2'}';

figure;plot(dat'+repmat([0 1 2],[nSamples 1]));
title('original ''sources''');

figure;plot((mixing*dat)'+repmat([0 1],[nSamples 1]));
axis([0 1000 -1 2]);
set(findobj(gcf,'color',[0 0.5 0]), 'color', [1 0 0]);
title('mixed ''sources''');


% do spectral analysis
cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'fourier';
cfg.foilim    = [0 200];
cfg.tapsmofrq = 5;
freq          = ft_freqanalysis(cfg, data);
fd            = ft_freqdescriptives(cfg, freq);

figure;plot(fd.freq, fd.powspctrm);
set(findobj(gcf,'color',[0 0.5 0]), 'color', [1 0 0]);
title('power spectrum');




% compute connectivity
cfg = [];
cfg.method = 'granger';
g = ft_connectivityanalysis(cfg, freq);
cfg.method = 'coh';
c = ft_connectivityanalysis(cfg, freq);


% visualize the results
cfg = [];
cfg.parameter = 'grangerspctrm';
figure; ft_connectivityplot(cfg, g);
cfg.parameter = 'cohspctrm';
figure; ft_connectivityplot(cfg, c);




%% Exercise: Using different mixing matrix
% create some instantaneously mixed data

% define some variables locally
nTrials  = 100;
nSamples = 1000;
fsample  = 1000;

% mixing matrix
mixing   = [0.9 0.1 0;
            0.6 0.2 0.2];

data       = [];
data.trial = cell(1,nTrials);
data.time  = cell(1,nTrials);
for k = 1:nTrials
  dat = randn(3, nSamples);
  dat(2,:) = ft_preproc_bandpassfilter(dat(2,:), 1000, [15 25]);
  dat = 0.2.*(dat-repmat(mean(dat,2),[1 nSamples]))./repmat(std(dat,[],2),[1 nSamples]);
  data.trial{k} = mixing * dat;
  data.time{k}  = (0:nSamples-1)./fsample;
end
data.label = {'chan1' 'chan2'}';

figure;plot(dat'+repmat([0 1 2],[nSamples 1]));
title('original ''sources''');

figure;plot((mixing*dat)'+repmat([0 1],[nSamples 1]));
axis([0 1000 -1 2]);
set(findobj(gcf,'color',[0 0.5 0]), 'color', [1 0 0]);
title('mixed ''sources''');


% do spectral analysis
cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'fourier';
cfg.foilim    = [0 200];
cfg.tapsmofrq = 5;
freq          = ft_freqanalysis(cfg, data);
fd            = ft_freqdescriptives(cfg, freq);

figure;plot(fd.freq, fd.powspctrm);
set(findobj(gcf,'color',[0 0.5 0]), 'color', [1 0 0]);
title('power spectrum');




% compute connectivity
cfg = [];
cfg.method = 'granger';
g = ft_connectivityanalysis(cfg, freq);
cfg.method = 'coh';
c = ft_connectivityanalysis(cfg, freq);


% visualize the results
cfg = [];
cfg.parameter = 'grangerspctrm';
figure; ft_connectivityplot(cfg, g);
cfg.parameter = 'cohspctrm';
figure; ft_connectivityplot(cfg, c);



%% Generate different signals

% create some instantaneously mixed data

% define some variables locally
nTrials  = 100;
nSamples = 1000;
fsample  = 1000;

% mixing matrix
mixing   = [0.7 0.1 0.2 0;
            0 0.3 0.2 0.5];

data       = [];
data.trial = cell(1,nTrials);
data.time  = cell(1,nTrials);
for k = 1:nTrials
  dat = randn(4, nSamples+10);
  dat(2,:) = ft_preproc_bandpassfilter(dat(2,:), 1000, [15 25]);
  dat(3,1:(nSamples)) = dat(2,11:(nSamples+10));
  dat = dat(:,1:1000);
  dat = 0.2.*(dat-repmat(mean(dat,2),[1 nSamples]))./repmat(std(dat,[],2),[1 nSamples]);
  data.trial{k} = mixing * dat;
  data.time{k}  = (0:nSamples-1)./fsample;
end
data.label = {'chan1' 'chan2'}';

figure;plot(dat'+repmat([0 1 2 3],[nSamples 1]));
title('original ''sources''');

figure;plot((mixing*dat)'+repmat([0 1],[nSamples 1]));
axis([0 1000 -1 2]);
set(findobj(gcf,'color',[0 0.5 0]), 'color', [1 0 0]);
title('mixed ''sources''');


% do spectral analysis
cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'fourier';
cfg.foilim    = [0 200];
cfg.tapsmofrq = 5;
freq          = ft_freqanalysis(cfg, data);
fd            = ft_freqdescriptives(cfg, freq);

figure;plot(fd.freq, fd.powspctrm);
set(findobj(gcf,'color',[0 0.5 0]), 'color', [1 0 0]);
title('power spectrum');




% compute connectivity
cfg = [];
cfg.method = 'granger';
g = ft_connectivityanalysis(cfg, freq);
cfg.method = 'coh';
c = ft_connectivityanalysis(cfg, freq);
cfg.method = 'pdc';
pdc=ft_connectivityanalysis(cfg, freq);
cfg.method = 'dtf';
dtf=ft_connectivityanalysis(cfg, freq);
cfg.method = 'psi';
cfg.bandwidth = 10;
psi=ft_connectivityanalysis(cfg, freq);




% visualize the results
cfg = [];
cfg.parameter = 'grangerspctrm';
figure; ft_connectivityplot(cfg, g);
cfg.parameter = 'cohspctrm';
figure; ft_connectivityplot(cfg, c);
cfg.parameter = 'pdcspctrm';
figure; ft_connectivityplot(cfg, pdc);
cfg.parameter = 'dtfspctrm';
figure; ft_connectivityplot(cfg, dtf);
cfg.parameter = 'psispctrm';
figure; ft_connectivityplot(cfg,psi);







