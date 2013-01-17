function I2 = radonRotate(I)

Ibw = im2bw(I, graythresh(I));
BW = edge(Ibw,'canny');
theta = 0:180;
[R,xp] = radon(BW,theta);
%gibt colormap der Radontransf. aus
%hold on
%figure, imagesc(theta, xp, R); colormap(hot);
%xlabel('\theta (degrees)'); ylabel('x\prime');
%title('R_{\theta} (x\prime)');
%colorbar;
[r,c] = find(R == max(R(:)));
thetap = theta(c(1));           
xpp = xp(r(1));
if (thetap ~= 0)
   %rotiert das Ursprungsbild zum Winkel aus der Radontransf.
   if (thetap==90 && xpp ~=-90)
       I2=I;
   elseif(xpp==0 && thetap>60)
       I2=I;
   elseif (xpp>=0 && thetap >=45)
       I2 = imrotate(I,-thetap,'bilinear', 'crop');
   elseif (thetap>90 && xpp< 0)
       I2=imrotate(I,thetap-90,'bilinear');
   elseif (xpp < 0 && thetap >= 45)
       I2=imrotate(I,90-thetap,'bilinear', 'crop');
   elseif ((xpp <= -1 && xpp >= -50) && thetap >45)
       I2 = imrotate(I,thetap-90,'bilinear');
   elseif (xpp >= 0 && thetap < 45)
       I2 = imrotate(I, -thetap, 'bilinear');
   elseif (xpp < 0 && thetap < 45) 
       I2 = imrotate(I,-thetap,'bilinear');
   end
elseif (thetap==0 && xpp <=-45 && xpp>=-60)
   I2 = imrotate(I, 90, 'bilinear');
else
   I2=I;
end