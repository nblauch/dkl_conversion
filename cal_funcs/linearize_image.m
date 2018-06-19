
function img_gc = linearize_image(img,gammaTable)
%perform gamma correction of an input img (can be number, vector, matrix, or image)
%smallest non-singleton dim must be 3
%if an inverse gammatable is provided, this function can also perform
%delinearization of gamma-corrected inputs.
%
%NOTES
%    4/19/18 nmb: edited to properly deal with input of dim 1,2,3

% if ndims(img)~=3 || size(img,3)~=3
%     error('Input must be an image of size MxNx3. For a vector, use linearizeOutput');
% end

double = 0;
if max(img(:))<=1
    double = 1;
    img = img.*255;
end

img_gc = zeros(size(img));
non_sing_dims = length(find(size(img)>1));

if non_sing_dims>1
    if non_sing_dims>3
        error('Wrong size input. ndims(img) must be <=3 and smallest non-singleton dim length must be 3')
%     elseif min(size(img))~=3
%         error('Wrong size input. ndims(img) must be <=3 and smallest non-singleton dim length must be 3')
    end
elseif non_sing_dims==1
    if max(size(img))~=3
        if length(find(size(gammaTable)>1)) >1
            error('Wrong size gammaTable. For a vector of grayscale values, you must input an Nx1 gammaTable')
        end
    end
elseif non_sing_dims==0
    if length(find(size(gammaTable)>1)) > 1
        error('Wrong size gammaTable. For a single input, you must input an Nx1 gammaTable')
    end
end

switch non_sing_dims
    case 0
        img_gc = gammaTable(round(img) + 1);
    case 1
        for ii = 1:length(img)
            if length(img)==3
                img_gc(ii) = gammaTable(round(img(ii)) + 1,min(ii,size(gammaTable,2)));
            else
                img_gc(ii) = gammaTable(round(img(ii)) + 1);
            end
        end
    case 2
        for ii = 1:size(img,1)
            for jj = 1:size(img,2)
                    img_gc(ii,jj) = gammaTable(round(img(ii,jj)) + 1,min(jj,size(gammaTable,2)));
            end
        end
    case 3
        for ii = 1:size(img,1)
            for jj = 1:size(img,2)
                for kk = 1:size(img,3)
                    img_gc(ii,jj,kk) = gammaTable(round(img(ii,jj,kk)) + 1,min(kk,size(gammaTable,2)));
                end
            end
        end
end

if ~double
    img_gc = uint8(255.*img_gc);
end

end