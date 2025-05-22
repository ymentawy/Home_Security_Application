# NeuroVison - Technical Setup Guide

## System Overview

This home security system consists of two main components:
1. Edge Device (Raspberry Pi with connected cameras)
2. Mobile Application

This guide is intended for technical users working with the development/prototype version of the system.

## Prerequisites

- Raspberry Pi with cameras (main camera and PTZ camera) properly connected
- Mobile device for running the application
- Both devices must be connected to the same local network
- Python installed on the Raspberry Pi

## Setup Instructions

### Mobile Application Setup

1. Download and install the mobile application on your device
2. Launch the application and create an account/login
3. Navigate to the Settings page
4. Update the Raspberry Pi's IP configuration:
   - The IP will be automatically updated for both stream services (notifications and recordings)
   - This configuration affects both camera streams

### Raspberry Pi Setup

#### 1. Main Server Setup
1. Navigate to the directory where servers.py is on your Raspberry Pi
2. Run the main server file:
   ```bash
   python servers.py
   ```
   This will automatically open three terminal windows, each hosting a different service:
   - Main camera stream server
   - PTZ camera stream and controls server
   - Recordings playback server

#### 2. AI Model and Notification Service
1. In a new terminal, run:
   ```bash
   python ptz.py
   ```
   This initiates:
   - All AI models on the PI
   - The notification server
   - When the (Human Activity Recognition) HAR model detects an anomaly, the notification server automatically sends alerts to the mobile application

## Important Notes

- **Network Requirements**: Both the Raspberry Pi and mobile device MUST be connected to the same local network
- **Development Status**: This is a prototype version intended for testing purposes and is not yet configured for deployment
- **Local Network Limitation**: The system currently operates within a local network environment only

## Troubleshooting

If you experience connection issues:
1. Verify both devices are on the same network
2. Check if the IP configuration in the mobile app matches the Raspberry Pi's IP
3. Ensure all servers are running properly (3 from servers.py and 1 from ptz.py)
4. Check terminal outputs for any error messages

## System Architecture

```
Mobile Application <----> Local Network <----> Raspberry Pi
                                             |-- servers.py
                                             |   |-- Main Camera Stream Server
                                             |   |-- PTZ Camera Server
                                             |   |-- Recordings Server
                                             |
                                             |-- ptz.py
                                                 |-- AI Model (HAR)
                                                 |-- Notification Server
```

For additional technical details or development queries, please refer to the source code documentation. 
