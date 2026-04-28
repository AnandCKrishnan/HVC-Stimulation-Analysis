
# HVC Stimulation Analysis

<br>

## Overview
This repository contains MATLAB scripts for processing and analyzing data from the HVC stimulation project in the Rajan Lab, IISER Pune.

<br>

## Scripts

### 1. GenerateWavFilesForIntanAnalogChannels
Converts Intan `.rhd` files into `.wav` audio files.

**Description:**
This function converts Intan (.rhd) files into .wav audio files by
extracting analog input channels (e.g., microphone signals).

Workflow:
1. Reads all .rhd files in the current directory
2. Extracts the first analog channel (assumed microphone input)
3. Normalizes the signal from Intan voltage range (0–3.3 V)
   to WAV-compatible range (-1 to 1)
4. Saves output .wav files in a subfolder 'WavFiles'

Requirements:
- read_Intan_RHD2000_file_M function

Output:
- Intan generated WAV files saved in:<br>
  [IntanRHDFiles]/WavFiles/
  
Usage:<br>
  GenerateWavFilesForIntanAnalogChannels()


---
<br>

### 2. GenerateIntanAlignedWavFiles
Convert and downsample PyCBS .wav files to Intan time frame.

**Description:**
This script performs temporal alignment between PyCBS and Intan
recordings based on syllable onset information extracted from both
systems. It computes the timing offset between the first labelled
vocalisation in each dataset and uses this to align PyCBS audio to
the Intan recording timeline.

The aligned PyCBS audio is then streamed and adjusted in segments to
match the duration of Intan recordings, and finally saved as new WAV
files in an output directory.


Workflow:
1. User selects:
   - Intan note file directory
   - PyCBS note file directory
2. Loads syllable onset times from both systems
3. Computes timing offset between PyCBS and Intan
4. Applies temporal correction (lag/lead adjustment)
5. Streams and aligns WAV data segment-by-segment
6. Writes aligned PyCBS audio into Intan timeline

Requirements:
- GetData function (for loading WAV files)
- .mat files containing 'onsets'

Output:
- Aligned WAV files saved in:<br>
  [PyCBSFiles]/IntanAlignedPyCBSFiles/

Usage:<br>
  GenerateIntanAlignedWavFiles()
  
Notes:
- Alignment assumes consistent ordering of files
- Sampling frequency is fixed at 30000 Hz for output

---
<br>


### 3. PlotStimulusOnSpectrogram
Overlays Intan digital input signals onto spectrograms generated from aligned `.wav` files.


**Description:**
This function overlays Intan digital input signals on top of 
spectrograms generated from aligned .wav files.

Workflow:
1. User selects:
   - Directory containing Intan (.rhd) files
   - Directory containing aligned .wav files
2. For each pair of files:
   - Spectrogram of the .wav file is plotted
   - Corresponding Intan digital input is overlaid
3. Figures are saved in a subfolder 'OverlayedPlots'

Requirements:
- PlotSpectrogram function
- read_Intan_RHD2000_file_M function

Output:<br>
- Spectrogram overlaid with stimulus saved in:<br>
  [WavFileDirectory]/OverlayedPlots/

Usage:<br>
  PlotStimulusOnSpectrogram()

---
<br>


### 4. PlotEvokedVocalizationAllSpectrograms
Plot all stimulus aligned spectrograms one below the other.

**Description:**
This script extracts digital input signals from Intan (.rhd) files,
detects stimulus bursts, and aligns them with corresponding audio
recordings (.wav). It then plots spectrograms of evoked vocalizations
around each detected burst.

User-defined experiment parameters (bird name, current, frequency, duration)
and data directories are obtained via a GUI interface.

Workflow:
1. User inputs experiment details via GUI:
   - Bird name
   - Stimulation current (µA)
   - Frequency (Hz)
   - Pulse duration (ms)
   - Directory containing Intan (.rhd) files
   - Directory containing aligned .wav files
2. Intan files are read and concatenated:
   - Extract time and digital input signals
3. Digital input is cleaned and processed:
   - Remove short noise spikes
   - Detect pulse onsets
   - Group pulses into bursts
4. Corresponding .wav files are loaded and concatenated
5. For each detected burst:
   - Extract audio segment around burst
   - Compute spectrogram
   - Plot aligned spectrograms across trials
6. Final figure formatting and visualization

Requirements:
- read_Intan_RHD2000_file_M function
- scale_spect function
- disp_idx_spect function
- getExperimentInputs

Usage:
  PlotEvokedVocalizationAllSpectrograms()

---
<br>


### 5. PlotEvokedVocalizationAvgSpectrograms
Plot avg stimulus aligned spectrogram with avg amplitude profile and avg pressure signal (if available).


**Description:**
This function processes Intan (.rhd) and aligned audio (.wav) files to:
- Detect stimulation bursts from digital input signals
- Extract corresponding vocalization and respiration signals
- Compute spectrograms of evoked vocalizations
- Calculate and plot averaged spectrogram, amplitude envelope, 
  and respiration (pressure) signals across trials

User-defined experiment parameters (bird name, current, frequency, duration)
and data directories are obtained via a GUI interface.


Workflow:
1. User inputs experiment details via GUI:
   - Bird name
   - Stimulation current (µA)
   - Frequency (Hz)
   - Pulse duration (ms)
   - Directory containing Intan (.rhd) files
   - Directory containing aligned .wav files
2. Intan data is loaded and concatenated:
   - Time, digital input, and pressure (ADC channel)
3. Digital signal processing:
   - Remove noise spikes
   - Detect pulse onsets
   - Group pulses into bursts
4. Audio data is loaded and concatenated
5. For each burst:
   - Extract audio and pressure segments
   - Compute spectrogram
   - Extract amplitude envelope
6. Across bursts:
   - Compute mean and SEM for:
       • Spectrogram
       • Amplitude profile
       • Pressure signal
7. Plot:
   - Average spectrogram
   - Average amplitude profile (± SEM)
   - Average pressure trace (± SEM)

Requirements:
- read_Intan_RHD2000_file_M function
- scale_spect function
- disp_idx_spect function
- getExperimentInputs

Usage:
  PlotEvokedVocalizationAvgSpectrograms()

  
---
<br>

### Written by Anand C Krishnan (2026)


These MATLAB scripts are intended for research use within Rajan Lab, IISER Pune.<br>
Please acknowledge the author if this code contributes to your work.
