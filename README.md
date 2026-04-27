
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

### Written by Anand C Krishnan (2026)


These MATLAB scripts are intended for research use within Rajan Lab, IISER Pune.<br>
Please acknowledge the author if this code contributes to your work.
