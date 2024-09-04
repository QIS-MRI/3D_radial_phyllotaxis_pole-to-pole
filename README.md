# 3D Radial Phyllotaxis Trajectories

This repository contains implementations of three different 3D radial phyllotaxis trajectories: the **Original Phyllotaxis**, **Pole-to-Pole Phyllotaxis**, and **Continuous Phyllotaxis**. Each method has unique characteristics that impact the sampling of k-space.

## Trajectories

### 1. Original phyllotaxis
The original phyllotaxis pattern from Piccini et al. ensures uniform coverage of the k-space, distributing points evenly on a spherical surface. 

### 2. Pole-to-pole phyllotaxis
In this trajectory, the starting points of the spokes are located on both hemispheres, and the trajectory follows a path from one pole to the other. 

### 3. Continuous phyllotaxis
The continuous phyllotaxis trajectory builds upon the pole-to-pole approach by adjusting the path so that the angular position increases continuously from one pole to the other before returning to its starting point. This design further minimizes eddy current effects by avoiding jumps at the start of each segment.

## Visualization

The following figures illustrate each of the three methods:

### Original phyllotaxis
![Original Phyllotaxis](trajectory_original.png)

### Pole-to-pole phyllotaxis
![Pole-to-Pole Phyllotaxis](trajectory_poletopole.png)

### Continuous phyllotaxis
![Continuous Phyllotaxis](trajectory_continuous.png)

## Code
The repository contains MATLAB code to generate and plot these trajectories. It requires to set the desired number of readout points, interleaves (shots), and segments.

## References
Peper et al., 2024 'Pole-to-pole spiral phyllotaxis trajectory design improves image quality and quantitative parametric maps of 3D radial MRI'
