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

% Re-referencing options - see explanation above
cfg.implicitref   = 'LM';
cfg.reref         = 'yes';
cfg.refchannel    = {'LM' 'RM'};

data = ft_preprocessing(cfg);

cfg = [];  % use only default options
ft_databrowser(cfg, data);

cfg         = [];
cfg.dataset = 's04.vhdr';
ft_databrowser(cfg);