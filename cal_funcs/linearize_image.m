
function img_gc = linearize_image(img,gammaTable)
% extension of linearizeOutput to deal with full images

double = 0;
if max(img(:))<=1
    double = 1;
    img = img.*255;
end

img_gc = zeros(size(img));
for ii = 1:size(img,1)
    for jj = 1:size(img,2)
        for kk = 1:size(img,3)
            img_gc(ii,jj,kk) = gammaTable(round(img(ii,jj,kk)) + 1,min(kk,size(gammaTable,2)));
        end
    end
end

if ~double
    img_gc = uint8(255.*img_gc);
end

end