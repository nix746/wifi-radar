function p = get_tgax_propagation_params(model)
% GET_TGAX_PROPAGATION_PARAMS Returns IEEE 802.11 TGn/TGax dual-slope path loss parameters.
% Based on V. Erceg et al., "TGn Channel Models", IEEE 802.11-03/940r4 (May 2004),
% adopted by IEEE 802.11ax (TGax).
%
% Inputs:
%   model - TGax delay profile string: 'Model-A'..'Model-F' (or 'A'..'F')
%
% Output:
%   p     - Struct with fields:
%             * model  : Normalized model name ('MODEL-A'..'MODEL-F')
%             * d_bp   : Breakpoint distance [m] (LoS -> NLOS transition)
%             * n_los  : Path loss exponent for R <= d_bp (2.0, free space)
%             * n_nlos : Path loss exponent for R > d_bp (3.5, obstructed)

    if nargin < 1 || isempty(model)
        model = 'Model-A';
    end

    model = upper(strtrim(char(model)));
    if ~startsWith(model, 'MODEL-')
        model = ['MODEL-' model];
    end

    p = struct('model', model, 'd_bp', 5.0, 'n_los', 2.0, 'n_nlos', 3.5);

    switch model
        case {'MODEL-A', 'MODEL-B', 'MODEL-C'}
            p.d_bp = 5.0;
        case 'MODEL-D'
            p.d_bp = 10.0;
        case 'MODEL-E'
            p.d_bp = 20.0;
        case 'MODEL-F'
            p.d_bp = 30.0;
        otherwise
            error('Unsupported TGax propagation model ''%s''. Expected Model-A through Model-F.', model);
    end
end
