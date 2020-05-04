% ============================================================
% samiko // 2020-04-18
% MATLAB IMAGE TO ASCII ART CONVERTER
% ============================================================

clear;
clc;
format compact;

fprintf("MATLAB IMAGE TO ASCII ART CONVERTER BOT 9000\n");

% Query user for input arguments, map path to image, load image data as array.
try
    % Validate file path and if it exists
    fprintf("[-] Enter path to image: ");
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
    
    % Load image data
    fprintf("[+] Loading %s...\n", string(file_path));
    imageData = rgb2gray(imread(file_path));
    [y_size,x_size] = size(imageData);
    fprintf("[+] Image details: %s%s | %i x %i %s file\n", string(name), ext, x_size, y_size, upper(erase(ext,".")));
    
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
            errorStruct.message = "[x] ERROR: File not found. Please make sure you've entered the correct file path.";    
            error(errorStruct);
        case 'LOADFILE:FileNotImage'
            errorStruct.message = "[x] ERROR: File is not an image. Failed to read image data from file.";
            error(errorStruct);
        case 'DEFINEBLOCK:WidthOutOfRange'
            errorStruct.message = "[x] ERROR: Please input a valid output width size (1-200).";
            error(errorStruct);
        otherwise
            rethrow(e);
    end
end

% Define block regions, grid and index image data
block_size = 5;

output_data = [];

% Define ASCII character set
symbol_set = [' ', ',', '*', '/', '(', '#', '&', '%'];
intensity_index = [224, 192, 160, 128, 96, 64, 32, 0];

output_file = fopen('output.txt','w');

% output = zeros(50);

for y_block = 1:ceil(y_size/block_size)
    output_row = [];
    for x_block = 1:ceil(x_size/block_size)
        block = zeros(block_size);
        for y = 1:block_size
            for x = 1:block_size
                block(x,y) = imageData(x+((y_block-1)*block_size),y+((x_block-1)*block_size));
            end
        end
        intensity = ceil(mean(block,'all'));
        block_val = [];
        for symbol = length(intensity_index):-1:1
            if intensity > intensity_index(symbol)
                block_val = symbol_set(symbol);
            end
        end
        block_val = [block_val, '  '];
        output_row = [output_row, block_val];
        % output_row = [output_row, block]
    end
    output_data = [output_data; output_row];
end


% display as an image
% imshow(output);

% save as an image
% imwrite(output,'output.png');

fclose(output_file);

disp(output_data);
