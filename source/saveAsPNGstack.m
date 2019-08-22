function saveAsPNGstack (img, path, name)
    %% saveAsPNGstack
    %   save a 3D image as a .png stack of 2D images

    if (ndims(img) < 3)
        error('Image is not 3D!')
    end

    path = strcat(path, '\' , name)
    mkdir (path)

    % fix for name format from other png stack
    % start from zero & up to 4 leading zeros
    for i = 1:(size(img,1))
        tmp = squeeze(img(i, :, :));
        tmp_name = strcat(path, '\img_', num2str((i-1),'%04.f'), '.png');
        imwrite(tmp, tmp_name);
    end
    
    new_img = loadOCT(path);
    volumeViewer(new_img);
end