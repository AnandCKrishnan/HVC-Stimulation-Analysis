function [] = GenerateIntanAlignedPyCBSWavFiles()
% ========================================================================
% Author: Anand C Krishnan
% Last updated: 10.03.2026
%
% Description:
% This script performs temporal alignment between PyCBS and Intan
% recordings based on syllable onset information extracted from both
% systems. It computes the timing offset between the first labelled
% vocalisation in each dataset and uses this to align PyCBS audio to
% the Intan recording timeline.
% 
% The aligned PyCBS audio is then streamed and adjusted in segments to
% match the duration of Intan recordings, and finally saved as new WAV
% files in an output directory.
% 
% 
% Workflow:
% 1. User selects:
%    - Intan note file directory
%    - PyCBS note file directory
% 2. Loads syllable onset times from both systems
% 3. Computes timing offset between PyCBS and Intan
% 4. Applies temporal correction (lag/lead adjustment)
% 5. Streams and aligns WAV data segment-by-segment
% 6. Writes aligned PyCBS audio into Intan timeline
% 
% Requirements:
% - GetData function (for loading WAV files)
% - .mat files containing 'onsets'
% 
% Output:
% - Aligned WAV files saved in:
%   IntanAlignedPyCBSFiles/
% 
% Notes:
% - Alignment assumes consistent ordering of files
% - Sampling frequency is fixed at 30000 Hz for output
%
% Written by Anand C Krishnan (2026)
% Rajan Lab, IISER Pune
%
%
% Disclaimer:
% This MATLAB script was written entirely by the author (Anand C Krishnan).
% Generative AI tools were used solely to formalize the code comments for 
% improved readability and documentation. AI use was limited to enhancing 
% the accompanying comments and documentation.
%
% ========================================================================


% -------------------------- Display authorship --------------------------
fprintf('\n=============================================\n');
fprintf(' Function: GenerateIntanAlignedPyCBSWavFiles\n');
fprintf(' Author  : Anand C Krishnan\n');
fprintf(' Lab     : Rajan Lab, IISER Pune\n');
fprintf(' Year    : 2026\n');
fprintf('=============================================\n\n');


%% Select directories
h = msgbox('Select the Intan note file directory', 'Intan note files');
uiwait(h);
IntanNoteFiles = uigetdir(pwd, 'Select the folder');

h = msgbox('Select the PyCBS note file directory', 'PyCBS note files');
uiwait(h);
PyCBSNoteFiles = uigetdir(pwd, 'Select the folder');


%% Load PyCBS onset data
cd(PyCBSNoteFiles);
files = dir('*.mat');
PyCBSNames = {files.name};

load(PyCBSNames{1});
PyCBSOnset = onsets;


%% Load Intan onset data
cd(IntanNoteFiles);
files = dir('*.mat');
IntanNames = {files.name};

load(IntanNames{1});
IntanOnset = onsets;


%% Compute onset difference (temporal offset between systems)
OnsetDiff = PyCBSOnset - IntanOnset;
ActualLag = round(OnsetDiff);


%% Display alignment direction
if (ActualLag > 0)
    disp(['PyCBS leads Intan by ' num2str(ActualLag) ' ms']);
else
    disp(['Intan leads PyCBS by ' num2str(abs(ActualLag)) ' ms']);
end


%% Prepare file paths
PyCBSPath = fileparts(PyCBSNoteFiles);
IntanPath = fileparts(IntanNoteFiles);

IntanWavFiles = dir(fullfile(IntanPath, '*.wav'));
PyCBSWavFiles = dir(fullfile(PyCBSPath, '*.wav'));

PyCBSFiles = string({PyCBSWavFiles.name});
IntanFiles = string({IntanWavFiles.name});

%% --- Safety check: require more than 2 PyCBS wav files ---
if length(PyCBSFiles) <= 2
    error('Script aborted: At least 3 PyCBS .wav files are required. Found %d.', ...
        length(PyCBSFiles));
end


%% Initialize buffers
Fs = 30000; % Target sampling rate

cd(PyCBSPath);
mkdir IntanAlignedPyCBSFiles;


PyCBSData = [];
IntanData = [];


%% Progress bar
f = waitbar(0, 'Starting');
pause(0.5);


%% Main alignment loop
for i = 1:length(IntanFiles)
    
    % --- Load Intan WAV segment ---
    [Data, Fs44] = GetData(IntanPath, IntanFiles{i}, 'wav', 1);
    IntanData = [IntanData; Data];

    
    % --- Initialize PyCBS stream on first iteration ---
    if i == 1
        
        % Load initial PyCBS segments
        for j = 1:3
            [Data, Fs44] = GetData(PyCBSPath, PyCBSFiles{j}, 'wav', 1);
            
            % Resample to match Intan sampling rate
            Data = resample(Data, Fs, Fs44);
            PyCBSData = [PyCBSData; Data];
        end
        
        NumCn = j;

        % --- Apply lag correction ---
        if ActualLag > 0
            % PyCBS leads → remove initial samples
            PyCBSData(1:abs((ActualLag/1000)*Fs)-1) = [];
        end

        if ActualLag < 0
            % Intan leads → pad PyCBS with zeros
            Temp = zeros(1, abs((ActualLag/1000)*Fs)-1);
            PyCBSData = [Temp'; PyCBSData];
        end
    end
    

    %% Ensure PyCBS buffer matches Intan length
    while length(PyCBSData) < length(IntanData)

        NumCn = NumCn + 1;

        % --- STOP IF NO MORE FILES ---
        if NumCn > length(PyCBSFiles)
            warning('PyCBS files exhausted. Padding remaining signal with zeros.');

            missingLen = length(IntanData) - length(PyCBSData);
            PyCBSData = [PyCBSData; zeros(missingLen, 1)];
            break;
        end

        % --- Load next file ---
        [Data, Fs44] = GetData(PyCBSPath, PyCBSFiles{NumCn}, 'wav', 1);
        Data = resample(Data, Fs, Fs44);

        PyCBSData = [PyCBSData; Data];
    end
     

    %% Write aligned output file
    cd(PyCBSPath);
    
    audiowrite( ...
        ['IntanAlignedPyCBSFiles/' IntanFiles{i} '_Aligned.wav'], ...
        PyCBSData(1:length(IntanData)), ...
        Fs);

    % Remove written portion from buffer
    PyCBSData(1:length(IntanData)) = [];
    IntanData = [];
    

    %% Update progress
    waitbar(i/length(IntanFiles), f, ...
        sprintf('Progress: %d of %d', i, length(IntanFiles)));
end


%% Finish
waitbar(1, f, 'Finishing');
pause(0.5);
close(f);

end