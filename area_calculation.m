clc;clear all;close all;

[file,path,indx] = uigetfile( ...
{'*.JPG;*.dcm;*.png;*.bmp;*.jpeg;*.mat'}, ...
   'Select a File');
filename=strcat(path,file);


Test_image = imread(filename);



%% Tumor parameters to reduce false positives - hard coded - more parameters involved

    % Binarized image of nodules using watershed segmentation
    BW = Test_image;
    dImage=BW;

    % Find connected components (blobs)
    cc = bwconncomp(BW); 

    % Find statistics/properties of each blob
    stats = regionprops(cc, 'all'); 

    %% Create new column (dervied) in regionprops (stats) structure array 

    % DICOM header - extract pixel size for planeXY, XZ, YZ from DICOM meta data
    % pixel_spacing = dInfo.PixelSpacing;
    pixel_spacing=[0.5859;0.5859];
    per_pixel_area = pixel_spacing(1)*pixel_spacing(2);

    % Area based on per pixel area
    actual_area = num2cell([stats.Area]*[per_pixel_area]);
    [stats.ActualArea] = actual_area{:};

    % Actual perimeter based on pixel spacing
    actual_perimeter = num2cell([stats.Perimeter]*[pixel_spacing(1)]);
    [stats.ActualPerimeter] = actual_perimeter{:};

    % Actual major axis based on pixel spacing
    actual_diameter = num2cell([stats.MajorAxisLength]*[pixel_spacing(1)]);
    [stats.ActualMajorAxisLength] = actual_diameter{:};

    % Mean Gray Level Intensity of nodule
    for k = 1 : length(stats)           % Loop through all blobs.
        thisBlobsPixels = stats(k).PixelIdxList;        % Get list of pixels in current blob.
            MeanIntensity = mean(BW(thisBlobsPixels));  % Find mean intensity (in original image!)
            stats(k).MeanIntensity = MeanIntensity;
    end

    %% Find desired Parameters
    % Get index in regionprops stucture array that satisfy property according
    % to TNM 8th edition

    % Stage t1a
    if (length(stats) ~= 0)
    idx = find([stats.ActualMajorAxisLength] > 3 & [stats.ActualMajorAxisLength] <= 10 & [stats.Eccentricity] < 0.8 & [stats.MeanIntensity] < 800);

    t1a = ismember(labelmatrix(cc), idx);  
    % figure, imshow(t1a), title('Stage t1a mask - Discard due to high false positive');
    t1a_stats = stats(idx);

    % Stage t1b
    idx = find([stats.ActualMajorAxisLength] > 10 & [stats.ActualMajorAxisLength] <= 20 & [stats.Eccentricity] < 0.8 & [stats.MeanIntensity] < 800);

    t1b = ismember(labelmatrix(cc), idx);  
    % figure, imshow(t1b), title('Stage t1b mask');
    t1b_stats = stats(idx);

    % Stage t1c
    idx = find([stats.ActualMajorAxisLength] > 20 & [stats.ActualMajorAxisLength] <= 30 & [stats.Eccentricity] < 0.8 & [stats.MeanIntensity] < 800);

    t1c = ismember(labelmatrix(cc), idx);  
    % figure, imshow(t1c), title('Stage t1c mask');
    t1c_stats = stats(idx);

    % Stage 2
    idx = find([stats.ActualMajorAxisLength] > 30 & [stats.ActualMajorAxisLength] <= 50 & [stats.Eccentricity] < 0.8 & [stats.MeanIntensity] < 800);

    t2 = ismember(labelmatrix(cc), idx);  
    % figure, imshow(t2), title('Stage t2 mask');
    t2_stats = stats(idx);


    % Stage 3
    idx = find([stats.ActualMajorAxisLength] > 50 & [stats.Eccentricity] < 0.8 & [stats.MeanIntensity] < 800);

    t3 = ismember(labelmatrix(cc), idx);  
    % figure, imshow(t3), title('Stage t3 mask');
    t3_stats = stats(idx);
    end

    %% Display Result on Command Window

    % Discard stage t1a due to high false positive rate
    % If there are no tumors > stage t1a, we consider as normal
    if length(stats) == 0
        %('normal lung')

    else
        if (length(t1b_stats) + length(t1c_stats) + length(t2_stats) == 0)
        %('normal lung')


        % Visualize output
        fprintf('\nEarly Detection saves lives! Possible nodules:\n\n');
        if length(t1a_stats) ~= 0
            t1a_holes = bwlabel(t1a); 
            boundary = bwboundaries(t1a_holes);
            figure, imshow(dImage, []), title('Probable T1a Tumors');
            disp('Probable T1a Tumors');
            
            hold on
            visboundaries(boundary, 'Color', 'r');

            maskedImageT1a = dImage;
            maskedImageT1a(~t1a_holes) = 0;

            disp('T1a\n');
            figure, imshow(maskedImageT1a, []), title(' Probable T1a Tumors');
            disp('Probable T1a Tumors');
            showNoduleStats(t1a_stats);
        end

        else
            ('tumor detected')

            % Visualize output of t1a nodules
            if length(t1a_stats) ~= 0
                t1a_holes = bwlabel(t1a); 
                boundary = bwboundaries(t1a_holes);
                figure, imshow(dImage, []), title('Probable T1a Tumors');
                disp('Probable T1a Tumors');
                hold on
                visboundaries(boundary, 'Color', 'r');

                maskedImageT1a = dImage;
                maskedImageT1a(~t1a_holes) = 0;

                disp('T1a');
                figure, imshow(maskedImageT1a, []), title(' Probable T1a Tumors');
                disp('Probable T1a Tumors');
                showNoduleStats(t1a_stats);
            end

            % Visualize output of t1b nodules
            if length(t1b_stats) ~= 0
                t1b_holes = bwlabel(t1b); 
                boundary = bwboundaries(t1b_holes);
                figure, imshow(dImage, []), title('T1b Tumors');
                disp('Probable T1b Tumors');
                hold on
                visboundaries(boundary, 'Color', 'r');

                maskedImageT1b = dImage;
                maskedImageT1b(~t1b_holes) = 0;

                disp('T1b');
                figure, imshow(maskedImageT1b, []), title('T1b Tumors');
                disp('Probable T1b Tumors');
                showNoduleStats(t1b_stats);
            end

            % Visualize output
            if length(t1c_stats) ~= 0
                t1c_holes = bwlabel(t1c); 
                boundary = bwbound
                aries(t1c_holes);
                imshow(dImage, []), title('T1c Tumors');
                disp('Probable T1cTumors');
                hold on
                visboundaries(boundary, 'Color', 'g');

                maskedImageT1c = dImage;
                maskedImageT1c(~t1c_holes) = 0;
                figure, imshow(maskedImageT1c, []), title('T1c Tumors');
                disp('Probable T1c Tumors');

                disp('T1c');
                showNoduleStats(t1c_stats);
            end

            % Visualize output
            if length(t2_stats) ~= 0
                t2_holes = bwlabel(t2); 
                boundary = bwboundaries(t2_holes);
                figure, imshow(dImage, []), title('T2 Tumors');
                disp('Probable T2 Tumors');
                hold on
                visboundaries(boundary, 'Color', 'c');

                maskedImageT2 = dImage;
                maskedImageT2(~t2_holes) = 0;
                figure, imshow(maskedImageT2, []), title('T2 Tumors');
                disp('Probable T2 Tumors');

                disp('T2');
                showNoduleStats(t2_stats)
            end

              % Visualize output
            if length(t3_stats) ~= 0
                t3_holes = bwlabel(t3); 
                boundary = bwboundaries(t3_holes);
                figure, imshow(dImage, []), title('T3 Tumors');
                disp('Probable T3 Tumors');
                hold on
                visboundaries(boundary, 'Color', 'y');

                maskedImageT3 = dImage;
                maskedImageT3(~t3_holes) = 0;
                figure, imshow(maskedImageT3, []), title('T3 Tumors');
                disp('Probable T3 Tumors');

                disp('T3');
                showNoduleStats(t3_stats)
            end
        end
    end
