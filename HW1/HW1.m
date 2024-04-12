clear;
close all;
clc;
% Hamidreza Abooei 402617509

% Read data according to the trials.
cfg              = [];
cfg.trialfun     = 'trialfun_affcog';
cfg.headerfile   = 's04.vhdr';
cfg.datafile     = 's04.eeg';
cfg = ft_definetrial(cfg);

% Baseline-correction options
cfg.demean          = 'yes';
cfg.baselinewindow  = [-0.2 0];

% Fitering options
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 100;

% Re-referencing options
cfg.implicitref   = 'LM';
cfg.reref         = 'yes';
cfg.refchannel    = {'LM' 'RM'};

data = ft_preprocessing(cfg);

cfg = [];  % use only default options
ft_databrowser(cfg, data);

% read continous data
cfg         = [];
cfg.dataset = 's04.vhdr';
% cfg.viewmode = 'vertical';
ft_databrowser(cfg);

% Single trial plot
figure()
plot(data.time{1}, data.trial{1});

% EOGV channel
cfg              = [];
cfg.channel      = {'53' 'LEOG'};
cfg.reref        = 'yes';
cfg.implicitref  = []; % this is the default, we mention it here to be explicit
cfg.refchannel   = {'53'};
eogv             = ft_preprocessing(cfg, data);

% only keep one channel, and rename to eogv
cfg              = [];
cfg.channel      = 'LEOG';
eogv             = ft_selectdata(cfg, eogv);
eogv.label       = {'eogv'};

% EOGH channel
cfg              = [];
cfg.channel      = {'57' '25'};
cfg.reref        = 'yes';
cfg.implicitref  = []; % this is the default, we mention it here to be explicit
cfg.refchannel   = {'57'};
eogh             = ft_preprocessing(cfg, data);

% only keep one channel, and rename to eogh
cfg              = [];
cfg.channel      = '25';
eogh             = ft_selectdata(cfg, eogh);
eogh.label       = {'eogh'};

% only keep all non-EOG channels
cfg         = [];
cfg.channel = setdiff(1:60, [53, 57, 25]);        % you can use either strings or numbers as selection
data        = ft_selectdata(cfg, data);

% append the EOGH and EOGV channel to the 60 selected EEG channels
cfg  = [];
data = ft_appenddata(cfg, data, eogv, eogh);

% check channel labels 
disp(data.label')

% EOG Artifact detection
cfg = [];
cfg.artfctdef.eog.channel = {'eogv','eogh'};
cfg.artfctdef.eog.bpfilter   = 'yes';
cfg.artfctdef.eog.bpfilttype = 'but';
cfg.artfctdef.eog.bpfreq     = [1 15];
cfg.artfctdef.eog.bpfiltord  = 4;
cfg.artfctdef.eog.hilbert    = 'yes';
[cfg, artifact] = ft_artifact_eog(cfg,data);

% EOG Artifact rejection
cfg.artfctdef.reject = 'complete';
cfg.artfctdef.feedback = 'yes';
[data] = ft_rejectartifact(cfg, data);

% Threshold exceeding
cfg =[];
cfg.artfctdef.threshold.min = -80;
cfg.artfctdef.threshold.max = 100;
cfg.continuous = 'no';
cfg.artfctdef.threshold.channel   = 'all';
cfg.artfctdef.threshold.bpfilter  = 'no';

[cfg, artifact] = ft_artifact_threshold(cfg, data);

cfg.artfctdef.feedback = 'yes';
[data_clean] = ft_rejectartifact(cfg, data);


% use ft_timelockanalysis to compute the ERPs
% ERP trial 1
cfg = [];
cfg.trials = find(data_clean.trialinfo==1);
task1 = ft_timelockanalysis(cfg, data_clean);

% ERP trial 2
cfg = [];
cfg.trials = find(data_clean.trialinfo==2);
task2 = ft_timelockanalysis(cfg, data_clean);

% show ERP generated
p3_channel = '41';
p4_channel = '9';

% Show on topography map
cfg = [];
cfg.channel = {p3_channel,p4_channel};
cfg.layout = 'mpi_customized_acticap64.mat';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, task1, task2)

% Show in indivudual plots as well
% P3 - 41
% figure()
% plot(task1.time,task1.avg(str2num(p3_channel),:),'b');
% hold on
% plot(task2.time,task2.avg(str2num(p3_channel),:),'r');
% legend("1","2")
% title("P3 (41) channel ERP")
cfg = [];
cfg.channel = p3_channel;
ft_singleplotER(cfg,task1,task2)

% P4 - 9
% figure()
% plot(task1.time,task1.avg(str2num(p4_channel),:),'b');
% hold on
% plot(task2.time,task2.avg(str2num(p4_channel),:),'r');
% legend("1","2")
% title("P4 (9) channel ERP")
cfg = [];
cfg.channel = p4_channel;
ft_singleplotER(cfg,task1,task2)


% Topography plot in high diff erp Cz 
% finding the time in which the ERP Cz diff is maximum
Cz_channel = '30';
% Calculating difference
cfg = [];
cfg.operation = 'subtract';
cfg.parameter = 'avg';
difference = ft_math(cfg, task1, task2);

cfg = [];
cfg.operation = 'abs';
cfg.parameter = 'avg';
absdifference = ft_math(cfg, difference);

[m,I] = max(absdifference.avg(str2num(Cz_channel)-1,:));

cfg = [];
cfg.channel = Cz_channel;
ft_singleplotER(cfg,absdifference)
hold on
scatter(task1.time(I),m,'or')
load mpi_customized_acticap64.mat

cfg = [];
cfg.layout = lay;
cfg.xlim = [task1.time(I) task1.time(I)]; 
ft_topoplotER(cfg,task1)

cfg = [];
cfg.layout = lay;
cfg.xlim = [task2.time(I) task2.time(I)]; 
ft_topoplotER(cfg,task2)









