function [cartoonImg] = cartoon(I)
    thresholdVal = 1; %intensity difference
    r_id = 0.3; %relative intensity difference before img is total black

    r = I(:,:,1); %r is all rows and columns in the first image plane, the red channel of I
    g = I(:,:,2); %g is all rows and columns in the second image plane, the green channel of I
    b = I(:,:,3); %b is all rows and columns in the third image plane, the blue channel of I
    rc = cartoon_img(r,thresholdVal,r_id); %convert the red channel of I to cartoon 
    gc = cartoon_img(g,thresholdVal,r_id); %convert the green channel of I to cartoon
    bc = cartoon_img(b,thresholdVal,r_id); %convert the blue channel of I to cartoon
    cartoonImg = cat(3,rc,gc,bc); %concatenate rr, gr and br along the third dimension to create cartoon img
    

    function c_img = cartoon_img(I,thresholdVal,r_id) %function to create cartoon img
        I = im2double(I); %convert img to double to avoid overflow
        g_new = imgaussfilt(I,5); %apply the gaussian filter to the double img with standard deviation, sigma, given as 5 to obtain a blurred or smoothed img
        g_new = I./g_new; %divide I by the smoothed img to get a new img with coloured edges
        intmult = (r_id - min(r_id,(thresholdVal-g_new)))/r_id; %the intenisty mult is calculated
        ind = find(g_new < thresholdVal); %find the indices in g_new where the thresholdVal is greater than the values in g_new
        c_img = I; %create the cartoon img with dimensions and values the same as img im
        c_img(ind) = I(ind).*intmult(ind); %at the indices, found earlier, in the cartoon img, set it to im(ind).*mult(ind), to create the final c_img
    end
    %output results, original img next to cartoon img
    subplot(1,2,1);imshow(I);title('Original image');
    subplot(1,2,2);imshow(cartoonImg);title('Cartoon image of orginal image');
end