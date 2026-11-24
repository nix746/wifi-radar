function H = interpolate_dc_nulls(H, dc_indices)
% INTERPOLATE_DC_NULLS Linearly interpolates contiguous internal DC null gaps across subcarriers.
%
% Inputs:
%   H          - Centered channel transfer matrix [Nfft x n_symbols]
%   dc_indices - Indices of internal DC null subcarriers in centered domain
%
% Output:
%   H          - Channel matrix with DC null gaps linearly interpolated

    dc = sort(dc_indices(:).');
    if isempty(dc)
        return;
    end

    gap_starts = [dc(1), dc(find(diff(dc) > 1) + 1)];
    gap_ends   = [dc(diff(dc) > 1), dc(end)];

    for g = 1:numel(gap_starts)
        idx_gap   = gap_starts(g) : gap_ends(g);
        idx_left  = idx_gap(1) - 1;
        idx_right = idx_gap(end) + 1;

        weights = (1:numel(idx_gap)).' / (numel(idx_gap) + 1);
        H(idx_gap, :) = H(idx_left, :) + ...
            weights .* (H(idx_right, :) - H(idx_left, :));
    end
end
