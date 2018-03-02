
function RGB = delinearizeOutput(RGB_gc,inv_gammaTable)
%   delinearizeOutput
%   this function can be used to delinearize an RGB triplet according to an
%   inverse gamma table
%
%   you might use this if your monitor applies automatic gamma correction
%   during viewing

if size(inv_gammaTable,2) == 3
    R = inv_gammaTable(round(RGB_gc(1)) + 1,1);
    G = inv_gammaTable(round(RGB_gc(2)) + 1,2);
    B = inv_gammaTable(round(RGB_gc(3)) + 1,3);
else
    R = inv_gammaTable(round(RGB_gc(1)) + 1);
    G = inv_gammaTable(round(RGB_gc(2)) + 1);
    B = inv_gammaTable(round(RGB_gc(3)) + 1);
end

RGB = 255.*[R G B];

end

