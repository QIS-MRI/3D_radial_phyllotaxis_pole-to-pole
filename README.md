# 3D Radial Phyllotaxis Trajectories

This repository contains implementations of three different 3D radial phyllotaxis trajectories: the **Original Phyllotaxis**, **Pole-to-Pole Phyllotaxis**, and **Continuous Phyllotaxis**.  
Each method has unique characteristics that impact the sampling of k-space.

---

## Trajectories

### 1. Original Phyllotaxis
The original phyllotaxis pattern from *Piccini et al.* ensures uniform coverage of the k-space, distributing points evenly on a spherical surface.

### 2. Pole-to-Pole Phyllotaxis
In this trajectory, the starting points of the spokes are located on both hemispheres, and the trajectory follows a path from one pole to the other.

### 3. Continuous Phyllotaxis
The continuous phyllotaxis trajectory builds upon the pole-to-pole approach by adjusting the path so that the angular position increases continuously from one pole to the other before returning to its starting point.  
This design further minimizes eddy current effects by avoiding jumps at the start of each segment.

---

## Visualization

The following figures illustrate each of the three methods:

- **Original Phyllotaxis**  
  *Original Phyllotaxis GIF*

- **Pole-to-Pole Phyllotaxis**  
  *Pole-to-Pole Phyllotaxis GIF*

- **Continuous Phyllotaxis**  
  *Continuous Phyllotaxis GIF*

---

## Code

The repository contains MATLAB code to generate and plot these trajectories.  
You can set the desired number of readout points, interleaves (shots), and segments.

### Directory Structure

```
/code/
├── Recon.m                 # Run image reconstruction of the provided 3D radial Phyllotaxis data
├── trajectories/           # Code to generate 3D Radial Phyllotaxis trajectories in MATLAB
├── sequences/              # Compiled 3D Radial Phyllotaxis trajectories for Pulseq
├── utils/                  # MATLAB helper functions for reconstruction and correction methods
├── gpunufft/               # gpuNUFFT functions for reconstructing 3D radial data
├── mapBVBD/                # Functions to read Siemens raw data
├── data/                   # Example raw and MATLAB data
└── figures/                # Example figures
```

---

## 3D Radial Phyllotaxis Trajectories – Pulseq Sequences

### Sequence `.seq` Files

The provided Pulseq `.seq` files can be executed on any MRI system equipped with a Pulseq interpreter, subject to the following system definitions and hardware limits.

**System limits (as defined in `mr.Opts`):**
```python
system = mr.Opts(
    B0 = 2.89,
    max_grad = 26,          # mT/m
    grad_unit = "mT/m",
    max_slew = 130,         # T/m/s
    slew_unit = "T/m/s",
    rf_ringdown_time = 30e-6,
    rf_dead_time = 100e-6,
    adc_dead_time = 10e-6,
    adc_raster_time = 100e-9,
    rf_raster_time = 1e-6,
    grad_raster_time = 10e-6,
    block_duration_raster = 10e-6
)
system.rise_time = 0
system.rf_dead_time = 100e-6
```

**Sequence parameters:**
- Trajectory: 3D radial phyllotaxis (original, pole-to-pole, and continuous)
- Segments: 200
- Interleaves: 89
- Bandwidth: 349 Hz/px and 1394 Hz/px
- TR: 5 ms
- Base resolution: 80
- FOV: 160 mm

**Notes and Limitations:**  
These sequences were designed and tested according to the accompanying manuscript.  
The uploaded `.seq` files reproduce the experimental results shown in the paper (Figs. 2–5).  
Only the compiled `.seq` files are shared here. The underlying source code for generating these sequences is part of a separate publication and is therefore not included in this repository.  

Users may directly play out the `.seq` files on any compatible MRI scanner with a Pulseq interpreter installed.

> **Disclaimer:**  
> Please verify that the system limits match your scanner hardware before execution.  
> Use of these sequences is at your own risk. Adapt parameters if necessary to ensure compliance with local safety regulations and hardware specifications.

---

## 3D Radial Phyllotaxis Reconstruction Code

All data can be retrieved from [**Zenodo**] (https://zenodo.org/uploads/17428583)  
The following experiments from the paper can be conducted using the provided data and code.

---

### Experiment 1  
**One 180° phase-cycle, original Phyllotaxis, two bandwidths, different FOV orientations, and scanners**

- Use the normal reconstructions provided.  
- Use the Original Phyllotaxis sequence (two bandwidths) from `/sequence` and scan in sagittal, transverse, and coronal orientations, both in- and off-isocenter.  
- **Recon Experiment 1.1:** Reconstruct this data and observe the artifacts in the Original Phyllotaxis scans, independent of FOV orientation and stronger at higher bandwidths.  
  *(Corresponds to Figure 2 in the paper)*

---

### Experiment 2  
**One 180° phase-cycle, original, pole-to-pole, and continuous Phyllotaxis at high bandwidths**

- Use the normal reconstructions provided.  
- Use the Original, Pole-to-Pole, and Continuous Phyllotaxis sequences from `/sequence`.

**Sub-experiments:**
- **Recon Experiment 2.1:** Evaluation of trajectory-dependent signal variations — reconstruct the phase at the k-space center. *(Figure 3)*  
- **Recon Experiment 2.2:** Reconstruct data and observe artifact suppression with Pole-to-Pole and Continuous Phyllotaxis. *(Figure 4)*  
- **Recon Experiment 2.3:** Phase-compensation correction — reconstruct top or bottom subsets, observe reappearance of artifacts, and apply correction to remove them again. *(Figure 5, Supporting Information Figure S5)*  
- **Experiment 2.4:** Repeat each spoke four times and reconstruct. *(Supporting Information Figure S6)*

---

## References

Peper et al., 2024.  
*Pole-to-pole spiral phyllotaxis trajectory design improves image quality and quantitative parametric maps of 3D radial MRI.*
