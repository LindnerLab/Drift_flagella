%% QUANTIFICATION OF THE MIGRATION (DRIFT) OF FLUORESCENT FLAGELLA AS A FUNCTION OF Z - IMAGE SEQUENCE
%
%~~~~~  GENERAL DESCRIPTION   : 
%
% *  READ AN IMAGE SEQUENCE (FLAGELLA SUSPENSION IMAGED OVER Z, MAX. 750 IMG)
% *  FOR EACH IMAGE OF THE SEQUENCE (ASSUMING A POTENTIAL DRIFT IN Y):
%    ** ESTABLISH A MEAN INTENSITY PROFILE ALONG X
%    ** ESTABLISH A GAUSSIAN FIT OF THE MEAN INTENSITY PROFILE
%    ** PLOT THE MEAN INTENSITY PROFILE WITH ITS FIT, THEN CLOSE IT
%    ** RAW VALUES AND FIT VALUES ARE SAVED (BOTH ORDINATE AND ABSCISSA RANGES)
% *  PLOT ALL MEAN INTENSITY PROFILES (RAW AND FITS)
% *  PLOT ALL PIXEL INDICES CORRESPONDING TO THE CENTERS OF INTENSITY DISTRIBUTIONS OVER TIME (POTENTIAL DRIFT)
% *  PLOT REPRESENTATIVE DISTRIBUTIONS (BOTTOM, CENTER, AND TOP) AND THEIR CENTERS (RAWS AND FITS)
%
% IMPORTANT NOTES:
%       -IMAGE SEQUENCES NEED TO BE OPTIMIZED USING IMAGEJ BEFORE USING THIS CODE. SEE PROTOCOLE "DRIFT EXPERIMENT".
%       -BOTH FILES INTENSITYPROFILE.M AND MAT2TILES.M NEED TO BE PLACED IN THE IMAGE SEQUENCE FOLDER.
%       -MAKE SURE YOUR MATLAB DIRECTORY IS THE FOLDER CONTAINING THESE THREE FILES.
%
%% CODE

% GET A LIST OF ALL .JPG FILES IN THE CURRENT FOLDER OR/AND SUBFOLDERS
fds = fileDatastore('*.jpg', 'ReadFcn', @importdata);
fullFileNames = fds.Files; % Names of .jpg files
numFiles = length(fullFileNames); % Total number of .jpg files

% INITIALIZING MATRICES
% * RAW VALUES ----------------------------------------------------------
Datamean={}; % Intensity value ranges (for each image)
Datastds={}; % Standard deviations (for each image, standard deviation to the mean values)
Dataglobalmax=[]; % Maximal intensity value (by image, for all images)
Dataglobalstd=[]; % Standard deviation around the maximal intensity value (for all images)
Dataindexmax=[]; % Corresponding pixel index of the maximal intensity value (for all images)
Dataminusix=[]; % Lowest pixel index bound (standard deviation around the indexmax)
Dataplusix=[]; % Highest pixel index bound (standard deviation around the indexmax)
% * FIT VALUES ----------------------------------------------------------
FDatamean={}; % Intensity value ranges (for each image)
FDataglobalmax=[]; % Maximal intensity value (by image, for all images)
FDataglobalstd=[]; % Standard deviation around the maximal intensity value (for all images)
FDataindexmax=[]; % Corresponding pixel index of the maximal intensity value (for all images)
FDataminusix=[]; % Lowest pixel index bound (standard deviation around the indexmax)
FDataplusix=[]; % Highest pixel index bound (standard deviation around the indexmax)
% * FIT VALUES AFTER OPTIMIZATION ---------------------------------------
NewX={}; % Tested abscissa ranges for fits (same as X, -10%, -20%, -30%)
NewMeans={}; % Tested ordinate ranges for fits (same as X, -10%, -20%, -30%)
fitobject={}; % Fits corresponding to the different ranges tested
gof={}; % Estimating the goodness of all fitobjects
R2=[]; % vector containing all gof.rsquare for a given image (renewed for each image)
Chosenfit={}; % Best fit (selected) by image
Chosenrange={}; % Best abscissa range by image
Chosenvalues={}; % Best ordinate range by image
Startpoints=[]; % Tested startpoints for abscissa / ordinate ranges (renewed for each image based on image size)
Endpoints=[]; % Tested endpoints for abscissa / ordinate ranges (renewed for each image based on image size)

% FOR EACH IMAGE
% * ESTABLISH A MEAN INTENSITY PROFILE ALONG X
for k = 1 : numFiles
    fprintf('Now reading file %s\n', fullFileNames{k});
    Im = imread(fds.Files{k});
    [x,y]=size(Im); % Image grid (for example 2048 x 2048)
    X = 1:x; % Vector containing each pixel along any line on the image (NB: that only works for SQUARE IMAGES)
    i= im2double(Im); % intensity value of each pixel (matrix)
    Vectors = mat2tiles(i,[1,y]); % Gathering pixel intensity values by vertical line (1 column of this matrix = 1 vertical line in the image)
    for p = 1:x
        Means(p) = mean(Vectors{p,1}); % Averaging intensity values over X for a given position in Y
        Stds(p) = std(Vectors{p,1}); % Standard deviation when averaging over X for a given position in Y
    end
    
% * ESTABLISH A GAUSSIAN FIT OF THE MEAN INTENSITY PROFILE
% ** TESTED STARTING AND ENDING FIT POINTS ------------------------------
    Startpoints(1) = 1;
    Startpoints(2) = round(length(X)*10/100);
    Startpoints(3) = round(length(X)*20/100);
    Startpoints(4) = round(length(X)*30/100);
    Endpoints(1) = length(X);
    Endpoints(2) = round(length(X)-length(X)*10/100);
    Endpoints(3) = round(length(X)-(length(X)*20/100));
    Endpoints(4) = round(length(X)-(length(X)*30/100));
% All startpoints and endpoints can be tested with one another (ex: Startpoints(1) with Endpoints(4))

% ** TESTED FITS AND RANGES ---------------------------------------------
    for m = 1:4
        for n = 1:4
            NewX{m,n}=X(Startpoints(m):Endpoints(n)); % Abscissa ranges to test
            NewMeans{m,n}=Means(Startpoints(m):Endpoints(n)); % Ordinate ranges to test
            % Fitobject records fits characteristics (parameters of the fit function)
            % Gof = "Goodness of fit" parameters (records the fit rsquare for example). 
            [fitobject{m,n},gof{m,n}] = fit(NewX{m,n}.',NewMeans{m,n}.','gauss1');  
            R2(m,n)=gof{m,n}.rsquare; % Matrix containing the rsquares of all fits tested on a given intensity profile
        end
    end
    
% ** SELECTING THE BEST FIT AND RANGES-----------------------------------    
    M = max(R2,[],'all'); % Finding the maximum rsquare
    [mo,no]=find(R2==M); % Finding the corresponding indices of the Startpoints and Endpoints
    Chosenfit{k}=fitobject{mo,no}; % Selecting the fit corresponding to this rsquare
    Chosenrange{k}=NewX{mo,no}; % Selecting the X range corresponding to this rsquare (pixels)
    Chosenvalues{k}=NewMeans{mo,no}; % Selecting the Y range corresponding to this rsquare (intensity)
    
% ** PLOTTING MEAN INTENSITY PROFILE AND ITS BEST FIT ------------------- 
    figure()
    hold on
    plot(X,Means)
    plot(Chosenfit{k},Chosenrange{k},Chosenvalues{k})
    hold off
    close

% * SAVING RAW AND FIT VALUES
% ** RAW VALUES
%           FOR EACH IMAGE ----------------------------------------------
    Globalmax = max(Means); % Maximal intensity value
    Globalstd = std(Means); % Standard deviation of the intensity distribution
    Indexmax = find(Means==Globalmax); % Index (pixel number) of the maximal intensity value
    Minus = Globalmax-Globalstd; % Index of the std on both sides
    [lowvalue, Minusix] = min(abs(Means-Minus)); % Minusix = lowest index of the standard deviation 
    Plusix = Indexmax + (Indexmax-Minusix); % Plusix = highest index of the standard deviation
%           FOR ALL IMAGES (ARRAYS) -------------------------------------
    Datamean{k}=Means;
    Datastds{k}=Stds;
    Dataglobalmax(k)=Globalmax;
    Dataglobalstd(k)=Globalstd;
    Dataindexmax(k)=Indexmax;
    Dataminusix(k)=Minusix;
    Dataplusix(k)=Plusix;
%
% ** FIT VALUES 
%           FOR EACH IMAGE ----------------------------------------------
    FMeans=Chosenfit{k}(Chosenrange{k}); % Fit values on the chosen range
    FGlobalmax = max(FMeans); % Maximal fit value
    FGlobalstd = std(FMeans); % Standard deviation of fit values
    % Depending on the Startpoint chosen, the real indices of the fit are "drifted"
    if mo ==1
        FIndexmax = find(FMeans==FGlobalmax); % Startpoint = the beginning of the sequence
    elseif mo == 2
        FIndexmax = find(FMeans==FGlobalmax)+205; % Startpoint = 10% further than the beginning of the sequence
    elseif mo == 3
        FIndexmax = find(FMeans==FGlobalmax)+410; % Startpoint = 20% further than the beginning of the sequence
    else
        FIndexmax = find(FMeans==FGlobalmax)+614; % Startpoint = 30% further than the beginning of the sequence
    end
    FMinus = FGlobalmax-FGlobalstd; % Index (pixel number) of the standard deviation on both sides
    [F_lowvalue, FMinusix] = min(abs(FMeans-FMinus)); % FMinusix = lowest index of the standard deviation
    FPlusix = FIndexmax + (FIndexmax-FMinusix); % FPlusix = highest index of the standard deviation
%           FOR ALL IMAGES (ARRAYS) -------------------------------------
    FDatamean{k}=FMeans;
    FDataglobalmax(k)=FGlobalmax;
    FDataglobalstd(k)=FGlobalstd;
    FDataindexmax(k)=FIndexmax;
    FDataminusix(k)=FMinusix;
    FDataplusix(k)=FPlusix;
    
end

% PLOTTING RAW MEANS
T = 1:numFiles;
figure()
hold on
for k=1:numFiles
    plot(X, Datamean{k})
end
xlabel('Frame n°');
ylabel('Intensity');
title(strcat('Mean intensity profiles');
hold off
saveas(gcf,'Raw_Meanprofiles','pdf');
saveas(gcf,'Raw_Meanprofiles','fig');

% PLOTTING FIT MEANS
T = 1:numFiles;
figure()
hold on
for k=1:numFiles
    plot(Chosenrange{k},FDatamean{1,k})
end
xlabel('Frame n°');
ylabel('Intensity');
title(strcat('Mean intensity profiles');
hold off
saveas(gcf,'Fit_Meanprofiles','pdf');
saveas(gcf,'Fit_Meanprofiles','fig');

% PLOTTING INDICES
figure()
Dataindexmax_smooth = smoothdata(Dataindexmax, 'movmean', 100);
FDataindexmax_smooth = smoothdata(FDataindexmax, 'movmean', 100);
hold on
plot(T, Dataindexmax)
plot(T, Dataindexmax_smooth)
plot(T, FDataindexmax)
plot(T, FDataindexmax_smooth)
Maxsmooth = sprintf('%.1f',max(Dataindexmax_smooth)); % Convert number to text and keeping one decimal
Minsmooth = sprintf('%.1f',min(Dataindexmax_smooth));
yline(max(Dataindexmax_smooth),'r',strcat('Right max:',Maxsmooth));
yline(min(Dataindexmax_smooth),'r',strcat('Left max:',Minsmooth));
xlabel('Frame n°');
ylabel('Index (pixel number) corresponding to the maximal intensity');
legend('Raw data', 'Smooth raw data', 'Fitted data', 'Smooth fitted data');
title(strcat('Pixel indices (maximal intensity) = f(number of frames)');
hold off
saveas(gcf,'Indexmax=f(framenb)','pdf');
saveas(gcf,'Indexmax=f(framenb)','fig');

% PLOTTING A FIGURE WITH ONLY A FEW INTENSITY PROFILES (REPRESENTATIVE)
% * REPRESENTATIVE FRAMES -----------------------------------------------
LowestFrame = round(10/100*length(Chosenrange));
MidFrame = round(50/100*length(Chosenrange));
HighestFrame = round(80/100*length(Chosenrange));
% * CONVERSION OF FRAME N° INTO TEXT ------------------------------------
TxtLF = sprintf('%g',LowestFrame); % '%g' allows no trailing zeros when converting number to char
TxtMF = sprintf('%g',MidFrame);
TxtHF = sprintf('%g',HighestFrame);
% * PLOTTING RAW VALUES -------------------------------------------------
figure()
hold on
plot(X,Datamean{LowestFrame})
plot(X,Datamean{1,MidFrame})
plot(X,Datamean{1,HighestFrame})
xl1 = xline(Dataindexmax(LowestFrame),'b',Dataindexmax(LowestFrame));
xl2 = xline(Dataindexmax(MidFrame),'k',Dataindexmax(MidFrame));
xl3 = xline(Dataindexmax(HighestFrame),'c',Dataindexmax(HighestFrame));
xl1.LabelVerticalAlignment = 'middle';
xl1.LabelHorizontalAlignment = 'center';
xl2.LabelVerticalAlignment = 'middle';
xl2.LabelHorizontalAlignment = 'center';
xl3.LabelVerticalAlignment = 'middle';
xl3.LabelHorizontalAlignment = 'center';
xlabel('Frame n°')
ylabel('Intensity')
legend(strcat('img',TxtLF),strcat('img',TxtMF),strcat('img',TxtHF))
hold off
saveas(gcf,strcat('Raw',TxtLF,'-',TxtMF,'-',TxtHF),'pdf');
saveas(gcf,strcat('Raw',TxtLF,'-',TxtMF,'-',TxtHF),'fig');
% * PLOTTING FIT VALUES -------------------------------------------------
figure()
hold on
plot(Chosenrange{LowestFrame},FDatamean{1,LowestFrame})
plot(Chosenrange{MidFrame},FDatamean{1,MidFrame})
plot(Chosenrange{HighestFrame},FDatamean{1,HighestFrame})
xl1 = xline(FDataindexmax(LowestFrame),'b',FDataindexmax(LowestFrame));
xl2 = xline(FDataindexmax(MidFrame),'k',FDataindexmax(MidFrame));
xl3 = xline(FDataindexmax(HighestFrame),'c',FDataindexmax(HighestFrame));
xl1.LabelVerticalAlignment = 'middle';
xl1.LabelHorizontalAlignment = 'center';
xl2.LabelVerticalAlignment = 'middle';
xl2.LabelHorizontalAlignment = 'center';
xl3.LabelVerticalAlignment = 'middle';
xl3.LabelHorizontalAlignment = 'center';
xlabel('Frame n°')
ylabel('Intensity')
legend(strcat('img',TxtLF),strcat('img',TxtMF),strcat('img',TxtHF))
hold off
Rawname = convertCharsToStrings(strcat('Fit',TxtLF,'-',TxtMF,'-',TxtHF));
saveas(gcf,Rawname,'pdf');
saveas(gcf,Rawname,'fig');

% SAVING WORKSPACE
save('Intensityprofile_sequence')