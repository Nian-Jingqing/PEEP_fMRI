function [P,O] = get_calib_data(P,O)
% Get the calibration data for PEEP exp

P.path.calib =  fullfile(P.path.experiment,'Data','LogCalibration',P.project.part,['sub' sprintf('%03d',P.protocol.subID)]);
pain_c_dir = dir(fullfile(P.path.calib,'*parameters*.mat'));

%if ~P.test
    if isempty(pain_c_dir)
                error('Calibration data file not found in %s. Aborting.',P.path.calib);
    elseif length(pain_c_dir)>1
        c_file = pain_c_dir(end).name;
        warning('Multiple calibration data files found. Proceeding with most recent one (%s).',c_file)
        calib_data = load(fullfile(P.path.calib,c_file)); % load existing parameters
        P.pain.calib_data = calib_data;
    else
        c_file = pain_c_dir.name;
        calib_data = load(fullfile(P.path.calib,c_file)); % load existing parameters
        P.pain.calib_data = calib_data;
    end

% else
%     if isempty(pain_c_dir)
%                 % use default values (only in test trials)
%                 P.pain.calib_data  = [];
%     elseif length(pain_c_dir)>1
%         c_file = pain_c_dir(end).name;
%         warning('Multiple calibration data files found. Proceeding with most recent one (%s).',c_file)
%         calib_data = load(fullfile(P.path.calib,c_file)); % load existing parameters
%         P.pain.calib_data = calib_data.P.painCalibData;
%     else
%         c_file = pain_c_dir.name;
%         calib_data = load(fullfile(P.path.calib,c_file)); % load existing parameters
%         P.pain.calib_data = calib_data.P.painCalibData;
%     end
% end


end