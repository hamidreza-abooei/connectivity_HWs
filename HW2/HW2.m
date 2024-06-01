clc
clear
close all

% % find the interesting epochs of data
% cfg = [];
% cfg.trialfun                  = 'trialfun_left';
% cfg.dataset                   = 'SubjectCMC.ds';
% cfg = ft_definetrial(cfg);
% 
% % detect EOG artifacts in the MEG data
% cfg.continuous                = 'yes';
% cfg.artfctdef.eog.padding     = 0;
% cfg.artfctdef.eog.bpfilter    = 'no';
% cfg.artfctdef.eog.detrend     = 'yes';
% cfg.artfctdef.eog.hilbert     = 'no';
% cfg.artfctdef.eog.rectify     = 'yes';
% cfg.artfctdef.eog.cutoff      = 2.5;
% cfg.artfctdef.eog.interactive = 'no';
% cfg = ft_artifact_eog(cfg);
% 
% % detect jump artifacts in the MEG data
% cfg.artfctdef.jump.interactive = 'no';
% cfg.padding                    = 5;
% cfg = ft_artifact_jump(cfg);
% 
% % detect muscle artifacts in the MEG data
% cfg.artfctdef.muscle.cutoff      = 8;
% cfg.artfctdef.muscle.interactive = 'no';
% cfg = ft_artifact_muscle(cfg);
% 
% % reject the epochs that contain artifacts
% cfg.artfctdef.reject          = 'complete';
% cfg = ft_rejectartifact(cfg);
% 
% % preprocess the MEG data
% cfg.demean                    = 'yes';
% cfg.dftfilter                 = 'yes';
% cfg.channel                   = {'MEG'};
% cfg.continuous                = 'yes';
% meg = ft_preprocessing(cfg);
% 
% 
% % Preprocess the EMG
% cfg              = [];
% cfg.dataset      = meg.cfg.dataset;
% cfg.trl          = meg.cfg.trl;
% cfg.continuous   = 'yes';
% cfg.demean       = 'yes';
% cfg.dftfilter    = 'yes';
% cfg.channel      = {'EMGlft' 'EMGrgt'};
% cfg.hpfilter     = 'yes';
% cfg.hpfreq       = 10;
% cfg.rectify      = 'yes';
% emg = ft_preprocessing(cfg);
% 
% % Combine EMG and EMG
% data = ft_appenddata([], meg, emg);
% 
% save data data

%% load data set and plot EMG and MEG for one trial

load data

figure
subplot(2,1,1);
plot(data.time{1},data.trial{1}(77,:));
axis tight;
legend(data.label(77));
title("MEG signal");
ylabel("Amplitude");
xlabel("time (sec)")

subplot(2,1,2);
plot(data.time{1},data.trial{1}(152:153,:));
axis tight;
legend(data.label(152:153));
title("EMG signal");
ylabel("Amplitude");
xlabel("time (sec)")

%% Computing the coherence

load data

% %% Method 1
% cfg            = [];
% cfg.output     = 'fourier';
% cfg.method     = 'mtmfft';
% cfg.foilim     = [5 100];
% cfg.tapsmofrq  = 5;
% cfg.keeptrials = 'yes';
% cfg.channel    = {'MEG' 'EMGlft' 'EMGrgt'};
% freqfourier    = ft_freqanalysis(cfg, data);

%% Method 2
cfg            = [];
cfg.output     = 'powandcsd';
cfg.method     = 'mtmfft';
cfg.foilim     = [5 100];
cfg.tapsmofrq  = 5;
cfg.keeptrials = 'yes';
cfg.channel    = {'MEG' 'EMGlft' 'EMGrgt'};
cfg.channelcmb = {'MEG' 'EMGlft'; 'MEG' 'EMGrgt'};
freq           = ft_freqanalysis(cfg, data);


cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'MEG' 'EMG'};
fd             = ft_connectivityanalysis(cfg, freq);
% fdfourier      = ft_connectivityanalysis(cfg, freqfourier);



%% Displaying the coherence
cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [5 80];
cfg.refchannel       = 'EMGlft';
cfg.layout           = 'CTF151_helmet.mat';
cfg.showlabels       = 'yes';
figure; ft_multiplotER(cfg, fd)


cfg.channel = 'MRC21';
figure; ft_singleplotER(cfg, fd);



%% Exercise 2
cfg                  = [];
cfg.parameter        = 'cohspctrm';
% cfg.xlim             = [15 20];
cfg.xlim             = [13 30];
cfg.zlim             = [0 0.1];
cfg.refchannel       = 'EMGlft';
cfg.layout           = 'CTF151_helmet.mat';
figure; ft_topoplotER(cfg, fd)

%% Exercise 3
cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [35 45];
cfg.zlim             = [0 0.1];
cfg.refchannel       = 'EMGlft';
cfg.layout           = 'CTF151_helmet.mat';
figure; ft_topoplotER(cfg, fd)


%% Exercise 4
cfg            = [];
cfg.output     = 'powandcsd';
cfg.method     = 'mtmfft';
cfg.foilim     = [5 100];
cfg.tapsmofrq  = 2;
cfg.keeptrials = 'yes';
cfg.channel    = {'MEG' 'EMGlft'};
cfg.channelcmb = {'MEG' 'EMGlft'};
freq2          = ft_freqanalysis(cfg,data);

cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'MEG' 'EMG'};
fd2            = ft_connectivityanalysis(cfg,freq2);

% Plot the results of the 5 and 2Hz smoothing:

cfg               = [];
cfg.parameter     = 'cohspctrm';
cfg.refchannel    = 'EMGlft';
cfg.xlim          = [5 80];
cfg.channel       = 'MRC21';
figure; ft_singleplotER(cfg, fd, fd2);
legend("5Hz","2Hz")
title("Evaluate the smoothing by changing kernel size:2,5Hz")
xlabel("freq")
ylabel("Amplitude")

cfg            = [];
cfg.output     = 'powandcsd';
cfg.method     = 'mtmfft';
cfg.foilim     = [5 100];
cfg.keeptrials = 'yes';
cfg.channel    = {'MEG' 'EMGlft'};
cfg.channelcmb = {'MEG' 'EMGlft'};
cfg.tapsmofrq = 10;
freq10        = ft_freqanalysis(cfg,data);

cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'MEG' 'EMG'};
fd10          = ft_connectivityanalysis(cfg,freq10);


cfg               = [];
cfg.parameter     = 'cohspctrm';
cfg.xlim          = [5 80];
cfg.ylim          = [0 0.2];
cfg.refchannel    = 'EMGlft';
cfg.channel       = 'MRC21';
figure; ft_singleplotER(cfg, fd, fd2, fd10);
legend("5Hz","2Hz","10Hz")
title("Evaluate the smoothing by changing kernel size:2,5,10Hz")
xlabel("freq")
ylabel("Amplitude")


%% Exercise 5

cfg            = [];
cfg.output     = 'powandcsd';
cfg.method     = 'mtmfft';
cfg.foilim     = [5 100];
cfg.tapsmofrq  = 5;
cfg.keeptrials = 'yes';
cfg.channel    = {'MEG' 'EMGlft'};
cfg.channelcmb = {'MEG' 'EMGlft'};
cfg.trials     = 1:50;
freq50         = ft_freqanalysis(cfg,data);

cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'MEG' 'EMG'};
fd50           = ft_connectivityanalysis(cfg,freq50);

cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [5 100];
cfg.ylim             = [0 0.2];
cfg.refchannel       = 'EMGlft';
cfg.channel          = 'MRC21';
figure; ft_singleplotER(cfg, fd, fd50);
legend("1 trial","50 trials")
title("Comparing between using 1 trial vs 50 trials to calculate coh")%,tapsmofrq=2")
xlabel("freq")
ylabel("Amplitude")
%%
cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.xlim             = [35 45];
% cfg.zlim             = [0 0.1];
cfg.refchannel       = 'EMGlft';
cfg.layout           = 'CTF151_helmet.mat';
figure; ft_topoplotER(cfg, fd50)



