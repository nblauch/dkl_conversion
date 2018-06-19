
function RGB = linearizeOutput(RGB,gammaTable)
%RGB is the vector of RGB triplets on 0:255 which need to be linearized
%gammaTable is a 256x1 lookup table for transformations
%gammaTable may also be a 256x3 lookup table for gamma correction of
%individual phosphors for accurate color space 

if ndims(RGB)~=2 || size(RGB,2)~=3
    error('Input must be size Mx3. For an image, use linearize_image');
end

double = 0;
if max(RGB)<=1
    double = 1;
    RGB = RGB.*255;
end

if size(gammaTable,2) == 3
    R = gammaTable(round(RGB(1)) + 1,1);
    G = gammaTable(round(RGB(2)) + 1,2);
    B = gammaTable(round(RGB(3)) + 1,3);
else
    R = gammaTable(round(RGB(1)) + 1);
    G = gammaTable(round(RGB(2)) + 1);
    B = gammaTable(round(RGB(3)) + 1);
end

RGB = [R G B];

if ~double
    RGB = 255.*RGB;
end

end

