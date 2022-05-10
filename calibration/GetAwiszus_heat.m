function [P] = GetAwiszus_heat(P)

        P.time.threshStart=GetSecs;                

        painCFiles = cellstr(ls(P.out.dir));   
        painCFiles = painCFiles(contains(painCFiles,'calib_data'));
        
        if isempty(painCFiles)
            warning('Previous calibration data file not found. Crash out (Ctrl+C) or indicate custom threshold.');
            P.painCalibData.AwThr = input('Thresholding data not found. Please enter pain threshold (awTT).');
            P.painCalibData.notes{end+1} = 'Custom threshold (awTT)';
        else
            if numel(painCFiles)>1
                warning('Multiple calibration data files found. Proceeding with most recent one (%s).',cell2mat(painCFiles))
            end
            painCFiles = painCFiles(end);
            existP = load([P.out.dir cell2mat(painCFiles)]); % load existing parameters
            existP = existP.P;
            P.painCalibData.AwThrTemps = existP.painCalibData.AwThrTemps;
            P.painCalibData.AwThrResponses = existP.painCalibData.AwThrResponses;
            try
                P.painCalibData.AwThr = existP.painCalibData.AwThr;
            catch % for opening old log files
                P.painCalibData.AwThr = existP.painCalibData.ResThrAw;
            end
            P.painCalibData.notes{end+1} = sprintf('Thresholding data imported from %s',[P.out.dir cell2mat(painCFiles)]);
        end

        P.time.threshEnd=GetSecs; 
 
    end