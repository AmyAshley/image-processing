function [] = MultiEffects(i)
    function [r] = ColourBlend(front,back) %function to blend two imgs
        i_new = front*255./(255-back);  %divide the bottom layer of img by the inverted top layer
        i_new(i_new > 255) = 255; %find where i_new > 255 in i_new and set those pixel vals to 255;
        i_new(back == 255) = 255; %find where back img = 255 in i_new and set those pixel vals to 255;
        r = im2uint8(i_new); %resultant img is then converted to uint8 
    end
    function [i_new] = Thermal(i) %function to turn rgb images to thermal images
        map = hsv(256); %thermal colour map 
        bw = rgb2gray(i); %turn rgb img to grayscale
        contrast = imadjust(bw); %perform contrast stretching on the grayscale img
        i_new = ind2rgb(contrast,map); %convert contrast img to thermal img
    end
    function [i_new] = OldenDay(i) %function to turn rgb images to olden day polaroids
        map = pink(256); %create pink colour map, to closely resemble the wornout colours of an old img
        bw = rgb2gray(i); %convert rgb img to grayscale img
        border = 15; %create a borders of 15pt for all 4 edges of the img, to make it look like a polaroid
        bw(1:border,:,:) = 256;
        bw(end - border + 1:end,:,:) = 256;
        bw(:,1:border,:) = 256;
        bw(:,end-border+1:end,:) = 256;
        noise = imnoise(bw,'poisson'); %create a grainy noise, Poisson noise to make the img look old
        i_new = ind2rgb(noise, map); %apply the colourmap onto the img to give it that olden day effect
    end
    function [contrast] = charcoal(i) %function to turn rgb imgs to a charcoal like img
        gray = rgb2gray(i); %convert rgb img to grayscale
        inverted = 255 - gray; %invert the img to get the X-ray effect
        blur = imgaussfilt(inverted,5); %blur the img using the gaussian filter with sigma = 5
        d = ColourBlend(blur,gray); %apply the colorblend function to blend the blurred and inverted imgs 
        contrast = imadjust(d); %perform contrast stretching to give the effect an enhanced charcoal painting
    end
    function [inverted] = XRay(i) %function to turn rgb imgs to an X-ray img
        gray = rgb2gray(i); %convert rgb img to grayscale
        inverted = 255 - gray; %invert the img to get the X-ray effect
    end
    function [k] = RotateImfuse(i) %function to rotate an rgb img and overlay it with the orignal img with color effect
        j = imrotate(i,5,'bicubic','crop'); %rotate the img by 5 degrees. Bicubic interpolation is used i.e. the output pixel value is a weighted average of pixels in the nearest 4-by-4 neighborhood. (mathworks)
        k = imfuse(i,j,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]); %the two imgs are fused together and colored
    end
    function [i_new] = CoolInverted(i) %function to flip, invert and add cool colours to rgb img
        LR = i(1:end,end:-1:1,:); %flip the img from left to right
        gray = rgb2gray(LR); %convert img to grayscale
        inverted = 255-gray; %invert the img to get the X-ray effect
        map = cool(256); %get the cool colormap
        i_new = ind2rgb(inverted, map); %overlay the img with the cool colormap
    end
    function [mir] = Mirror(i) %function to create mirror effect of an rgb img
    LR = i(1:end,end:-1:1,:); %flip the img from left to right 
    [m,n]= size(LR); %find size dimensions 
    if mod(m,2) == 0 && mod(n,2) == 0 %if img dimensions are both even 
       mir = i; %then the mirror img will have the same values as input img i
    end
    if mod(m,2) ~= 0 && mod(n,2) == 0 %if no. of rows of i is not even and if no. of cols is even 
        mir = i; %then let mirror img have the same values as input img i but 
        mir = vertcat(mir,i(end,:)); %then add an extra row which is a duplicate of the last row of i, so that img dimensions are even
    end
    if mod(m,2) == 0 && mod(n,2) ~= 0 %if no. of rows of i is even and if no. of cols isn't even 
        mir = i;%then let mirror img have the same values as input img i but
        mir = horzcat(mir,i(:,end));%then add an extra col which is a duplicate of the last col of i, so that img dimensions are even
    end
    if mod(m,2) ~= 0 && mod(n,2) ~= 0 %if no. of rows and cols are both odd
        mir = i; %then let mirror img have the same values as input img i but
        horzcat(mir,i(:,end)); %then add an extra row which is a duplicate of the last row of i 
        b = horzcat(i(end,:),i(end,end)); %now create a longer row so that it can be vertically concatenated with the above 
        mir = vertcat(mir,b); %vertically concatenate b so that now the dimensions are even
    end
    %now that mirror has even rows and columns we can continue
    halfcols = n/2; %find the middle of the img
    for i = 1:m
        for j = halfcols:n
            mir(i,j) = LR(i,j); %let the mirror img get all the pixel values of LR, to form the mirror img
        end
    end
    end
    function [X] = PencilSketch(image)
        %convert to grayscale image
        image2 = rgb2gray(image);
        %convert greyscale image to double
        image2= double(image2);

        threshold = 50;%threshold parameter
        h=20;%parameter for converting low to higphass
        p= 2;%parameter to blend edges ;

        %gaussian lowpass filters
        gaussfilt1 = fspecial('Gaussian', 5,0.5);
        gaussfilt2 = fspecial('Gaussian', 5,2);
        %convert gaussian lowpass filter to highpass filter
        newIm = (1+h)*gaussfilt1 - (h*gaussfilt2);

        %concatenate the highpass filtered image with grayscalemage
        FilteredImage = conv2(image2,newIm,'same');

        %get the size of the image 
        [m,n] = size(FilteredImage);

        %blend the highpass filtered image
        for f=1:m
            for j=1:n
                if FilteredImage(f,j) > threshold
                    FilteredImage(f,j) = 1;
                else 
                    FilteredImage(f,j) = 1 + tanh(p*(FilteredImage(f,j)-threshold));
                end
            end
        end

        %perform gaussfilter 
        Finalgauss = fspecial('Gaussian',10,1.5);

        %concatenate the fitered image
        FinalIm = conv2(FilteredImage,Finalgauss,'same');

        %output the original and the image with the effect
        X = FinalIm;
    end
    figure() %output all the effects 
    subplot(3,3,1),
    imshow(i),
    title('Original image'),
    subplot(3,3,2),
    imshow(Thermal(i)),
    title('Thermal image'),
    subplot(3,3,3),
    imshow(OldenDay(i)),
    title('Olden day image'),
    subplot(3,3,4),
    imshow(charcoal(i)),
    title('Charcoal image'),
    subplot(3,3,5),
    imshow(XRay(i)),
    title('X-ray image'),
    subplot(3,3,6),
    imshow(Mirror(i)),
    title('Mirror image'),
    subplot(3,3,7),
    imshow(CoolInverted(i)),
    title('Cool inverted and flipped image');
    subplot(3,3,8),
    imshow(PencilSketch(i)),
    title('Pencil sketch image');
    subplot(3,3,9),
    imshow(RotateImfuse(i)),
    title('Rotated and imfused image');
end