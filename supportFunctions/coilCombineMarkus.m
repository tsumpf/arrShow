function A_out = coilCombineMarkus(A, dim)

si  = size(A);
order = 1:length(si);
order(dim)  = 3;
C           = si(dim);
order(3)    = dim;
permutsi    = si(order);
A = permute(A,order);
A = reshape(A, si(1), si(2), si(dim), []);

% Get image dimensions and set filter size
filtsize    = 7;
filter_ones = ones(filtsize);
A_out       = zeros([si(1:2), size(A,4)]);

for i=1:size(A,4)
    tmp1    = A(:,:,:,i);
    ctmp1   = conj(tmp1);
    tmp2    = zeros(si(1), si(2));
    Rs = zeros(si(1),si(2),C,C);
    % Get correlation matrices
    for kc1=1:C
        for kc2=1:C
            Rs(:,:,kc1,kc2) = Rs(:,:,kc1,kc2) + filter2(filter_ones, ...
                tmp1(:,:,kc1) .* ctmp1(:,:,kc2), 'same');
        end
    end
    % Compute and apply filter at each voxel
    for kx=1:si(1)
        for ky=1:si(2)
            % Change suggested by Mark Bydder
            [U,~]   = svd(squeeze(Rs(kx,ky,:,:)));
            myfilt  = U(:,1);
            tmp2(kx,ky) = myfilt'*squeeze(tmp1(kx,ky,:));
        end
    end
    A_out(:,:,i) = tmp2;
end

A_out = reshape(A_out, [permutsi(1), permutsi(2), 1, permutsi(4:end)]);
A_out = permute(A_out, order);
end



