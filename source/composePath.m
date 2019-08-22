
function path = composePath(root,folder)
%composePath used to automatically compose path of image stacks generated
%               by OCT scanner
path = strcat(root, '\', folder, '\B-Scans');
end

