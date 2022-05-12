function varargout = Awiszus(action,varargin)

if strcmpi(action,'init')
    
    P                           = varargin{1}; % Awiszus (and other) parameters
    stimType                    = varargin{2};
    P.awiszus.dist(stimType,:)  = normpdf(P.awiszus.X,P.awiszus.mu(stimType),P.awiszus.sd(stimType));
    varargout{1}                = P;
    
elseif strcmpi(action,'update')
    
    P           = varargin{1};
    response    = varargin{2};
    stimType    = varargin{3};
    
    % derive normal cumulative distribution
    if response==0
        likeli = normcdf(P.awiszus.X,P.awiszus.nextX(stimType),P.awiszus.sp(stimType));  % tekelili
    elseif response==1
        likeli = normcdf(P.awiszus.X,P.awiszus.nextX(stimType),P.awiszus.sp(stimType))*-1+1; % invert
    else
        error('Response must be binary.');
    end
    P.awiszus.dist(stimType,:) = (P.awiszus.dist(stimType,:)).*likeli;
    
    k=0;
    postCDF=[];
    for ii = 1:size(P.awiszus.dist(stimType,:),2)
        k = k+P.awiszus.dist(stimType,ii)/100;
        postCDF = [postCDF,k]; %#ok<AGROW>
    end
    P.awiszus.nextX(stimType) = P.awiszus.X(find(postCDF>0.5*postCDF(end),1,'first'));
    
    varargout{1} = P;
    
    %     elseif strcmpi(action,'visualdemo')
    %
    %         [varargout{1}] = AwiszusVisualDemo(varargin{1},varargin{2:end});
    
end

end