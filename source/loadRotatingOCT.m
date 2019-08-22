function loadRotatingOCT(path, outputDir)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    inputDir = dir(path)
    
    pxSize = [10.3425,13.3867,20.2712]; % [x,y,z]
    rotationOffset = 320;
    totalAngles = numel(inputDir) - 2;

    outputDir = strcat(outputDir, '\3DReconstruct\reconstructedImage');
    if ~exist(outputDir)
        mkdir(outputDir);
    end
    
    path = strcat(path, '\Position');
    csv_path = strcat(path,'0000\parameters.csv');
    topDir = '\B-Scans\OCTImage0000.png';
    
    bScan_width = dlmread(csv_path,',',[2,1,2,1]);
    bScan_height = dlmread(csv_path,',',[6,1,6,1])/2;
    
%     stack = zeros([bScan_height,bScan_width,totalAngles)];
%     stack = cell(1,numel(D));
    coords = zeros([bScan_height*bScan_width*totalAngles, 4]);
    n = 0;
    for i = 0:totalAngles %(numel(inputDir)-1)
        bScan_path = strcat(path, sprintf('%04d', i));
        theta = dlmread(strcat(bScan_path,'/parameters.csv'),',',[21,1,21,1]);
        
        tmp_img = imread(strcat(bScan_path, topDir));
%         stack{(i+1)} = imread(strcat(bScan_path, topDir));
        
%         if(size(stack{(i+1)}) == 3)
%             stack{(i+1)} = rgb2gray(stack{(i+1)});
        if(size(tmp_img) == 3)
            tmp_img = squeeze(rgb2gray(tmp_img));
        end
        
        for w = 1:bScan_width
            x = w*pxSize(1);
            
            for h = 1:bScan_height
                r = (rotationOffset - h)*pxSize(3);
                y = r*sin(theta);
                z = r*cos(theta);
                
                n = n+1;
                coords(n,:) = [x, y, z, tmp_img(h,w)]; %maybe imcell here
            end
        end
    end
    
%     X=coords(:,1);
    Y=coords(:,2);
    Z=coords(:,3);
%     I=coords(:,4);
    
    coords = reshape(coords,[bScan_height,bScan_width,totalAngles,4]);
    plane = bScan_height*totalAngles;
    
    for w = bScan_width
        W = reshape(coords(:,w,:,3),[plane,1]);
        D = reshape(coords(:,w,:,2),[plane,1]);
        II = reshape(coords(:,w,:,4),[plane,1]);
        
        [grid_W, grid_D] = meshgrid(min(Z):pxSize(3):max(Z),min(Y),pxSize(2):max(Y));
        interpolatedGrid=griddata(W,D,II,grid_W,grid_D,'linear');
        
        interpolatedGrid = uint16(interpolatedGrid);
        
        img_path = strcat(outputDir, sprintf('%04d',w), '.png');
        
        imwrite(interpolatedGrid, img_path);
        
    end
end %end function

