Per_search          = Per_F;
Per_search(~B)      = -inf;
[peak_val, lin_idx] = max(Per_search(:));

dn = abs(n_grid - n_hat);
dn = min(dn, N_Per - dn);
dm_dist = abs(m_grid - m_hat);
dm_dist = min(dm_dist, M_Per - dm_dist);
in_ellipse    = (dn / (N_win / 2)).^2 + (dm_dist / (M_win / 2)).^2 <= 1;
B(in_ellipse) = false;
