function oilp= oilpaint(Im)
[m, n,r]=size(Im);
%determines then nearest pixels to be processed
radius=9;
oilp=uint8(zeros(m-radius,n-radius,3));

%check the neighbour of every pixel to find the most repeated colour
for i=1:m-radius
    for j=1:n-radius
        %get the intensity mask of the pixel
        mask=Im(i:i+radius-1,j:j+radius-1,:);
        %calculate the histogram for the r,g,and b channels
        hist=zeros(256,3);
        for x=1:radius
            for y= 1:radius
                %calculate the histogram for the red channel
                hist((mask(x,y,1)+1),1)=hist((mask(x,y,1)+1),1)+1;
                %calculate the histogram for the blue channel
                hist((mask(x,y,2)+1),2)=hist((mask(x,y,2)+1),2)+1;
                %calculate the histogram for the green channel
                hist((mask(x,y,3)+1),3)=hist((mask(x,y,3)+1),3)+1;
            end
        end
  %Obtain Maximum occurring pixel value and its position 
       for k=1:3
        [maxcol,pos]=max(hist(:,k));
        %assign the maximum colour pixel to the output image
        oilp(i,j,k)=pos-1;
       end
    end
end

%output the image
figure()
subplot(1,2,1)
imshow(Im)
title('Original image')
subplot(1,2,2)
imshow(oilp)      
title(' Image with oil-paint effect');
end