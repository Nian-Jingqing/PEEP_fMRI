% This function integrates consecutively entered distributions in a quasi-Bayesian fashion.
% It was built for heat pain threshold determination, but will merrily process other input.
% See subfunctions EXAMPLE_CALLER for guidance on how to call it, and EXAMPLE_CALLER_VISUALDEMO 
% for a rough graphical demonstration of how it works.
%
% P = Awiszus('init',P); 
% This generates a starting distribution (actually the prior) for use in later iterations.
% Expects a P struct with parameters defined substruct P.awiszus
%
% [awPost,awNextX] = Awiszus('update',awP,awPost,awNextX,awResponse);
% P = Awiszus('update',awP,awPost,awNextX,awResponse);
% Responses are expected to be binary. In our original usage, we were judging stimuli to be
% painful (1) or not (0). .dist is actually the old prior, which is updated to become
% the returned .dist.
%
% Version: 1.1
% Author: Bjoern Horing, University Medical Center Hamburg-Eppendorf
% including code developed by Christian Sprenger, and conceptual work by Friedemann Awiszus,
% TMS and threshold hunting, Awiszus et al.(2003), Suppl Clin Neurophysiol. 2003;56:13-23.
% Date: 2020-07-16
%
% Version notes
% 1.0 2019-06-07
% - [extracted from calibration script]
% 1.1 2020-07-16
% - restructured to utilize P struct

function varargout = Awiszus(action,varargin)

    if strcmpi(action,'init')
        
        P               = varargin{1}; % Awiszus (and other) parameters    
        P.awiszus.thermoino.dist  = normpdf(P.awiszus.thermoino.X,P.awiszus.thermoino.mu,P.awiszus.thermoino.sd); 
        varargout{1}    = P;
        
    elseif strcmpi(action,'update')
        
        P           = varargin{1};
        response    = varargin{2};

        % derive normal cumulative distribution 
        if response==0
            likeli = normcdf(P.awiszus.thermoino.X,P.awiszus.thermoino.nextX,P.awiszus.thermoino.sp);  % tekelili
        elseif response==1
            likeli = normcdf(P.awiszus.thermoino.X,P.awiszus.thermoino.nextX,P.awiszus.thermoino.sp)*-1+1; % invert
        else
            error('Response must be binary.');
        end
        P.awiszus.thermoino.dist = (P.awiszus.thermoino.dist).*likeli; 

        k=0; 
        postCDF=[];
        for ii = 1:size(P.awiszus.thermoino.dist,2)
            k = k+P.awiszus.thermoino.dist(ii)/100; 
            postCDF = [postCDF,k];
        end
        P.awiszus.thermoino.nextX = P.awiszus.thermoino.X(find(postCDF>0.5*postCDF(end),1,'first'));

        varargout{1} = P;

    elseif strcmpi(action,'visualdemo')
        
        [varargout{1}] = AwiszusVisualDemo(varargin{1},varargin{2:end});

    end
    
    
function EXAMPLE_CALLER % highlight and execute code as is; not accessible using an action via Awiszus()

    P.awiszus.thermoino.N   = 8; % number of trials
    P.awiszus.thermoino.X   = 41.0:0.01:47.0;  % X to be covered, e.g. temperature range (°C) 
    P.awiszus.thermoino.mu  = 43.0; % assumed population mean (also become first stimulus to be tested)
    P.awiszus.thermoino.sd  = 1.2; % assumed population std
    P.awiszus.thermoino.sp  = 0.4; % assumed individual spread

	P = Awiszus('init',P); 

    P.awiszus.thermoino.nextX = P.awiszus.thermoino.mu; % start with assumed population mean
    for nTrial = 1:P.awiszus.thermoino.N
        P.awiszus.thermoino.nextX = round(P.awiszus.thermoino.nextX,1); % al gusto
        fprintf('Applying stim %1.1f... ',P.awiszus.thermoino.nextX);
        % painful = BinaryRating(awNextX); % this should be your stimulus delivery function
        painful = round(rand); % REPLACE WITH YOUR DELIVERY/RATING FUNCTION
        fprintf('rated %d.\n',painful);
        P = Awiszus('update',P,painful);          
    end   
    
    
function EXAMPLE_CALLER_VISUALDEMO % highlight and execute code as is; not accessible using an action via Awiszus()

    P = struct;
    P.awiszus.thermoino.N   = 8; % number of trials
    P.awiszus.thermoino.X   = 41.0:0.01:47.0;  % X to be covered, e.g. temperature range (°C) 
    P.awiszus.thermoino.mu  = 43.0; % assumed population mean (also become first stimulus to be tested)
    P.awiszus.thermoino.sd  = 1.2; % assumed population std
    P.awiszus.thermoino.sp  = 0.4; % assumed individual spread

    P = Awiszus('visualdemo','init',P); 

    P.awiszus.thermoino.nextX = P.awiszus.thermoino.mu; % start with assumed population mean
    for nTrial = 1:P.awiszus.thermoino.N
        P.awiszus.thermoino.nextX = round(P.awiszus.thermoino.nextX,1); % al gusto
        fprintf('Applying stim %1.1f... ',P.awiszus.thermoino.nextX);
        % awResponse = BinaryRating(awNextX); % this should be your stimulus delivery function
        painful = round(rand); % REPLACE WITH YOUR DELIVERY/RATING FUNCTION
        fprintf('rated %d.\n',painful);
        P = Awiszus('visualdemo','update',P,painful); 
        commandwindow;
        pause;        
    end   
    
  
% DEPRECATED; this fully replicates the main function, but with some clutter for adding visual output;
% probably informative only once
function varargout = AwiszusVisualDemo(action,varargin)

    if strcmpi(action,'init')
        
        P         = varargin{1}; % Awiszus parameters    
        P.awiszus.thermoino.dist       = normpdf(P.awiszus.thermoino.X,P.awiszus.thermoino.mu,P.awiszus.thermoino.sd); 

        P.awiszus.thermoino.H = figure; 
        plot(P.awiszus.thermoino.X,P.awiszus.thermoino.dist); 
        hold on
        drawnow;    

        varargout{1}    = P;
        
    elseif strcmpi(action,'update')
        
        P         = varargin{1};
        response    = varargin{2};
        
        if ~ishandle(P.awiszus.thermoino.H)
            error('Figure handle expected for visual demo.');
        end
        
        % derive normal cumulative distribution 
        if response==0
            likeli = normcdf(P.awiszus.thermoino.X,P.awiszus.thermoino.nextX,P.awiszus.thermoino.sp);  % tekelili
        elseif response==1
            likeli = normcdf(P.awiszus.thermoino.X,P.awiszus.thermoino.nextX,P.awiszus.thermoino.sp)*-1+1; % invert
        else
            error('Response must be binary.');
        end
        P.awiszus.thermoino.dist = P.awiszus.thermoino.dist.*likeli; 
     
        figure(P.awiszus.thermoino.H);
        plot(P.awiszus.thermoino.X,P.awiszus.thermoino.dist);
        plot(P.awiszus.thermoino.X,likeli);
        drawnow;

        k=0; 
        postCDF=[];
        for ii = 1:size(P.awiszus.thermoino.dist,2)
            k = k+P.awiszus.thermoino.dist(ii)/100; 
            postCDF = [postCDF,k];
        end
        P.awiszus.thermoino.nextX = P.awiszus.thermoino.X(find(postCDF>0.5*postCDF(end),1,'first'));

        varargout{1} = P;

    end    
