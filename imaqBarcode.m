clear;
imaqreset;
%import der jars
javaaddpath('.\core.jar');
javaaddpath('.\javase.jar');
%video wird geholt
vid = videoinput('winvideo', 1);
src = getselectedsource(vid);
get(src);
%video properties gesetzt
src.VerticalFlip = 'on';
set(vid, 'FramesPerTrigger', 1);
set(vid, 'TriggerRepeat', Inf);
triggerconfig(vid, 'manual');

%vid wird gestartet, preview wird angezeigt
start(vid);
preview(vid);
while true, 
    %Video-Frame wird akquiriert und in frame gespeichert
	trigger(vid);
    pause(1);
	frame = getdata(vid, 1);
    %frame = denoise(frame); %schwer optionales denoising, verbraucht viel
    %zu viel Leistung.
    %frame = rgb2gray(frame);
    
    %Ibw = im2bw(frame, graythresh(frame));
    I2 = radonRotate(frame);
    %Ausgabe des prozessierten Frames
    %imshow(I2);
    
    %Aufruf der 4 verschiedenen Methoden um Codes zu erkennen.
    message_qr = decodeQR(I2)
    message_dm = decodeMatrix(I2)
    message_ean13 = decodeEAN13(I2)
    message_ean8 = decodeEAN8(I2)
    %pause(3);
end