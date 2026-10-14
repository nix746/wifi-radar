function [fc, band_str] = get_carrier_frequency(band_input)
% GET_CARRIER_FREQUENCY Resolves carrier frequency in Hz from band name or numeric frequency.
%
% Inputs:
%   band_input - String ('2.4GHz', '5GHz', '6GHz') or numeric frequency in Hz
%
% Outputs:
%   fc       - Carrier frequency in Hz
%   band_str - Standardized band name ('2.4GHz', '5GHz', '6GHz', or 'Custom')

    if nargin < 1 || isempty(band_input)
        band_input = '5GHz';
    end

    if isnumeric(band_input)
        fc = double(band_input);
        if fc < 3e9
            band_str = '2.4GHz';
        elseif fc < 5.9e9
            band_str = '5GHz';
        elseif fc < 7.2e9
            band_str = '6GHz';
        else
            band_str = 'Custom';
        end
    elseif ischar(band_input) || isstring(band_input)
        str = upper(strtrim(char(band_input)));
        switch str
            case {'2.4GHZ', '2.4G', '2.4', '2G', 'ISM'}
                fc = 2.437e9; % Wi-Fi Channel 6 (center of 2.4 GHz band)
                band_str = '2.4GHz';
            case {'5GHZ', '5G', '5'}
                fc = 5.500e9; % Wi-Fi Channel 100 (center of UNII-2 Extended / DFS)
                band_str = '5GHz';
            case {'6GHZ', '6G', '6', 'WIFI6E', 'WIFI 6E'}
                fc = 6.200e9; % Wi-Fi 6E Channel 50 (UNII-5 band)
                band_str = '6GHz';
            otherwise
                % Attempt numeric parsing if string contains digits
                val = str2double(strrep(str, 'GHZ', 'e9'));
                if ~isnan(val) && val > 0
                    [fc, band_str] = get_carrier_frequency(val);
                else
                    error('Unknown band input ''%s''. Valid options: ''2.4GHz'', ''5GHz'', ''6GHz'' or numeric Hz.', band_input);
                end
        end
    else
        error('Invalid input type for carrier band.');
    end
end
