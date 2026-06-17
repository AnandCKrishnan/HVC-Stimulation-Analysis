function [] = GenerateWavFilesForIntanAnalogChannels()
% ========================================================================
% Author: Anand C Krishnan
% Last updated: 02-02-2026
%
% Description:
% This function converts Intan (.rhd) files into .wav audio files by
% extracting analog input channels (e.g., microphone signals).
% 
% Workflow:
% 1. Reads all .rhd files in the current directory
% 2. Extracts the first analog channel (assumed microphone input)
% 3. Normalizes the signal from Intan voltage range (0–3.3 V)
%    to WAV-compatible range (-1 to 1)
% 4. Saves output .wav files in a subfolder 'WavFiles'
% 
% Requirements:
% - read_Intan_RHD2000_file_M function
% 
% Usage:
%   GenerateWavFilesForIntanAnalogChannels()
%
% 
% Written by Anand C Krishnan (2026)
% For use in the Rajan Lab, IISER Pune
%
%
% Disclaimer:
% This MATLAB script was written entirely by the author (Anand C Krishnan).
% Generative AI tools were used solely to formalize the code comments for 
% improved readability and documentation. AI use was limited to enhancing 
% the accompanying comments and documentation.
%
% This code is intended for research use within the lab.
% Please acknowledge the author if this code contributes to your work.
% ========================================================================


% -------------------------- Display authorship --------------------------
fprintf('\n=============================================\n');
fprintf(' Function: GenerateWavFilesForIntanAnalogChannels\n');
fprintf(' Author  : Anand C Krishnan\n');
fprintf(' Lab     : Rajan Lab, IISER Pune\n');
fprintf(' Year    : 2026\n');
fprintf('=============================================\n\n');


%% Get list of .rhd files
Files = dir('*.rhd');

nFiles = length(Files);
fprintf('Found %d .rhd files.\n', nFiles);

if isempty(Files)
    error('No .rhd files found in the current directory.');
end

%% Create output directory
outputDir = 'WavFiles';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

%% Initialize waitbar
f = waitbar(0, 'Starting...', 'Name', 'Converting Files');
set(f, 'WindowStyle', 'modal');
pause(0.5);

%% Main loop
maxVoltage = 3.3; % Intan ADC range (Volts)

for i = 1:nFiles

    % --- Load Intan data ---
    [t_board_adc, board_adc_channels, board_adc_data, Fs] = ...
        read_Intan_RHD2000_file_M(Files(i).name);
    
    if isempty(board_adc_data)
        warning('No ADC data in file: %s. Skipping.', Files(i).name);
        continue;
    end

    % --- Extract analog channel (Mic 1 assumed) ---
    SongData_Mic1 = board_adc_data(1, :);
    
    % --- Normalize signal ---
    % Step 1: Convert from voltage (0–3.3 V) to 0–1 range
    NorSongData_Mic1 = SongData_Mic1 / maxVoltage;

    % Step 2: Convert from 0–1 to -1 to 1 (WAV standard)
    NorSongData_Mic1 = (NorSongData_Mic1 * 2) - 1;
    
    % --- Save WAV file ---
    outputFileName = fullfile(outputDir, ...
        [Files(i).name(1:end-4) '.wav']);
    
    audiowrite(outputFileName, ...
        NorSongData_Mic1, Fs.board_adc_sample_rate);
    
    % --- Update progress ---
    waitbar(i/nFiles, f, ...
        sprintf('Processing %d/%d: %s', ...
        i, nFiles, Files(i).name));
end

%% Finish
waitbar(1, f, 'Finishing...');
pause(0.5);
close(f);

fprintf('\nAll WAV files saved in:\n%s\n\n', outputDir);

end