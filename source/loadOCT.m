%	loadOCT(path, 'threshold', clean_factor, 'imref', [xref, yref, zref])
%         Load the 3D image from a stack of png.
%               'imref', imref: is real-world coordinates can be used to register the image
%               'threshold', threshold: thresholding hides all pixels with 
%                                       a value smaller than threshold
%               'sigma', sigma: standard deviation used for denoising (see
%                               see BM3D documentation for more info

% Uses the BM3D by Kostadin Dabov, Aram Danieyan, Alessandro Foi; can be found at
% http://www.cs.tut.fi/~foi/GCF-BM3D


function [volume, varargout] = loadOCT(path, varargin)


str = strcat(path, '\*.png')
D = dir(str)

% read the image
for i = 1:numel(D)
  tmp_path = strcat (D(i).folder, '\', D(i).name);
  tmp = imread(tmp_path);
  if (size(tmp ,3) == 3)
    tmp = squeeze(rgb2gray(tmp));
  end
  if (i==1)
      volume = zeros(size(tmp,1),size(tmp,2),0);
  end
  volume = cat(3,volume, tmp);
end


if(nargin>1)
    % imref3d obj is created for real-world coords to help in 
    if (strcmp(varargin{1}, 'imref') && size(varargin{2},2)==3)
        varargout{1} = imref3d(size(volume), varargin{2}(1), varargin{2}(2), varargin{2}(3));
    end
    
    if(nargin>3)
        if (nargin > 5)
           % in the case both 'denoise' & 'threshold' are set, 
           % the thresholding is done after denoising
           if (strcmp(varargin{3}, 'denoise'))
                randn('seed', 0);
                sigma = varargin{4};
                volume = im2double(volume);
                z = volume + (sigma/255)*randn(size(volume));
                for i = 1:size(z,2)
                [NA, volume(:,i,:)] = BM3D(1, squeeze(z(:,i,:)), sigma);
            end 
           end
        % threshold the image
        if (strcmp(varargin{3},'threshold'))
           % !note that if denoising volume is now double not uint8 so
           % threshold needs to be adjusted
            if(strcmp(varargin{3}, 'denoise'))
                threshold = varargin{4}/255;
            else
                threshold = varargin{4};
            end
            volume(volume<=threshold)=0;
        end
    end
end

end


