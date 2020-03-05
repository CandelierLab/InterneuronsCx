clc

warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');
warning('off', 'imageio:tiffmexutils:libtiffWarning');

% === Parameters ==========================================================

Study = 'LowMag';
Run = 'M1';

operations = ["drift", "norm_R"];

% -------------------------------------------------------------------------

DS = dataSource;
fImages = struct('Raw', [DS.data Study filesep Run filesep 'Raw_' Run '.tiff'], ...
    'R', [DS.data Study filesep Run filesep 'Raw_' Run '_R.tiff'], ...
    'G', [DS.data Study filesep Run filesep 'Raw_' Run '_G.tiff'], ...
    'B', [DS.data Study filesep Run filesep 'Raw_' Run '_B.tiff']);

fOutput = struct('Raw', [DS.data Study filesep Run filesep Run '.tiff'], ...
    'R', [DS.data Study filesep Run filesep Run '_R.tiff'], ...
    'G', [DS.data Study filesep Run filesep Run '_G.tiff'], ...
    'B', [DS.data Study filesep Run filesep Run '_B.tiff']);

% =========================================================================

% --- File handles --------------------------------------------------------

Images = struct();
Output = struct();

% Raw
if exist(fImages.Raw, 'file')
    Images.Raw = Tiff(fImages.Raw, 'r');
    Output.Raw = Tiff(fOutput.Raw, 'w');
else
    warning('No Raw file found. Aborting.\n');
    return
end

% Red
if exist(fImages.R, 'file')
    Images.R = Tiff(fImages.R, 'r');
    Output.R = Tiff(fOutput.R, 'w');
else
    Images.R = [];
    Output.R = [];
end

% Green
if exist(fImages.G, 'file')
    Images.G = Tiff(fImages.G, 'r');
    Output.G = Tiff(fOutput.G, 'w');
else
    Images.G = [];
    Output.G = [];
end

% Blue
if exist(fImages.B, 'file')
    Images.B = Tiff(fImages.B, 'r');
    Output.B = Tiff(fOutput.B, 'w');
else
    Images.B = [];
    Output.B = [];
end

% --- Processing ----------------------------------------------------------

% --- Get infos

info = imfinfo(fImages.Raw);
nImg = numel(info);
Height = info(1).Height;
Width = info(1).Width;

% --- Tag structure

tagstruct = struct('ImageLength', Height, ...
    'ImageWidth', Width, ...
    'Photometric', Tiff.Photometric.MinIsBlack, ...
	'BitsPerSample', 8, ...
	'SamplesPerPixel', 1, ...
	'PlanarConfiguration', Tiff.PlanarConfiguration.Chunky, ...
    'Software', mfilename);

% --- Compute

fprintf('Computing .');
tic

for i = 1:nImg

    % --- Load images
    
    % Raw
    Images.Raw.setDirectory(i);
    Raw = read(Images.Raw);
    if isa(Raw, 'uint16'), Raw = uint8(Raw/255); end
    
    if ~isempty(Images.R)
        Images.R.setDirectory(i);
        R = read(Images.R);
        if isa(R, 'uint16'), R = uint8(R/255); end
    end
    
    if ~isempty(Images.G)
        Images.G.setDirectory(i);
        G = read(Images.G);
        if isa(G, 'uint16'), G = uint8(G/255); end
    end
    
    if ~isempty(Images.B)
        Images.B.setDirectory(i);
        B = read(Images.B);
        if isa(B, 'uint16'), B = uint8(B/255); end
    end
    
    % --- Drift correction
    
    if i==1 || ~ismember("drift", operations)
        
        Img = Raw;
        
    else
        
        % Compute correlation
        [dx, dy] = IP.fcorr(Img, Raw);
        
        % Compensate the drift
        Img = imtranslate(Raw, -[dx dy]);
        Img(Img==0) = median(Raw(:));
        
        if ~isempty(Images.R)
            R = imtranslate(R, -[dx dy]); 
            R(R==0) = median(R(:));
        end
        
    end
        
    % --- Normalizations
    
    if ismember("norm_R", operations)
        
        if i==1
            refRaw = sum(double(Img(:)));
            refR = sum(double(R(:)));
        else
            R = double(R);
            R = R/sum(R(:))*refR*(sum(double(Img(:)))/refRaw);
            R = uint8(R);
        end
    end
    
    % --- Save
    
    setTag(Output.Raw, tagstruct);
    write(Output.Raw, Img);
    writeDirectory(Output.Raw);
    
    if ~isempty(Images.R)
        setTag(Output.R, tagstruct);
        write(Output.R, R);
        writeDirectory(Output.R);
    end
    
    if ~isempty(Images.G)
        setTag(Output.G, tagstruct);
        write(Output.G, G);
        writeDirectory(Output.G);
    end
    
    if ~isempty(Images.B)
        setTag(Output.B, tagstruct);
        write(Output.B, B);
        writeDirectory(Output.B);
    end
    
    % --- Display
    
    imshow(Img);
    title("t = " + i);
    drawnow limitrate
    
    if ~mod(i, 10), fprintf('.'); end
    
end

fprintf(' %.02f sec\n', toc);

% --- Finish --------------------------------------------------------------

if ~isempty(Images.R), close(Images.R); end
if ~isempty(Images.G), close(Images.G); end
if ~isempty(Images.B), close(Images.B); end

if ~isempty(Output.R), close(Output.R); end
if ~isempty(Output.G), close(Output.G); end
if ~isempty(Output.B), close(Output.B); end
