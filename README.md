# MC10Stroke
Detecting spasticity and AR from MC10 sensors 

Data Pipeline:
- Data collected from MC10 devices (found on Z:\Stroke MC10\) 
    is divided into indivudal activities and processed (resampling and filtering)
    [PrepMC10Data.m]
- Data is labeled manually for all subjects using the GUI [LabellingTool.m]
    - Select an inactive period at least 2s long
    - Click threshold button to plot threshold for active portions of signal
    - Label MAS as either inactive or spastic from the beginning of movement
    - Label VCM and MVC as non-spastic if subject had spasticitiy

