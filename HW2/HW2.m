% find the interesting epochs of data
cfg = [];
cfg.trialfun                  = 'trialfun_left';
cfg.dataset                   = 'SubjectCMC.ds';
cfg = ft_definetrial(cfg);

% detect EOG artifacts in the MEG data
cfg.continuous                = 'yes';
cfg.artfctdef.eog.padding     = 0;
cfg.artfctdef.eog.bpfilter    = 'no';
cfg.artfctdef.eog.detrend     = 'yes';
cfg.artfctdef.eog.hilbert     = 'no';
cfg.artfctdef.eog.rectify     = 'yes';
cfg.artfctdef.eog.cutoff      = 2.5;
cfg.artfctdef.eog.interactive = 'no';
cfg = ft_artifact_eog(cfg);

% detect jump artifacts in the MEG data
cfg.artfctdef.jump.interactive = 'no';
cfg.padding                    = 5;
cfg = ft_artifact_jump(cfg);

% detect muscle artifacts in the MEG data
cfg.artfctdef.muscle.cutoff      = 8;
cfg.artfctdef.muscle.interactive = 'no';
cfg = ft_artifact_muscle(cfg);

% reject the epochs that contain artifacts
cfg.artfctdef.reject          = 'complete';
cfg = ft_rejectartifact(cfg);

% preprocess the MEG data
cfg.demean                    = 'yes';
cfg.dftfilter                 = 'yes';
cfg.channel                   = {'MEG'};
cfg.continuous                = 'yes';
meg = ft_preprocessing(cfg);


% Preprocess the EMG
cfg              = [];
cfg.dataset      = meg.cfg.dataset;
cfg.trl          = meg.cfg.trl;
cfg.continuous   = 'yes';
cfg.demean       = 'yes';
cfg.dftfilter    = 'yes';
cfg.channel      = {'EMGlft' 'EMGrgt'};
cfg.hpfilter     = 'yes';
cfg.hpfreq       = 10;
cfg.rectify      = 'yes';
emg = ft_preprocessing(cfg);

% Combine EMG and EMG
data = ft_appenddata([], meg, emg);

save data data

%% load data set and continue

% load data

figure
subplot(2,1,1);
plot(data.time{1},data.trial{1}(77,:));
axis tight;
legend(data.label(77));

subplot(2,1,2);
plot(data.time{1},data.trial{1}(152:153,:));
axis tight;
legend(data.label(152:153));












