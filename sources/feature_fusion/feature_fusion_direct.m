function [fused_features] = feature_fusion_direct(shot_patt_HS,shot_patt_MS,filter_pattHS,filter_pattMS,q,p,lambda1,lambda2,dictionary,alg_parameters)

[Mh,Nh,shots_hs] = size(shot_patt_HS);
[M,N,shots_ms] = size(shot_patt_MS);

indicesHS = zeros(Nh*Mh*p*p*shots_hs,2);
k = 1;
for i = 0:shots_hs-1
    r = filter_pattHS(:,:,i+1);
    r = r(:);
    for u = 0 : Mh*Nh - 1
        for v = 0 : p-1
            for w = 0 : p-1
                indicesHS(k,1) = u + Mh*Nh*i + 1;
                indicesHS(k,2) = floor(u/Mh)*M*p + rem(u,Mh)*p + w + v*M + (r(u+1)-1)*M*N + 1;
%                 if (u < 12)
%                     [u r(u+1) indicesHS(k,:) k floor(u/Mh) rem(u,Mh)]
%                 end
                k = k+1;
            end
        end
    end
end
A1=sparse(indicesHS(:,1),indicesHS(:,2),1,Mh*Nh*shots_hs,M*N*shots_hs);

indicesMS = zeros(M*N*q*shots_ms,2);
k=1;
for i = 0 : shots_ms-1
    r = filter_pattMS(:,:,i+1);
    r = r(:);
    for u = 0 : M*N-1
        for v = 0 : q-1
            indicesMS(k,1) = u + M*N*i + 1;
            indicesMS(k,2) = u + ((r(u+1)-1)*q + v)*M*N + 1;
            k=k+1;
        end
    end
end
A2=sparse(indicesMS(:,1),indicesMS(:,2),1,M*N*shots_ms,M*N*shots_hs);

H       = [A1; A2];

if strcmp(dictionary,'wav2_dct1')
    B   = wav2_dct1(M, N, shots_hs);
elseif strcmp(dictionary,'dct2_dct1')
    B   = dct2_dct1(M, N, shots_hs);
end
Lo      = tv_mtrx_2(M, N, shots_hs);
val     = powr_mthd(H, [M*N*shots_hs 1], 1e-6, 100, 0);
H       = H./sqrt(val);
y       = [shot_patt_HS(:); shot_patt_MS(:)] / norm([shot_patt_HS(:); shot_patt_MS(:)]);

Irec        = linz_admm_L1TV(H, B', Lo, y, lambda2, lambda1*norm(B*(H'*y),inf), alg_parameters, zeros(M,N,shots_hs));

Irec_fuse   = reshape(Irec, M, N, shots_hs);
fused_features = reshape(Irec_fuse, [M*N shots_hs])';
end

