% ============================================================
% samiko // 2020-04-21
% MATLAB IMAGE TO ASCII ART CONVERTER
% ============================================================

clear;
clc;
format compact;

% Print header
fprintf(['============================================================\n', ...
    '  ______  ______   ______   ______   ______  \n', ...
    ' /      |/      \\ /      \\ /      \\ /      \\ \n', ...
    ' $$$$$$//$$$$$$  /$$$$$$  /$$$$$$  /$$$$$$  |\n', ...
    '   $$ | $$ \\__$$/$$ |__$$ $$ |__$$ $$ |  $$/ \n', ...
    '   $$ | $$      \\$$    $$ $$    $$ $$ |      \n', ...
    '   $$ |  $$$$$$  $$$$$$$$ $$$$$$$$ $$ |   __ \n', ...
    '  _$$ |_/  \\__$$ $$ |  $$ $$ |  $$ $$ \\__/  |\n', ...
    ' / $$   $$    $$/$$ |  $$ $$ |  $$ $$    $$/ \n', ...
    ' $$$$$$/ $$$$$$/ $$/   $$/$$/   $$/ $$$$$$/  \n\n', ...
    ' ISSAC <> IMAGE-SOURCED ASCII ART CONVERTER\n', ...
    ' Version 0.3 // samiko\n', ...
    '============================================================\n\n']);


% Query user for input arguments, map path to image, load image data as array.
try
    % Validate file path and if it exists
    fprintf("[?] Enter path to image: ");
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
    
    % Trim image to nearest tens
    trimmed_y_size = round(y_size,-1);
    trimmed_x_size = round(x_size,-1);
    input_region = zeros(trimmed_y_size,trimmed_x_size);
    
    if trimmed_y_size >= y_size && trimmed_x_size >= x_size
        input_region(1:y_size,1:x_size) = imageData;
    elseif trimmed_y_size <= y_size && trimmed_x_size >= x_size
        input_region(1:trimmed_y_size,1:x_size) = imageData(1:trimmed_y_size,:);
    elseif trimmed_y_size >= y_size && trimmed_x_size <= x_size
        input_region(1:y_size,1:trimmed_x_size) = imageData(:,1:trimmed_x_size);
    elseif trimmed_y_size <= y_size && trimmed_x_size <= x_size
        input_region(1:trimmed_y_size,1:trimmed_x_size) = imageData(1:trimmed_y_size,1:trimmed_x_size);
    else
        errorStruct.identifier = 'DEFINEBLOCK:DimError';
        error(errorStruct);
    end
    
    if trimmed_y_size < y_size
        y_size = trimmed_y_size;
    end
    if trimmed_x_size < x_size
        x_size = trimmed_x_size;
    end
    
    % Define output size options
    output_sizes = ["Very Large (VL)","Large (L)","Medium (M)","Small (S)"];

    
    if x_size <= 500 || y_size <= 500
        size_index = [1,2,5,10];
    else
        size_factor = x_size/500;
        while size_factor < x_size && div == false
            size_factor = size_factor + 1;
            if mod(x_size/size_factor,1) == 0 && mod(y_size/size_factor,1) == 0

                div = true;
            end
            max_output_size = ceil(x_size/500);       
        end
    end
    
    % Query for output_size
    fprintf("[+] Output options - %s, %s, %s, %s\n", output_sizes);
    fprintf("[?] Select an output size: ");
    output_size = upper(input("",'s'));

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
    switch e.identifier
        case 'LOADFILE:FileNotFound'
            errorStruct.message = "[x] ERROR: File not found. Please make sure you've entered the correct file path.";    
            error(errorStruct);
        case 'LOADFILE:FileNotImage'
            errorStruct.message = "[x] ERROR: File is not an image. Failed to read image data from file.";
            error(errorStruct);
        case 'DEFINEBLOCK:DimError'
            errorStruct.message = "[x] ERROR: Dimension error, please try a different image.";
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

% Define block regions, grid and index image data
output_data = [];

% Define ASCII character set
symbol_set = [' ', ',', '*', '/', '(', '#', '&', '%'];
intensity_index = [224, 192, 160, 128, 96, 64, 32, 0];

output_file = fopen('output.txt','w');

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
            if intensity_L > intensity_index(symbol)
                block_val_L = symbol_set(symbol);
            end
            if intensity_R > intensity_index(symbol)
                block_val_R = symbol_set(symbol);
            end
        end
        
        block_val = [block_val_L, block_val_R];
        output_row = [output_row, block_val];
        
    end
    
    output_data = [output_data; output_row];
    
end

for y = 1:(y_size/block_size)
    for x = 1:(x_size*2/block_size)
        fprintf(output_file,"%c",output_data(y,x));
    end
    fprintf(output_file,"\n");
end

fprintf("[+] ASCII art saved as %s\\output.txt\n", pwd);

fclose(output_file);
