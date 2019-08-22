% preliminary.m was used as an example to process the preliminary images
%   current values (i.e. offset and names are from the preliminary sample
%   must be adjusted to be used for other samples

% Uses Image Processing & Computer vision toolbox for MATLAB
% https://www.mathworks.com/solutions/image-video-processing.html
% Uses the BM3D by Kostadin Dabov, Aram Danieyan, Alessandro Foi; can be found at
% http://www.cs.tut.fi/~foi/GCF-BM3D

clear all;
root_dir = '\preliminary';

%% Loading of data
%   - requires loadOCT.m to be in MATLAB path
%   - requires composePath.m to be in MATLAB path
%   - requires saveAsPNG.m to be in MATLAB path
%   NB images may not have been identified correctly as 'buccal' or
%   'lingual' BUT are correct relative to one another

threshold = 70;

z_PixelSize=20.2712; % microns per pixel
x_PixelSize=10.3425; % microns per pixel
y_PixelSize=13.3867; % microns per pixel

imref = [x_PixelSize z_PixelSize y_PixelSize];

[buccal, buccal_ref] = loadOCT(composePath(root_dir,'18 - 500 Hz - Buccal'),'imref', imref, 'clean',threshold);
[lingual, lingual_ref] = loadOCT(composePath(root_dir,'20 - 500 Hz - Lingual'),'imref', imref, 'clean',threshold);
[occlusal, occlusal_ref] = loadOCT(composePath(root_dir,'17 - 500Hz - Occlusal'),'imref', imref, 'clean',threshold);

[proximal, proximal_ref] = loadOCT_clean(composePath(root_dir,'17 - 500Hz - Occlusal'),'imref', imref, 'clean',threshold);

% [buccal, buccal_ref] = loadOCT(composePath(root_dir,'18 - 500 Hz - Buccal'),'imref', imref);
% [lingual, lingual_ref] = loadOCT(composePath(root_dir,'20 - 500 Hz - Lingual'),'imref', imref);
% [occlusal, occlusal_ref] = loadOCT(composePath(root_dir,'17 - 500Hz - Occlusal'),'imref', imref);

%% Transformation to composite 3D image

% Remove extra voxels in x-axis
[x, y, z] = size(buccal);
y = y - 150;

Buccal_ = buccal(1:y,:,:);
Lingual_ = lingual(1:y,:,:);
Occlusal_ = occlusal_(1:y,:,:);
Proximal_ = proximal(1:y,:,:);

% Rotate to real world position
Lingual_ = imrotate3(Lingual_, 180, [1 0 0], 'crop'); % loose | crop

Occlusal_ = imrotate3(Occlusal_, 90, [0 0 1], 'crop');
Occlusal_ = imrotate3(Occlusal_, -90, [1 0 0], 'crop');

Proximal_ = imrotate3(Proximal_, 90, [1 0 0], 'crop');

Occlusal_ = imresize3(Occlusal_, 0.9);  % automatic transformation has trouble if resize required is greater than +/- 10%
Occlusal_ = paddedUp(Lingual_,Occlusal_);

% cat is concatenate (i.e. no overlapping in images) whereas sum has
% overlapping

%unreg = cat(1, Buccal_, Lingual_);

volume = Lingual_ + Buccal_;
volume_unreg = volume + Occlusal_;
% volume_3 = volume_2 + Proximal_    % includes proximal view

% display in volume viewer
% volumeViewer(volume);
volumeViewer(volume_unreg);

saveAsPNGstack(volume_unreg,root_dir,"x1ba_unreg");

%%
[optimizer, metric] = imregconfig('monomodal')
                                                % MaximumIterations — Maximum number of iterations
optimizer.MaximumIterations = 500                   % 100 (default) | positive integer scalar
                                                % GradientMagnitudeTolerance — Gradient magnitude tolerance
optimizer.GradientMagnitudeTolerance = 1e-8         % 1e-4 (default) | positive scalar
                                                % MinimumStepLength — Tolerance for convergence
optimizer.MinimumStepLength = 1e-7                  % 1e-5 (default) | positive scalar
                                                % MaximumStepLength — Initial step length
optimizer.MaximumStepLength = 0.0625                % 0.0625 (default) | positive scalar
                                                % RelaxationFactor — Step length reduction factor
optimizer.RelaxationFactor = 0.2                    % 0.5 (default) | positive scalar between 0 and 1


[lingual_, lingual__ref_] = imregister(Lingual_, lingual_ref_, buccal_, buccal_ref, 'translation', optimizer, metric);
[occlusal_, occlusal_ref_] = imregister(Occlusal_, occlusal_ref_, buccal_, buccal_ref_, 'translation', optimizer, metric);

volume_reg = buccal_ + lingual_ + occlusal_;
saveAsPNGstack(volume_reg,root_dir,"x1ba_reg");
