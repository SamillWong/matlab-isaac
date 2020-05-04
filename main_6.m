% ============================================================
% samiko // 2020-04-30
% MATLAB IMAGE TO ASCII ART CONVERTER Version 0.6
% ============================================================

% Initialise and format console space
clear;
clc;
format compact;

% Print fancy ASCII art header
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
    ' Version 0.6 // samiko\n\n', ...
    '============================================================\n\n']);


% Query and load image data as an array, trim image, define output sizes
try
    % Query user input for file path
    fprintf("[?] Enter file path to image (max 5 MB):\n");
    input_path = input("    >> ", 's');
    
    % Validate file path and check whether if file exists
    if exist(input_path, 'file') ~= 2
        errorStruct.identifier = 'LOADFILE:FileNotFound';
        error(errorStruct);
    end
    
    % Validate file extension
    [file_path, name, ext] = fileparts(input_path);
    ext = string(ext);
    if ext ~= ".png" && ext ~= ".jpg" && ext ~= ".jpeg" && ext ~= ".bmp" && ext ~= ".tiff"
        errorStruct.identifier = 'LOADFILE:FileNotImage';
        error(errorStruct);
    end
    
    % Validate file size, throw exception if above limit (5 MB)
    if dir(input_path).bytes >= 5*1024^2
        errorStruct.identifier = 'LOADFILE:FileTooLarge';
        error(errorStruct);
    end
    
    % Load image data as greyscale, define image dimensions
    fprintf("[+] Loading %s...\n", string(input_path));
    image_data = rgb2gray(imread(input_path));
    [y_size,x_size] = size(image_data);
    fprintf("[+] Image details: %s%s | %i x %i %s file | %0.2f MB\n", string(name), ext, x_size, y_size, upper(erase(ext,".")), (dir(input_path).bytes/1024^2));
    
    % Trim image dimensions to nearest tens for small images, hundreds for large images
    if x_size * y_size <= 532000
        trimmed_y_size = round(y_size,-1);
        trimmed_x_size = round(x_size,-1);
    else
        trimmed_y_size = round(y_size,-2);
        trimmed_x_size = round(x_size,-2);
    end
    
    % Initialise input_region, used to layer image_data on trimmed dimensions
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
        errorStruct.identifier = 'DEFINEBLOCK:DimInvalid';
        error(errorStruct);
    end
    
    % Update new trimmed dimensions to avoid conflicting array sizes
    if trimmed_y_size < y_size
        y_size = trimmed_y_size;
    end
    if trimmed_x_size < x_size
        x_size = trimmed_x_size;
    end
    
    % Determine size_index relative to image size
    if x_size * y_size < 532000
        % Default values, divisible by 10 for smaller images
        size_index = [1,2,5,10];
    else
        % Calculate size_factor, used to scale size_index
        size_factor = floor(sqrt(floor((x_size * y_size)/532000)));
        size_index = [1,2,5,10];
        
        % Generate new size_options for larger images
        size_options = 4-size_factor;
        while size_options < 4
            for block_size = 11:50
                if mod(trimmed_x_size,block_size) == 0 && mod(trimmed_y_size,block_size) == 0 && size_options < 4
                    % Shift size_index to the left, set new block_size value
                    size_index(1:3) = size_index(2:4);
                    size_index(4) = block_size;
                    size_options = size_options + 1;
                    break
                end
            end
        end
    end
    
    % Define output size labels
    output_sizes = ["[VL] Very Large","[L] Large","[M] Medium","[S] Small"];
    
    % Query user input for output_size
    fprintf("[+] Output options - %s, %s, %s, %s\n", output_sizes);
    fprintf("[?] Select an output size:\n");
    output_size = upper(input("    >> ",'s'));

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
        % Throw exception if an invalid size is entered
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
        case 'DEFINEBLOCK:DimInvalid'
            errorStruct.message = "[x] ERROR: Dimension error. Please try a different image.";
            error(errorStruct);
        case 'DEFINEBLOCK:OutOfRange'
            errorStruct.message = "[x] ERROR: Please input a valid output size.";
            error(errorStruct);
        otherwise
            rethrow(e);
    end
end

% Begin ASCII conversion code and time measure
fprintf("[+] Converting image to ASCII art...\n");
tic;

% Initialise output regions
output_data = [];

% Define ASCII character set and corresponding intensity_index
symbol_set = [' ', ',', '*', '/', '(', '#', '&', '%'];
intensity_index = [224, 192, 160, 128, 96, 64, 32, 0];

% Convert image array to ASCII
for y_block = 1:ceil(y_size/block_size)
    
    % Initialise and empty output_row
    output_row = zeros(1,ceil(x_size/block_size)*2);
    
    for x_block = 1:ceil(x_size/block_size)
        
        % Initialise and empty block
        block = zeros(block_size);
        
        % Fill block with values from input_region
        for y = 1:block_size
            for x = 1:block_size
                block(x,y) = input_region(x+((y_block-1)*block_size),y+((x_block-1)*block_size));
            end
        end
        
        % Initialise mean intensity array of block
        if size(block,1) == 1 && size(block,2) == 1
            intensity = block;
        else
            intensity = mean(block);
        end
        
        % Average intensity values for left-half of the block
        temp_sum = 0;        
        for L = 1:ceil(length(intensity)/2)
            temp_sum = temp_sum + intensity(L);
        end
        intensity_L = temp_sum/ceil(length(intensity)/2);

        % Average intensity values for right-half of the block
        temp_sum = 0;
        for R = ceil(length(intensity)/2):-1:1
            temp_sum = temp_sum + intensity(R);
        end
        intensity_R = temp_sum/ceil(length(intensity)/2);
        
        % Cycle through symbol_set and set block halves per intensity range
        for symbol = length(intensity_index):-1:1
            if intensity_L >= intensity_index(symbol)
                block_val_L = symbol_set(symbol);
            end
            if intensity_R >= intensity_index(symbol)
                block_val_R = symbol_set(symbol);
            end
        end
        
        % Recombine block halves, and push to output_row
        block_val = [block_val_L, block_val_R];
        output_row(x_block*2-1:x_block*2) = block_val;
        
    end
    
    % Append output_row to output_data
    output_data = [output_data; output_row];

end

% Output and file saving
try
    % Checks if output file is too large or output column count is too large
    if size(output_data,1)*size(output_data,2) >= 532000 || size(output_data,2) >= 1080
        fprintf(2,['[!] WARN: Selected output size is too large!\n', ...
            '    The output file may not be displayed correctly when opened in Notepad.\n', ...
            '    To avoid this, select a smaller output size and try again.\n'])
    end
    
    % Save output_data as .txt, open output_file with write permissions
    fprintf("[+] Saving output...\n");
    output_file = fopen('output.txt','w');
    for y = 1:(size(output_data,1))-2
        for x = 1:(size(output_data,2))-2
            fprintf(output_file,"%c",output_data(y,x));
        end
        fprintf(output_file,"\n");
    end

    % Save confirmation and close output_file
    fprintf("[+] ASCII art saved as %s\\output.txt\n", pwd);
    fclose(output_file);

    
catch e
    % Exception handler
    switch e.identifier
        case 'MATLAB:FileIO:InvalidFid'
            errorStruct.message = "[x] ERROR: Insufficient permission to write file to current directory.";
            error(errorStruct);
        otherwise
            rethrow(e);
    end
end

% Done message and display time_taken
time_taken = toc;
fprintf("[+] Done! Elapsed time: %0.2fs\n", time_taken);