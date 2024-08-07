% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function opt = getOptionSearchlight()
  % returns a structure that contains the options chosen by the user to run
  % searchlight.

  if nargin < 1
    opt = [];
  end

  % group of subjects to analyze
  opt.groups = {''};
  % suject to run in each group
  opt.subjects = { 'ctrl009'}; 
               % , 'ctrl011',  ...

  % Uncomment the lines below to run preprocessing
  % - don't use realign and unwarp
  opt.realign.useUnwarp = true;

  % we stay in native space (that of the T1)
  opt.space = 'MNI'; % 'individual', 'MNI'

  % The directory where the data are located
  opt.dataDir = fullfile(fileparts(mfilename('fullpath')), ...
                           '..', '..', '..',  'raw');
  opt.derivativesDir = fullfile(opt.dataDir, '..', 'derivatives', 'cpp-spm');

  % task to analyze
%   opt.taskName = 'mototopy';
  opt.taskName = 'somatotopy';

 
  % Suffix output directory for the saved jobs
  opt.jobsDir = fullfile( ...
                           opt.dataDir, '..', 'derivatives', ...
                           'cpp_spm', 'JOBS', opt.taskName);
                       
  opt.pathOutput = fullfile(opt.dataDir, '..', 'derivatives', 'cosmoMvpa', ...
                            'Searchlight', 'raw');

  opt.pathInput = fullfile(opt.dataDir, '..', 'derivatives', 'cosmoMvpa', ...
                            'Searchlight', 'derivatives');                     
    % multivariate
  opt.model.file = fullfile(fileparts(mfilename('fullpath')), '..', ...
                            'model', ...
                            ['model-', opt.taskName,'_audCueParts_smdl.json']);


  opt.parallelize.do = false;
  opt.parallelize.nbWorkers = 1;
  opt.parallelize.killOnExit = true;

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);
  % we cannot save opt with opt.mvpa, it crashes

  %% mvpa options

  % define the 4D maps to be used
  opt.funcFWHM = 2;

  % Define a neighborhood with approximately 100 voxels in each searchlight.
  opt.mvpa.searchlightVoxelNb = 3; % 100 150 'count', or 3 - 5 with 'radius'
  opt.mvpa.sphereType = 'radius'; % 'radius' or 'count'

  % set which type of ffx results you want to use
  opt.mvpa.map4D = {'t_maps'}; %'beta', 

  % whole brain or another mask?
  opt.mvpa.roiSource = 'wholeBrain';

  % design info
  opt.mvpa.nbRun = 6; %6 for moto, 12 for somato 
  if strcmp(opt.taskName, 'somatotopy')
     opt.mvpa.nbRun = 12; 
  end
  
  opt.mvpa.nbTrialRepetition = 1;

  % cosmo options
  opt.mvpa.tool = 'cosmo';

  % Use the cosmo_cross_validation_measure and set its parameters
  % (classifier and partitions) in a measure_args struct.
  opt.mvpa.measure = @cosmo_crossvalidation_measure;

  % Define which classifier to use, using a function handle.
  % Alternatives are @cosmo_classify_{svm,matlabsvm,libsvm,nn,naive_bayes, lda}
  opt.mvpa.classifier = @cosmo_classify_lda;
  opt.mvpa.className = 'lda';

end
