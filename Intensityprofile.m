%% VERTICAL INTENSITY PROFILES OVER GREY STACK IMAGES %%

%% Draw a line over the image and plot intensity profile

% basepath = 'D:\2020-09-11\1.1. L1 X=-2070\10h34m05s';
% Image = imread(strcat(basepath,'SUM_745_20.jpg')); % reading img
% 
% imshow(Image,[]); % showing image
% 
% improfile

%% 3D-intensity profile of an entire image
% 
% basepath = 'D:\2020-09-11\1.1. L1 X=-2070\10h34m05s\';
% Im=imread(strcat(basepath,'SUM_745.jpg'));
% 
% % Size of the image and meshing; 3D-plot display;
% [x,y]=size(Im);
% X=1:x;
% Y=1:y;
% [xx,yy]=meshgrid(Y,X);
% i=im2double(Im);
% figure;mesh(xx,yy,i);
% saveas(gcf,'3Dplot_intensity','pdf');
% saveas(gcf,'3Dplot_intensity','fig');
% colorbar
% 
% % Maximal values and corresponding indices (pixel position) of the entire image stored in Max and Index
% [Max,Index] = max(i);
% Mean = mean(Index); % average index where pixel values reaches a maximum
% Std = std(Index);
% %Stderr = std(Index)/sqrt(length(Index)); % how is the spread around the index peak
% lowbar = Mean-Std;
% highbar = Mean + Std;
% 
% % Displaying max index value and distribution around peak on the figure
% x1 = [1024 1024];
% y2 = [0 size(Im,1)];
% c = improfile(Im,x1,y2);
% figure
% subplot(2,1,1)
% imshow(Im);
% hold on
% plot(x1,y2,'r')
% subplot(2,1,2)
% plot(c(:,1,1),'r')
% hold on
% xl1 = xline(mean(Index),'k',mean(Index));
% xl1.LabelVerticalAlignment = 'middle';
% xl1.LabelHorizontalAlignment = 'center';
% xl2 = xline(lowbar,'b',lowbar);
% xl2.LabelVerticalAlignment = 'top';
% xl2.LabelHorizontalAlignment = 'left';
% xl3 = xline(highbar,'b',highbar);
% xl3.LabelVerticalAlignment = 'bottom';
% xl3.LabelHorizontalAlignment = 'right';
% hold off
% saveas(gcf,'2Dintensityplot_mean-and-std','pdf');
% saveas(gcf,'2Dintensityplot_mean-and-std','fig');

%% SEQUENCE OF IMAGES: 2D-profile = equiv. of the average on each xi of the 3D-profile

close all

%Get a list of all txt files in the current folder, or subfolders of it.
fds = fileDatastore('*.jpg', 'ReadFcn', @importdata);
fullFileNames = fds.Files;
numFiles = length(fullFileNames);

% Initializing matrices
Datamean={};
Datastds={};
Dataglobalmax=[];
Dataglobalstd=[];
Dataindexmax=[];
Dataminusix=[];
Dataplusix=[];
% Loop over all files reading them in and plotting them.
for k = 1 : numFiles
    fprintf('Now reading file %s\n', fullFileNames{k});
    Im = imread(fds.Files{k});
    [x,y]=size(Im);
    X = 1:x;
    Y = 1:y;
    i= im2double(Im);
    Vectors = mat2tiles(i,[1,y]);
    for p = 1:x
        Means(p) = mean(Vectors{p,1});
        Stds(p) = std(Vectors{p,1});
    end
    % TEST
    figure()
    hold on
    plot(X,Means)
    f = fit(X.',Means.','gauss1');
    plot(f,X,Means)
    hold off
    close
    % FIT VALUES -------------------------------------------
    %Means = smoothdata(Means,'gaussian',100);
    FMeans = f(X);
    FGlobalmax = max(FMeans); % maximal mean value
    FGlobalstd = std(FMeans); % distribution of mean values
    FIndexmax = find(FMeans==FGlobalmax); % Index of the maximum
    FMinus = FGlobalmax-FGlobalstd; % Index of the std on both sides
    [F_lowvalue, FMinusix] = min(abs(FMeans-FMinus));
    FPlusix = FIndexmax + (FIndexmax-FMinusix);
    % RAW VALUES -------------------------------------------
    %Means = smoothdata(Means,'gaussian',100);
    Globalmax = max(Means); % maximal mean value
    Globalstd = std(Means); % distribution of mean values
    Indexmax = find(Means==Globalmax); % Index of the maximum
    Minus = Globalmax-Globalstd; % Index of the std on both sides
    [lowvalue, Minusix] = min(abs(Means-Minus));
    Plusix = Indexmax + (Indexmax-Minusix);
    % FIT ARRAYS --------------------------------------------
    FDatamean{k}=FMeans;
    FDataglobalmax(k)=FGlobalmax;
    FDataglobalstd(k)=FGlobalstd;
    FDataindexmax(k)=FIndexmax;
    FDataminusix(k)=FMinusix;
    FDataplusix(k)=FPlusix;
    % RAW ARRAYS --------------------------------------------
    Datamean{k}=Means;
    Datastds{k}=Stds;
    Dataglobalmax(k)=Globalmax;
    Dataglobalstd(k)=Globalstd;
    Dataindexmax(k)=Indexmax;
    Dataminusix(k)=Minusix;
    Dataplusix(k)=Plusix;
end

% PLOTTING MEANS
T = 1:numFiles;
figure()
hold on
for k=1:numFiles
    plot(X, Datamean{k})
    plot(X, FDatamean{k})
end
xlabel('Frame n°');
ylabel('Intensity');
legend('Raw data','Fitted data');
%title(strcat('2D Intensity plot, ', Smoothingmethod,smoothingdegree));
hold off
saveas(gcf,'2Dplot_mean-and-std','pdf');
saveas(gcf,'2Dplot_mean-and-std','fig');

% PLOTTING INDICES
figure()
Dataindexmax_smooth = smoothdata(Dataindexmax, 'movmean', 100);
FDataindexmax_smooth = smoothdata(FDataindexmax, 'movmean', 100);
hold on
plot(T, Dataindexmax)
plot(T, Dataindexmax_smooth)
plot(T, FDataindexmax)
plot(T, FDataindexmax_smooth)
Maxsmooth = sprintf('%.1f',max(Dataindexmax_smooth));
Minsmooth = sprintf('%.1f',min(Dataindexmax_smooth));
yline(max(Dataindexmax_smooth),'r',strcat('Right max:',Maxsmooth));
yline(min(Dataindexmax_smooth),'r',strcat('Left max:',Minsmooth));
xlabel('Frame n°');
ylabel('Index corresponding to the maximal intensity obtained on a given frame');
legend('Raw data', 'Smooth raw data', 'Fitted data', 'Smooth fitted data');
hold off
saveas(gcf,'Indexmax=f(framenb)','pdf');
saveas(gcf,'Indexmax=f(framenb)','fig');
%title(strcat('2D Intensity plot, ', Smoothingmethod,smoothingdegree));

% PLOTTING A FIGURE WITH ONLY A FEW INTENSITY PROFILES (REPRESENTATIVE)
% figure()
% hold on
% plot(X,FDatamean{86})
% plot(X,FDatamean{190})
% plot(X,FDatamean{316})
% plot(X,FDatamean{442})
% plot(X,FDatamean{604})
% plot(X,FDatamean{706})
% xl1 = xline(FDataindexmax(86),'b:',FDataindexmax(50));
% xl2 = xline(FDataindexmax(190),'b:',FDataindexmax(96));
% xl3 = xline(FDataindexmax(316),'b:',FDataindexmax(165));
% xl4 = xline(FDataindexmax(442),'b:',FDataindexmax(320));
% xl5 = xline(FDataindexmax(604),'b:',FDataindexmax(350));
% xl6 = xline(FDataindexmax(706),'b:',FDataindexmax(350));
% xl1.LabelVerticalAlignment = 'middle';
% xl1.LabelHorizontalAlignment = 'center';
% xl2.LabelVerticalAlignment = 'middle';
% xl2.LabelHorizontalAlignment = 'center';
% xl3.LabelVerticalAlignment = 'middle';
% xl3.LabelHorizontalAlignment = 'center';
% xl4.LabelVerticalAlignment = 'middle';
% xl4.LabelHorizontalAlignment = 'center';
% xl5.LabelVerticalAlignment = 'middle';
% xl5.LabelHorizontalAlignment = 'center';
% xl6.LabelVerticalAlignment = 'middle';
% xl6.LabelHorizontalAlignment = 'center';
% xlabel('Frame n°')
% ylabel('Intensity')
% legend('img86','img190','img316','img442','img604','img706')
% hold off

%% STACKED IMAGE: 2D-profile = equiv. of the average on each xi of the 3D-profile
% close all
% 
% basepath = 'D:\2020-09-11\7. L7 X=-4072 to -4102\2020-09-11_11h15m28s\';
% Im=imread(strcat(basepath,'SUM_590.jpg'));
% 
% %IMAGE SIZE AND DATA RETRIEVING
% [x,y]=size(Im);
% %Pixel indices vectors
% X = 1:x;
% Y = 1:y;
% i= im2double(Im); %intensity values
% Vectors = mat2tiles(i,[1,y]); %cut i into vectors of size [1,y], each of them = 1 horizontal line of the image 
% 
% %CALCULATING A MEAN CURVE WITH STD FOR EACH POINT
% for k = 1:x
%     Means(k) = mean(Vectors{k,1});
%     Stds(k) = std(Vectors{k,1});
% end
% 
% % SMOOTHING DATA IF NEEDED
% Gaussian20_Means = smoothdata(Means,'gaussian',20);
% Gaussian50_Means = smoothdata(Means,'gaussian',50);
% Gaussian100_Means = smoothdata(Means,'gaussian',100);
% figure()
% hold on
% title('Means - Gaussian smoothing')
% plot(X,Means)
% plot(X,Gaussian20_Means)
% plot(X,Gaussian50_Means)
% plot(X,Gaussian100_Means)
% xlabel('Pixel n°')
% ylabel('Intensity')
% legend('Means','Gaussian (20)','Gaussian (50)','Gaussian (100)')
% hold off
% saveas(gcf,'SmoothingFIG_Means','pdf');
% saveas(gcf,'SmoothingFIG_Means','fig');
% 
% input_smooth = input('How many points do you want to smooth your data on? \n');
% if input_smooth == 0
%     Smoothingmethod = 'None';
%     Means = Means;
% else
%     Smoothingmethod = 'Gaussian';
%     Means = smoothdata(Means,'gaussian',input_smooth);
% end
% smoothingdegree = sprintf('%d',input_smooth);
%  
% % Means = smoothdata(Means,'gaussian',100);
%  
% % FINDING CORRESPONDING INDICES
% Globalstd = std(Means); % distribution of mean values
% Globalmax = max(Means); % maximal mean value
% % Index of the maximum
% Indexmax = find(Means==Globalmax);
% % Index of the std on both sides
% Minus = Globalmax-Globalstd;
% [lowvalue, Minusix] = min(abs(Means-Minus));
% Plusix = Indexmax + (Indexmax-Minusix);
% 
% % Plotting intensity =f(dataX)
% figure()
% hold on
% plot(X, Means)
% xline(Indexmax, 'r', Indexmax);
% xline(Minusix, 'b:', Minusix);
% xline(Plusix, 'b:', Plusix);
% %title(strcat('2D Intensity plot, ', Smoothingmethod,smoothingdegree));
% hold off
% saveas(gcf,'2Dplot_mean-and-std','pdf');
% saveas(gcf,'2Dplot_mean-and-std','fig');
