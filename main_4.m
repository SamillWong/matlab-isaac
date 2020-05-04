% ============================================================
% samiko // 2020-04-23
% MATLAB IMAGE TO ASCII ART CONVERTER
% ============================================================

clear;
clc;
format compact;

% Print header
fprintf(['============================================================\n\n', ...
    '  ______  ______   ______   ______   ______  \n', ...
    ' /      |/      \\ /      \\ /      \\ /      \\ \n', ...
    ' $$$$$$//$$$$$$  /$$$$$$  /$$$$$$  /$$$$$$  |\n', ...
    '   $$ | $$ \\__$$/$$ |__$$ $$ |__$$ $$ |  $$/ \n', ...
    '   $$ | $$      \\$$    $$ $$    $$ $$ |      \n', ...
    '   $$ |  $$$$$$  $$$$$$$$ $$$$$$$$ $$ |   __ \n', ...
    '  _$$ |_/  \\__$$ $$ |  $$ $$ |  $$ $$ \\__/  |\n', ...
    ' / $$   $$    $$/$$ |  $$ $$ |  $$ $$    $$/ \n', ...
    ' $$$$$$/ $$$$$$/ $$/   $$/$$/   $$/ $$$$$$/  \n\n', ...
    ' ISAAC <> IMAGE-SOURCED ASCII ART CONVERTER\n', ...
    ' Version 0.4 // samiko\n\n', ...
    '============================================================\n\n']);


% Query and load image data as array, trim image, define output sizes.
try
    % Query user for input file path
    fprintf("[?] Enter path to image (max 5 MB): ");
    input_path = input("", 's');
    
    % Validate file path and whether if it exists
    if exist(input_path, 'file') ~= 2
        errorStruct.identifier = 'LOADFILE:FileNotFound';
        error(errorStruct);
    end
    
    % Validate file extension
    [filepath, name, ext] = fileparts(input_path);
    ext = string(ext);
    if ext ~= ".png" && ext ~= ".jpg" && ext ~= ".jpeg" && ext ~= ".bmp" && ext ~= ".tiff"
        errorStruct.identifier = 'LOADFILE:FileNotImage';
        error(errorStruct);
    end
    
    % Validate file size
    if dir(input_path).bytes >= 5*1024^2
        errorStruct.identifier = 'LOADFILE:FileTooLarge';
        error(errorStruct);
    end
    
    % Load image data, image dimensions
    fprintf("[+] Loading %s...\n", string(input_path));
    image_data = rgb2gray(imread(input_path));
    [y_size,x_size] = size(image_data);
    fprintf("[+] Image details: %s%s | %i x %i %s file | %0.2f MB\n", string(name), ext, x_size, y_size, upper(erase(ext,".")), (dir(input_path).bytes/1024^2));
    
    % Trim image dimensions to nearest tens for small images, hundreds for large images.
    if x_size * y_size <= 532000
        trimmed_y_size = round(y_size,-1);
        trimmed_x_size = round(x_size,-1);
    else
        trimmed_y_size = round(y_size,-2);
        trimmed_x_size = round(x_size,-2);
    end
    
    % Initialises input_region used to layer image_data on trimmed dimensions.
    input_region = zeros(trimmed_y_size,trimmed_x_size);
    
    % Overlay image_data on input_region
    if trimmed_y_size >= y_size && trimmed_x_size >= x_size
        input_region(1:y_size,1:x_size) = image_data;
    elseif trimmed_y_size <= y_size && trimmed_x_size >= x_size
        input_region(1:trimmed_y_size,1:x_size) = image_data(1:trimmed_y_size,:);
    elseif trimmed_y_size >= y_size && trimmed_x_size <= x_size
        input_region(1:y_size,1:trimmed_x_size) = image_data(:,1:trimmed_x_size);
    elseif trimmed_y_size <= y_size && trimmed_x_size <= x_size
        input_region(1:trimmed_y_size,1:trimmed_x_size) = image_data(1:trimmed_y_size,1:trimmed_x_size);
    else
        errorStruct.identifier = 'DEFINEBLOCK:DimError';
        error(errorStruct);
    end
    
    % Apply new trimmed dimensions to y_size & x_size, if any
    if trimmed_y_size < y_size
        y_size = trimmed_y_size;
    end
    if trimmed_x_size < x_size
        x_size = trimmed_x_size;
    end
    
    % Determine size_index relative to image size
    if x_size * y_size <= 532000
        % Default values, divisible by 10 for smaller images
        size_index = [1,2,5,10];
    else
        % Calculates size_factor used to scale size_index
        size_factor = floor(sqrt(floor((x_size * y_size)/532000)));
        size_index = [1,2,5,10];
        
        % Generate new size_options for larger images
        size_options = 4-size_factor;
        while size_options < 4
            for block_size = 11:50
                if mod(trimmed_x_size,block_size) == 0 && mod(trimmed_y_size,block_size) == 0 && size_options < 4
                    size_index(1:3) = size_index(2:4);
                    size_index(4) = block_size;
                    size_options = size_options + 1;
                end
            end
        end
    end
    
    % Define output size labels
    output_sizes = ["Very Large (VL)","Large (L)","Medium (M)","Small (S)"];
    
    % Query user for output_size
    fprintf("[+] Output options - %s, %s, %s, %s\n", output_sizes);
    fprintf("[?] Select an output size: ");
    output_size = upper(input("",'s'));

    % Define block_size according to query
    switch output_size
        case {"VERY LARGE","VL"}
            block_size = size_index(1);
        case {"LARGE","L"}
            block_size = size_index(2);
        case {"MEDIUM","M"}
            block_size = size_index(3);
        case {"SMALL","S"}
            block_size = size_index(4);
        otherwise
            errorStruct.identifier = 'DEFINEBLOCK:OutOfRange';
            error(errorStruct);
    end
    
catch e
    % Exception handler
    switch e.identifier
        case 'LOADFILE:FileNotFound'
            errorStruct.message = "[x] ERROR: File not found. Please make sure you've entered the correct file path.";    
            error(errorStruct);
        case 'LOADFILE:FileNotImage'
            errorStruct.message = "[x] ERROR: File is not an image. Failed to read image data from file.";
            error(errorStruct);
        case 'LOADFILE:FileTooLarge'
            errorStruct.message = "[x] ERROR: Image is too large. Please try a smaller image (max 5 MB).";
            error(errorStruct);
        case 'DEFINEBLOCK:DimError'
            errorStruct.message = "[x] ERROR: Dimension error. Please try a different image.";
            error(errorStruct);
        case 'DEFINEBLOCK:OutOfRange'
            errorStruct.message = "[x] ERROR: Please input a valid output size.";
            error(errorStruct);
        otherwise
            rethrow(e);
    end
end

% Begin ASCII mapping codeblock
fprintf("[+] Converting image to ASCII art...\n");
tic;

% Define block regions, grid and index image data
output_data = [];

% Define ASCII character set
symbol_set = [' ', ',', '*', '/', '(', '#', '&', '%'];
intensity_index = [224, 192, 160, 128, 96, 64, 32, 0];

for y_block = 1:ceil(y_size/block_size)
    
    output_row = [];
    
    for x_block = 1:ceil(x_size/block_size)
        
        block = zeros(block_size);
        
        for y = 1:block_size
            for x = 1:block_size
                block(x,y) = input_region(x+((y_block-1)*block_size),y+((x_block-1)*block_size));
            end
        end
               
        intensity = mean(block);
        
        temp_sum = 0;
        
        for L = 1:ceil(length(intensity)/2)
            temp_sum = temp_sum + intensity(L);
            intensity_L = temp_sum/ceil(length(intensity)/2);
        end
        
        temp_sum = 0;
        
        for R = ceil(length(intensity)/2):-1:1
            temp_sum = temp_sum + intensity(R);
            intensity_R = temp_sum/ceil(length(intensity)/2);
        end

        for symbol = length(intensity_index):-1:1
            if intensity_L >= intensity_index(symbol)
                block_val_L = symbol_set(symbol);
            end
            if intensity_R >= intensity_index(symbol)
                block_val_R = symbol_set(symbol);
            end
        end
        
        block_val = [block_val_L, block_val_R];
        output_row = [output_row, block_val];
        
    end
    
    output_data = [output_data; output_row];

end

try
    % Checks if output file is too large
    if size(output_data,2) >= 532000
        fclose(output_file);
        errorStruct.identifier = 'ASCIICONV:OutputTooLarge';
        error(errorStruct);
    end

    % Print and save output to txt
    fprintf("[+] Saving output...\n");
    output_file = fopen('output.txt','w');
    for y = 1:(size(output_data,1))
        for x = 1:(size(output_data,2))
            fprintf(output_file,"%c",output_data(y,x));
        end
        fprintf(output_file,"\n");
    end


    fprintf("[+] ASCII art saved as %s\\output.txt\n", pwd);

    fclose(output_file);

    
catch e
    switch e.identifier
        case 'ASCIICONV:OutputTooLarge'
            errorStruct.message = "[x] ERROR: Output is too large, please try a smaller image or size.";
            error(errorStruct);
        otherwise
            rethrow(e);
    end
end

time_taken = toc;
fprintf("[+] Done! Elapsed time: %0.2fs\n", time_taken);