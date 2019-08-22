% yStack.m was used as an example to process y_stack images
%   current values (i.e. offset and names are from the y_stack sample
%   must be adjusted to be used for other sample (e.g. y_stack2)

% Uses Image Processing & Computer vision toolbox for MATLAB
% https://www.mathworks.com/solutions/image-video-processing.html
% Uses the BM3D by Kostadin Dabov, Aram Danieyan, Alessandro Foi; can be found at
% http://www.cs.tut.fi/~foi/GCF-BM3D

clear all;
root_dir = 'D:\Astrid\My Documents\University\Year 4\ECS770_ UG Project\matlab\OCT_DATA\21-3-18\flat_2';
% path to folder with image stacks

%% Loading of data
%   - requires loadOCT.m to be in MATLAB path
%   - requires composePath.m to be in MATLAB path
%   - requires saveAsPNG.m to be in MATLAB path
%   NB images may not have been identified correctly as 'buccal' or
%   'lingual' BUT are correct relative to one another

threshold = 70
sigma = 25

z_PixelSize=20.2712; % microns per pixel
x_PixelSize=10.3425; % microns per pixel
y_PixelSize=13.3867; % microns per pixel

imref = [x_PixelSize z_PixelSize y_PixelSize];

% Load with thresholding and denoising
[buccal, buccal_ref] = loadOCT(composePath(root_dir,'1kHz_Buccal'),'imref', imref, 'clean',threshold, 'denoise', sigma);
[lingual, lingual_ref] = loadOCT(composePath(root_dir,'1kHz_Lingual'),'imref', imref, 'clean',threshold, 'denoise', sigma);
[view45, view45_ref] = loadOCT(composePath(root_dir,'1kHz_Proximal_noLesion_45'),'imref', imref, 'clean',threshold, 'denoise', sigma);
[view135, view135_ref] = loadOCT(composePath(root_dir,'1kHz_Proximal_noLesion_135'),'imref', imref, 'clean',threshold, 'denoise', sigma);
[view225, view225_ref] = loadOCT(composePath(root_dir,'1kHz_Proximal_Lesion_225'),'imref', imref, 'clean',threshold, 'denoise', sigma);
[view315, view315_ref] = loadOCT(composePath(root_dir,'1kHz_Proximal_Lesion_315'),'imref', imref, 'clean',threshold, 'denoise', sigma);

% Load images without thresholding or denoising
% [buccal, buccal_ref] = loadOCT(composePath(root_dir,'1kHz_Buccal'),'imref', imref);
% [lingual, lingual_ref] = loadOCT(composePath(root_dir,'1kHz_Lingual'),'imref', imref);
% [view45, view45_ref] = loadOCT(composePath(root_dir,'1kHz_Proximal_noLesion_45'),'imref', imref);
% [view135, view135_ref] = loadOCT(composePath(root_dir,'1kHz_Proximal_noLesion_135'),'imref', imref);
% [view225, view225_ref] = loadOCT(composePath(root_dir,'1kHz_Proximal_Lesion_225'),'imref', imref);
% [view315, view315_ref] = loadOCT(composePath(root_dir,'1kHz_Proximal_Lesion_315'),'imref', imref);

%% Perform initial translation
offset = [0 -380 0];    % rotation axis offset along z-axis
% NB:   rotation around x-axis/ offset is on z-axis
%       z-axis in real model corresponds to y dimension on MATLAB always

% shift 
[buccal_, buccal_ref_] = imtranslate(buccal, buccal_ref, offset,'OutputView', 'same');
[view45_, view45_ref_] = imtranslate(view45, view45_ref, offset,'OutputView', 'same');
[view135_, view135_ref_] = imtranslate(view135, view135_ref, offset,'OutputView', 'same');

[lingual_, lingual_ref_] = imtranslate(lingual, lingual_ref, offset,'OutputView', 'same');
[view225_, view225_ref_] = imtranslate(view225, view225_ref, offset,'OutputView', 'same');
[view315_, view315_ref_] = imtranslate(view315, view315_ref, offset,'OutputView', 'same');

view45_  = imrotate3(view45_, 45, [1 0 0], 'crop');     
view135_ = imrotate3(view135_, 315, [1 0 0], 'crop');   

lingual_  = imrotate3(lingual_, 180, [1 0 0], 'crop');  
view225_ = imrotate3(view225_, -135, [1 0 0], 'crop');  
view315_ = imrotate3(view315_, 135, [1 0 0], 'crop');   

volA = buccal_ + view45_ + view135_;
volB = lingual_ + view225_ + view315_;
volume_unreg = volA + volB;

saveAsPNGstack(volume_unreg,root_dir,"2204_unreg"); % final unregistered image saved

%% Initialisation of registration parameters
%   - default values refer to MATLAB function
[optimizer, metric] = imregconfig('monomodal')  % monomodal | multimodal
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

%% Registration of images relative to each other
%   - happens in sides (i.e. buccal side with +/- 45 degrees images and
%       same for other side
%   - parameters which can be used are 'rigid' or 'translation'; others
%       including rotation and other transformations results in bad
%       registration

[view135_, view135__ref_] = imregister(view135_, view135_ref_, buccal_, buccal_ref, 'rigid', optimizer, metric);    % rigid | translation
[view45_, view45_ref_] = imregister(view45_, view45_ref_, buccal_, buccal_ref_, 'rigid', optimizer, metric);        % rigid | translation

volA_reg =  view45_ + buccal_ + view135_;
saveAsPNGstack(volA_reg,root_dir,"2204_regA");  % image is saved multiple times in case of crash


[view225_, view225__ref_] = imregister(view225_, view225_ref_, lingual_, lingual_ref, 'rigid', optimizer, metric);  % rigid | translation
[view315_, view315__ref_] = imregister(view315_, view315_ref_, lingual_, lingual_ref_, 'rigid', optimizer, metric); % rigid | translation

volB_reg =  view315_ + lingual_ + view225_;
saveAsPNGstack(volB_reg,root_dir,"2204_regB");  % image is saved multiple times in case of crash

%% Add sides together
volume_reg = volA_reg + volB_reg;
saveAsPNGstack(volume_reg,root_dir,"2204_reg"); % final registered image saved

%% Display in volume viewer
volumeViewer(volume_unreg);
volumeViewer(volume_reg);