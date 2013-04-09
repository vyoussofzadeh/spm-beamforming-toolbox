function res = bf_inverse_dics(BF, S)
% Computes DICS filters
% Copyright (C) 2013 Wellcome Trust Centre for Neuroimaging

% Vladimir Litvak
% $Id$

%--------------------------------------------------------------------------
if nargin == 0  
     
    fixedori = cfg_menu;
    fixedori.tag = 'fixedori';
    fixedori.name = 'Optimise for maximal power';
    fixedori.labels = {'Yes', 'No'};
    fixedori.val = {'yes'};
    fixedori.values = {'yes', 'no'};
    fixedori.help = {'Optimise dipole orientation for maximal power'};    
    
    dics      = cfg_branch;
    dics.tag  = 'dics';
    dics.name = 'DICS';
    dics.val  = {fixedori};
    
    res = dics;
    
    return
elseif nargin < 2
    error('Two input arguments are required');
end

modalities = {'MEG', 'EEG'};


for m = 1:numel(modalities)
    if isfield(BF.features, modalities{m})
        C    = BF.features.(modalities{m}).C;
        Cinv = BF.features.(modalities{m}).Cinv;
        
        U    = BF.features.(modalities{m}).U;

        
        L = BF.sources.L.(modalities{m});
        
        W = cell(size(L));
        
        nvert = numel(W);
        
        spm('Pointer', 'Watch');drawnow;
        spm_progress_bar('Init', nvert, ['Computing ' modalities{m} ' filters']); drawnow;
        if nvert > 100, Ibar = floor(linspace(1, nvert,100));
        else Ibar = 1:nvert; end
        
        for i = 1:nvert
            if ~isnan(L{i})
                lf    = U'*L{i};    
                
                if size(lf, 2) == 1
                    S.fixedori = 'no';
                end                
                                
                estimate = ft_inverse_beamformer_dics(lf, C, 'invCf', Cinv,...
                    'fixedori', S.fixedori, 'filteronly', 'yes', 'projectnoise', 'no', ...
                    'keepfilter', 'yes', 'keepleadfield', 'no', 'keepcsd', 'no', 'feedback', 'none');
  
                 W(i) = estimate.filter;
            else
                W{i} = NaN;
            end
            
             if ismember(i, Ibar)
                spm_progress_bar('Set', i); drawnow;
            end
        end
        
        
        spm_progress_bar('Clear');
        inverse.W.(modalities{m}) = W;
    end
end

res = inverse;