# FreeTuner - iOS Tuner App Specifications

## Overview
FreeTuner is an iOS tuner application that detects pitch in real-time using microphone input and displays the corresponding musical note with tuning accuracy feedback.

## Core Features

### Audio Processing
- Real-time pitch detection from microphone input
- Audio input permission handling
- Low-latency audio processing for responsive tuning

### Note Detection & Display
- Map detected frequencies to musical notes (A, B, C, D, E, F, G)
- Display current detected note prominently
- Show frequency value in Hz
- Visual indicator for tuning accuracy (sharp/flat/in-tune)

### Customization Settings
- **Concert A Frequency**: Adjustable reference pitch (default: 440 Hz)
- **Note Naming**: Toggle between A B C and Do Re Mi notation
- **Note Order**: High to low or low to high display order
- **Accidental Style**: Sharp (#) or flat (♭) notation preference
- **Transposition**: Adjust displayed notes by semitones
- **Tuning Tolerance**: Configurable cents tolerance for "in-tune" indicator
- **Temperament**: Support for equal temperament and other tuning systems
- **Key Selection**: Musical key context for temperament calculations

### User Interface
- Clean, modern iOS design following Apple's Human Interface Guidelines
- Dark mode support
- Responsive layout for different device orientations
- Large, readable note display
- Intuitive settings interface
- Visual feedback for audio input status

## Technical Requirements

### Platform
- iOS 17.0+
- SwiftUI framework
- AVFoundation for audio processing
- Core Audio for real-time pitch detection

### Permissions
- Microphone access permission request
- Privacy description for microphone usage

### Performance
- Sub-100ms latency for pitch detection
- Smooth UI updates (60fps)
- Efficient battery usage during continuous audio processing

## Development Phases

### Phase 1: Core Audio & Pitch Detection
- Implement microphone input handling
- Basic pitch detection algorithm
- Frequency to note mapping

### Phase 2: UI Implementation
- Main tuning display interface
- Settings panel
- Dark mode support

### Phase 3: Advanced Features
- Customization options
- Temperament system support
- Transposition functionality

### Phase 4: Polish & Testing
- Performance optimization
- UI/UX refinements
- Comprehensive testing across devices
