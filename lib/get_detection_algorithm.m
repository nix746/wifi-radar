function alg = get_detection_algorithm(method)
% GET_DETECTION_ALGORITHM Single source of truth for radar detection algorithms.
% Resolves algorithm identifiers, display names, Polish descriptions, default
% selection, and execution handlers in one centralized place.
%
% Input:
%   method - (Optional) Algorithm ID ('binary', 'coherent'), empty/missing for
%            the default algorithm, or an existing algorithm config struct.
%
% Output:
%   alg    - Struct with fields:
%            id, name, full_name, description_pl, is_default, run

DEFAULT_METHOD    = 'binary';
SUPPORTED_METHODS = {'binary', 'coherent'};

if nargin < 1 || isempty(method)
    method_id = DEFAULT_METHOD;
elseif isstruct(method) && isfield(method, 'id')
    alg = get_detection_algorithm(method.id);
    return;
elseif isstring(method) && isscalar(method) && ismissing(method)
    method_id = DEFAULT_METHOD;
elseif ischar(method) || (isstring(method) && isscalar(method))
    method_id = lower(strtrim(char(method)));
    if isempty(method_id)
        method_id = DEFAULT_METHOD;
    end
else
    error('Invalid detection algorithm specification. Expected a method name (%s), config struct, or empty.', ...
        strjoin(SUPPORTED_METHODS, ', '));
end

switch method_id
    case 'binary'
        alg = struct( ...
            'id',             'binary', ...
            'name',           'Binary STC', ...
            'full_name',      'Binary Successive Target Cancellation', ...
            'description_pl', 'maskowanie binarne', ...
            'is_default',     strcmp('binary', DEFAULT_METHOD), ...
            'run',            @run_binary_stc);

    case 'coherent'
        alg = struct( ...
            'id',             'coherent', ...
            'name',           'Coherent STC', ...
            'full_name',      'Coherent Successive Target Cancellation', ...
            'description_pl', 'odejmowanie koherentne', ...
            'is_default',     strcmp('coherent', DEFAULT_METHOD), ...
            'run',            @run_coherent_stc);

    otherwise
        error('Unsupported detection algorithm ''%s''. Supported options: %s.', ...
            method_id, strjoin(SUPPORTED_METHODS, ', '));
end
end

function [targets, CPer_F, Per_F, eta, diag_info] = run_binary_stc(radar_data, fs, fc, p_FA, p_rx_dBm, save_history)
% RUN_BINARY_STC Execute Binary STC and apply binary cancellation mask to CPer_F.
if nargin < 5 || isempty(p_rx_dBm), p_rx_dBm = -50.0; end
if nargin < 6 || isempty(save_history), save_history = true; end
k_pri = 1;
if isfield(radar_data, 'k_pri') && ~isempty(radar_data.k_pri)
    k_pri = radar_data.k_pri;
end
[targets, B, Per_F, eta, diag_info] = binary_successive_target_cancellation( ...
    radar_data.Per_F, radar_data.W, radar_data.N_act, radar_data.n_symbols, ...
    radar_data.Nfft, radar_data.Ncp, fs, fc, p_FA, p_rx_dBm, k_pri, save_history);
CPer_F = radar_data.CPer_F .* B;
end

function [targets, CPer_F, Per_F, eta, diag_info] = run_coherent_stc(radar_data, fs, fc, p_FA, p_rx_dBm, save_history)
% RUN_COHERENT_STC Execute Coherent STC on complex and real periodograms.
if nargin < 5 || isempty(p_rx_dBm), p_rx_dBm = -50.0; end
if nargin < 6 || isempty(save_history), save_history = true; end
k_pri = 1;
if isfield(radar_data, 'k_pri') && ~isempty(radar_data.k_pri)
    k_pri = radar_data.k_pri;
end
[targets, CPer_F, Per_F, eta, diag_info] = coherent_successive_target_cancellation( ...
    radar_data.CPer_F, radar_data.Per_F, radar_data.W, radar_data.N_act, radar_data.n_symbols, ...
    radar_data.Nfft, radar_data.Ncp, fs, fc, p_FA, p_rx_dBm, k_pri, true, save_history);
end
