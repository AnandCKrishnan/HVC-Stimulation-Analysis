function PlotStimulusOnSpectrogram()
% ========================================================================
% Author: Anand C Krishnan
% Last updated: 10-03-2026
% 
% Description:
% This function overlays Intan digital input signals on top of 
% spectrograms generated from aligned .wav files.
% 
% Workflow:
% 1. User selects:
%    - Directory containing Intan (.rhd) files
%    - Directory containing aligned .wav files
% 2. For each pair of files:
%    - Spectrogram of the .wav file is plotted
%    - Corresponding Intan digital input is overlaid
% 3. Figures are saved in a subfolder 'OverlayedPlots'
% 
% Requirements:
% - PlotSpectrogram function
% - read_Intan_RHD2000_file_M function
% 
% Usage:
%   PlotStimulusOnSpectrogram()
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
fprintf(' Function: PlotStimulusOnSpectrogram\n');
fprintf(' Author  : Anand C Krishnan\n');
fprintf(' Lab     : Rajan Lab, IISER Pune\n');
fprintf(' Year    : 2026\n');
fprintf('=============================================\n\n');


%% Select directories
h = msgbox('Select the Intan (.rhd) file directory', 'Stimuli files');
uiwait(h);
IntanFilePath = uigetdir(pwd, 'Select the folder');

if IntanFilePath == 0
    error('No Intan folder selected');
end

h = msgbox('Select the Intan aligned .wav file directory', '.wav files');
uiwait(h);
WavFilePath = uigetdir(pwd, 'Select the folder');

if WavFilePath == 0
    error('No WAV folder selected');
end

%% Get file lists
IntanFiles = dir(fullfile(IntanFilePath, '*.rhd'));
WavFiles   = dir(fullfile(WavFilePath, '*.wav'));

if isempty(IntanFiles)
    error('No .rhd files found in selected Intan folder.');
end

if isempty(WavFiles)
    error('No .wav files found in selected WAV folder.');
end

IntanNames = {IntanFiles.name};
WavNames   = {WavFiles.name};

% Basic check
if length(IntanNames) ~= length(WavNames)
    warning('Number of .rhd and .wav files do not match. Proceeding with minimum length.');
end

nFiles = min(length(IntanNames), length(WavNames));
fprintf('Processing %d file pairs.\n', nFiles);

%% Create output directory
outputDir = fullfile(WavFilePath, 'OverlayedPlots');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

%% Initialize waitbar
f = waitbar(0, 'Starting...', 'Name', 'Processing Files');
set(f, 'WindowStyle', 'modal');
pause(0.5);

%% Main loop
for i = 1:nFiles
    
    fprintf('Pairing: %s <-> %s\n', IntanNames{i}, WavNames{i});

    % --- Plot spectrogram ---
    PlotSpectrogram(WavFilePath, WavNames{i}, 'wav', 'hot');
    hold on;
    
    % --- Load Intan data ---
    [t_board_adc, ~, ~, ~, board_dig_in_data] = ...
        read_Intan_RHD2000_file_M(fullfile(IntanFilePath, IntanNames{i}));
    
    % Time alignment
    Time_data = t_board_adc - t_board_adc(1);
  
    if isempty(board_dig_in_data)
        warning('No digital input in file: %s. Skipping overlay.', IntanNames{i});
        Dig_data = [];
    else
        Dig_data = board_dig_in_data;
    end
    
    % --- Overlay digital signal ---
    if ~isempty(Dig_data)
        yyaxis right;
        plot(Time_data, Dig_data, '-', ...
            'Color', [0 0 0 0.2], 'LineWidth', 1);

        ylim([0 10]);
        ylabel('Stimulus');
    end
    
    % Formatting
    set(gca, 'FontSize', 15, 'FontName', 'Times New Roman');
    
    % --- Save figure ---
    savefig(fullfile(outputDir, [WavNames{i} '_Overlayed.fig']));
    close;
    
    % --- Update progress ---
    waitbar(i/nFiles, f, ...
    sprintf('Processing %d/%d: %s', i, nFiles, WavNames{i}));
end

%% Finish
waitbar(1, f, 'Finishing...');
pause(0.5);
close(f);

fprintf('\nAll files saved in:\n%s\n\n', outputDir);

end