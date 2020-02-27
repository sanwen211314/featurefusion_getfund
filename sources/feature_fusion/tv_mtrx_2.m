function Psi  = tv_mtrx_2(M,N,L)

ex          = ones(M,1);
ey          = ones(N,1);
ez          = ones(L,1);
diff_x      = spdiags([-ex ex], 0:1, M, M);
diff_y      = spdiags([-ey ey], 0:1, N, N);
diff_z      = spdiags([-ez ez], 0:1, L, L);
diff_x(M,:) = 0;
diff_y(N,:) = 0;
diff_z(L,:) = 0;
Dv_m        = kron(speye(N), sparse(diff_x))./sqrt(12);
Dv_m        = kron(speye(L), Dv_m);
Dh_m        = kron(sparse(diff_y), speye(M))./sqrt(12); 
Dh_m        = kron(speye(L), Dh_m);
Df_m        = kron(speye(N), speye(M))./sqrt(12); 
Df_m        = kron(sparse(diff_z), Df_m);
% Psi         = [Dv_m; Dh_m; Df_m];
Psi         = [Dv_m; Dh_m];