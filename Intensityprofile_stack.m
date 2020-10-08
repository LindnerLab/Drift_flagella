%% QUANTIFICATION OF THE MIGRATION OF FLUORESCENT FLAGELLA AS A FUNCTION OF Z - STACKED IMAGE
%
%~~~~~  GENERAL DESCRIPTION   : 
%
% *  READ AN IMAGE SEQUENCE (FLAGELLA SUSPENSION IMAGED OVER Z, MAX. 750 IMG)
% *  FOR EACH IMAGE OF THE SEQUENCE:
%    ** ESTABLISH A MEAN INTENSITY PROFILE ALONG X
%    ** ESTABLISH A GAUSSIAN FIT OF THE MEAN INTENSITY PROFILE
%    ** DISPLAY THE MEAN INTENSITY PROFILE WITH ITS FIT, THEN CLOSE IT
%    ** RAW VALUES AND FIT VALUES ARE SAVED (BOTH MEANS AND ABSCISS RANGES)
% *  PLOT ALL MEAN INTENSITY PROFILES (RAW AND FITS)
% *  PLOT ALL PIXEL INDICES CORRESPONDING TO THE CENTERS OF INTENSITY DISTRIBUTIONS OVER TIME (POTENTIAL DRIFT)
% *  PLOT REPRESENTATIVE DISTRIBUTIONS (BOTTOM, CENTER, AND TOP) AND THEIR CENTERS (RAWS AND FITS)
%
% IMPORTANT NOTES:
%       -IMAGE SEQUENCES NEED TO BE OPTIMIZED USING IMAGEJ BEFORE USING THIS CODE. SEE PROTOCOLE "DRIFT EXPERIMENT".
%       -BOTH FILES INTENSITYPROFILE.M AND MAT2TILES.M NEED TO BE PLACED IN THE IMAGE SEQUENCE FOLDER.
%       -MAKE SURE YOUR MATLAB DIRECTORY IS THE FOLDER CONTAINING THESE THREE FILES.
%
%~~~~~ OUTPUT: MATLAB STRUCTURE xy 
%
%              WITH THE FOLLOWING STRUCTURE: xy(i).property{j}, WHERE 
%
% (i) is the filament label              i = 1...FilNum = number of objects in the stack 
% {j} is the sequential index            j = 1...nframe = number of analyzed frames 
%
% IMPORTANT NOTES: 
% FilNum must be constant in the whole sequence, and MUST be specified before running the code
% nframe is returned by the code
%
% PROPERTY ARE:
%     crd = cell containing the x-y coordinates of the skeleton --> x = first column, y = second column
%     centroid = cell containing the x-y coordinates of the centroid of the skeleton
%     arclen = 1-d array of arc lengths of the skeleton                     
%     seglen = cell containing the length of each segment in the skeleton  
%     emptyframe = 1-d array of frame where the filament cannot be detected   
%     frame = frame number in t
%% CODE

close all

basepath = 'D:\2020-09-11\7. L7 X=-4072 to -4102\2020-09-11_11h15m28s\';
Im=imread(strcat(basepath,'SUM_590.jpg'));

%IMAGE SIZE AND DATA RETRIEVING
[x,y]=size(Im);
%Pixel indices vectors
X = 1:x;
Y = 1:y;
i= im2double(Im); %intensity values
Vectors = mat2tiles(i,[1,y]); %cut i into vectors of size [1,y], each of them = 1 horizontal line of the image 

%CALCULATING A MEAN CURVE WITH STD FOR EACH POINT
for k = 1:x
    Means(k) = mean(Vectors{k,1});
    Stds(k) = std(Vectors{k,1});
end

% SMOOTHING DATA IF NEEDED
Gaussian20_Means = smoothdata(Means,'gaussian',20);
Gaussian50_Means = smoothdata(Means,'gaussian',50);
Gaussian100_Means = smoothdata(Means,'gaussian',100);
figure()
hold on
title('Means - Gaussian smoothing')
plot(X,Means)
plot(X,Gaussian20_Means)
plot(X,Gaussian50_Means)
plot(X,Gaussian100_Means)
xlabel('Pixel n°')
ylabel('Intensity')
legend('Means','Gaussian (20)','Gaussian (50)','Gaussian (100)')
hold off
saveas(gcf,'SmoothingFIG_Means','pdf');
saveas(gcf,'SmoothingFIG_Means','fig');

input_smooth = input('How many points do you want to smooth your data on? \n');
if input_smooth == 0
    Smoothingmethod = 'None';
    Means = Means;
else
    Smoothingmethod = 'Gaussian';
    Means = smoothdata(Means,'gaussian',input_smooth);
end
smoothingdegree = sprintf('%d',input_smooth);
 
% Means = smoothdata(Means,'gaussian',100);
 
% FINDING CORRESPONDING INDICES
Globalstd = std(Means); % distribution of mean values
Globalmax = max(Means); % maximal mean value
% Index of the maximum
Indexmax = find(Means==Globalmax);
% Index of the std on both sides
Minus = Globalmax-Globalstd;
[lowvalue, Minusix] = min(abs(Means-Minus));
Plusix = Indexmax + (Indexmax-Minusix);

% Plotting intensity =f(dataX)
figure()
hold on
plot(X, Means)
xline(Indexmax, 'r', Indexmax);
xline(Minusix, 'b:', Minusix);
xline(Plusix, 'b:', Plusix);
%title(strcat('2D Intensity plot, ', Smoothingmethod,smoothingdegree));
hold off
saveas(gcf,'2Dplot_mean-and-std','pdf');
saveas(gcf,'2Dplot_mean-and-std','fig');