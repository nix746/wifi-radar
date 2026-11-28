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
