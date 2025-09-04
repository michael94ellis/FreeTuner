# Tuner Gauge: Chromatic Tuner
## An iOS App

## Overview
Tuner Gauge is an iOS chromatic tuner app that provides real-time pitch detection with professional-grade accuracy. Built with SwiftUI and leveraging Apple's Accelerate framework for high-performance audio processing, TunerGauge offers musical enthusiasts a valuable tuning solution with customizable reference standards and easy to understand visualization features.

## 📱 Screenshots

| Device | Screenshot | Description |
|--------|------------|-------------|
| iPad | <img src="screenshots/iPad_screenshot_2.png" width="140" alt="iPad Screenshot 2"> | Main tuner interface with circular display |
| iPad | <img src="screenshots/iPad_screenshot_1.png" width="140" alt="iPad Screenshot 1"> |Settings and configuration view |
| iPhone | <img src="screenshots/iPhone_screenshot_3.png" width="140" alt="iPhone Screenshot 1"> | Main tuner interface on iPhone |
| iPhone | <img src="screenshots/iPhone_screenshot_2.png" width="140" alt="iPhone Screenshot 2"> | A4 frequency picker interface |
| iPhone | <img src="screenshots/iPhone_screenshot_4.png" width="140" alt="iPhone Screenshot 4"> | Expanded pitch graph view |
| iPhone | <img src="screenshots/iPhone_screenshot_5.png" width="140" alt="iPhone Screenshot 5"> | Decibel meter and signal monitoring |

## 🎵 Core Features

### Real-Time Pitch Detection
- **Advanced FFT Analysis**: Uses Apple's Accelerate framework with 2048-point FFT for precise frequency detection
- **Parabolic Interpolation**: Improves frequency resolution beyond FFT bin limitations for sub-Hz accuracy
- **Noise Threshold Filtering**: Intelligent noise gate prevents false detections
- **Frequency Range**: Supports 69.5 Hz to 4108 Hz - nearly full piano range, help wanted to reach full piano range / higher with accuracy
- **Low Latency**: Optimized for responsive real-time performance

### Visual Tuning Interface
- **Circular Tuner Display**: Intuitive clock-face gauge design with note markers around the perimeter
- **Tuning Needle**: Real-time visual indicator showing cents deviation with color coding
- **Note Highlighting**: Active note prominently displayed with color-coded accuracy
- **Octave Support**: Full octave range display with clear visual hierarchy

### Audio Monitoring
- **Decibel Meter**: Real-time signal strength monitoring with visual bar meter
- **Peak Tracking**: Tracks and displays peak levels with decay animation
- **Color-Coded Levels**: 
  - 🟢 Green: Optimal input level (-60 to -40 dB)
  - 🟡 Yellow: Good level (-40 to -20 dB)
  - 🟠 Orange: High level (-20 to -10 dB)
  - 🔴 Red: Clipping risk (-10 to 0 dB)
- **Collapsible Interface**: Expandable meter with detailed information tooltips

### Pitch History & Analysis
- **Real-Time Graph**: Live frequency tracking over time using SwiftUI Charts
- **Configurable History**: Adjustable data point limit (25-1000 points)
- **Average Frequency**: Running average calculation
- **Stability Analysis**: Automatic pitch stability assessment
- **Collapsible Display**: Expandable graph interface

### Reference Standard Customization
- **A4 Frequency Picker**: Customizable A4 reference frequency (1-990 Hz)
- **Historical Standards**: Pre-configured frequencies for different musical periods:
  - Modern Standard (A440)
  - Baroque (A415)
  - Classical (A430)
  - Verdi (A432)
  - Historical (A409)
  - Early Music (A392)
  - Low A4 (A400)
  - High A4 (A480)
- **MIDI Reference Note**: Configurable MIDI reference note (0-127)
- **Common MIDI References**: Pre-configured for popular reference notes:
  - A4 (Standard) - MIDI 69
  - C4 (Middle C) - MIDI 60
  - A3 - MIDI 57
  - C5 - MIDI 72
  - G4 - MIDI 67
  - D4 - MIDI 62

### Audio Playback for Different Pitches
- **Reference Tone Generator**: Built-in tone generator for tuning reference
- **Multiple Waveforms**: Sine, Square, Triangle, and Sawtooth waveforms
- **Real-Time Frequency Control**: Adjustable frequency with live playback
- **Continuous Playback**: Sustained tone generation for extended tuning sessions

### User Interface Features
- **iPad Optimization**: Enhanced font sizes and layout for iPad users
- **Dark Mode Support**: Full dark mode compatibility
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Comprehensive Accessibility**: Full VoiceOver support with dynamic content handling
- **Gesture Controls**: Tap to start/stop listening
- **Collapsible Sections**: Expandable interface elements for cleaner layout

### Settings & Customization
- **Display Options**: Toggle visibility of pitch graph, signal strength, and reference labels
- **Pitch History Configuration**: Adjustable maximum history size
- **Persistent Settings**: All preferences saved using @AppStorage
- **Collapsible Sections**: Organized settings with expandable categories

## 🛠 Technical Architecture

### Audio Processing Pipeline
1. **Audio Input**: AVAudioEngine with microphone input
2. **FFT Analysis**: 2048-point FFT using Accelerate framework
3. **Frequency Detection**: Peak detection with parabolic interpolation
4. **Note Conversion**: Equal temperament calculation with cents deviation
5. **Real-Time Updates**: Async stream processing for responsive UI

### Key Components
- **AudioInputManager**: Handles audio session and real-time processing
- **PitchAnalyzer**: FFT-based frequency analysis with interpolation
- **NoteConverter**: Frequency-to-note conversion with customizable references
- **PitchPlayer**: Reference tone generator with multiple waveforms
- **TunerView**: Main interface with circular tuner display
- **SettingsView**: Comprehensive settings and reference configuration

### Performance Optimizations
- **Accelerate Framework**: Hardware-accelerated FFT processing
- **Async Streams**: Non-blocking audio processing
- **Memory Management**: Efficient buffer handling and cleanup
- **UI Updates**: MainActor coordination for smooth interface updates

## 📱 Platform Support

### iOS Requirements
- **Minimum iOS Version**: iOS 17.0+
- **Device Support**: iPhone and iPad
- **Permissions**: Microphone access required
- **Hardware**: Optimized for devices with A-series chips

### iPad Enhancements
- **Larger Fonts**: Enhanced typography for better readability
- **Adaptive Layouts**: Optimized spacing and sizing
- **Touch Interface**: Improved touch targets and gestures

## 🎨 Design Philosophy

### User Experience
- **Intuitive Interface**: Clock-face like gauge tuner design familiar to many people
- **Visual Feedback**: Color-coded accuracy indicators
- **Responsive Design**: Real-time updates on all displays

### Professional Standards
- **Musical Accuracy**: Equal temperament with precise cents calculation
- **Historical Support**: Multiple tuning standards for period performance
- **Professional Tools**: Reference tone generator and signal monitoring
- **Data Visualization**: Comprehensive pitch analysis and history
