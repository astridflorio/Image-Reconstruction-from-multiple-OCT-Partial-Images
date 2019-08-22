% Reload Script
% Use this script to load pre-processed volumes using MATLAB
% Requires loadOCT.m to be in the MATLAB path

% used by loadOCT.m with thresholding and denoising
imref = [10.3425 20.2712 13.3867];  % obtained through camera specs
threshold = 70  % set to 0 for denoising without thresholding
sigma = 25      % see 

% path = "Additional Material Submission\Results\4-1-1_Results"     % uncomment path & set to directory containing image stack

vol = loadOCT(path);

% alternative: use loadOCT.m with thresholding and denoising of image
% vol = loadOCT(xmt_path,'imref', imref, 'clean',threshold, 'denoise', sigma);

% Automatically displays image in the volume viewer when finished
volumeViewer(vol);