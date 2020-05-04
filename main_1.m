% ============================================================
% samiko // 2020-04-08
% MATLAB IMAGE TO ASCII ART CONVERTER
% ============================================================

fprintf("MATLAB IMAGE TO ASCII ART CONVERTER BOT 9000\n");

% Query user for input arguments, map path to image, load image data as array.
try
    % Validate file path and if it exists
    fprintf("Enter path to image: ");
    file_path = input("", 's');
    if exist(file_path, 'file') ~= 2
        errorStruct.identifier = 'LOADFILE:FileNotFound';
        error(errorStruct);
    end
    
    % Validate file extension
    [filepath, name, ext] = fileparts(file_path);
    ext = string(ext);
    if ext ~= ".png" && ext ~= ".jpg" && ext ~= ".jpeg" && ext ~= ".bmp" && ext ~= ".tiff"
        errorStruct.identifier = 'LOADFILE:FileNotImage';
        error(errorStruct);
    end
    
    % Determine maximum output size
    if x_size < 200
        max_output_size = x_size;
    else
        max_output_size = 200;
    end
    
    % Query for output_size
    fprintf("[-] Enter output width size (max %i): ", max_output_size);
    output_size = input("");    
    if output_size > max_output_size || output_size <= 0 || mod(output_size,1) ~= 0
        errorStruct.identifier = 'DEFINEBLOCK:WidthOutOfRange';
        error(errorStruct);
    end
catch e
    switch e.identifier
        case 'LOADFILE:FileNotFound'
            errorStruct.message = "ERROR: File not found. Please make sure you've entered the correct file path.";    
            error(errorStruct);
        case 'LOADFILE:FileNotImage'
            errorStruct.message = "ERROR: File is not an image. Failed to read image data from file.";
            error(errorStruct);
        case 'DEFINEBLOCK:WidthOutOfRange'
            errorStruct.message = "ERROR: Please input a valid output width size (1-200).";
            error(errorStruct);
        otherwise
            rethrow(e);
    end
end