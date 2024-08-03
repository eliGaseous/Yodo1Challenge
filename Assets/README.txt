This project serves as a comprehensive example on integrating custom native plugins with Unity, with specific focus on three key aspects:

1) Creating Custom .mm Scripts: How to write and integrate .mm files using C++ or Swift.

2)Integrating Custom Frameworks: Exporting your framework from xCode and the ease for which it can be integrated into your Unity project.

3) Accessing Plugins and Frameworks: Detailed example on using the DLLImport attribute to utilize the plugins and frameworks in Unity.

•Plugin Functionality:

The plugin developed for this project tracks CPU and Memory usage.
Due to the lack of a direct API from Apple for GPU usage data, this project includes a custom framework leveraging the IOKit to monitor GPU usage.

•UI Compatibility:

The project also demonstrates the use of a SafeZone object to adjust the screen layout. This ensures that UI elements such as text and interactive objects remain visible and are not obscured by device-specific overlays like the iOS speaker notch.