# 3D Radial Phyllotaxis Trajectories

This repository contains the implementations of three different 3D radial phyllotaxis trajectories: the **Original Phyllotaxis**, **Pole-to-Pole Phyllotaxis**, and **Continuous Phyllotaxis**. Each method has unique characteristics that impact the sampling of k-space, described in Peper et al., 2025.

---

## Trajectories

### 1. Original Phyllotaxis
The original phyllotaxis pattern proposed by [*Piccini et al., 2011*](https://pubmed.ncbi.nlm.nih.gov/21469185/) provides a uniform sampling of 3D k-space by evenly distributing the starting points of the readout spokes across the upper hemisphere of a spherical surface.

### 2. Pole-to-Pole Phyllotaxis
In this version, the starting points of the spokes are distributed across both hemispheres, following a continuous path from one pole to the other.

### 3. Continuous Phyllotaxis
The continuous phyllotaxis trajectory extends the pole-to-pole design by smoothly connecting the path from one pole to the other and back to the starting point. This continuous trajectory motion further reduces eddy current effects by eliminating discontinuities between segments.

---

## Visualization

The following figures illustrate each of the three methods:

- **Original Phyllotaxis**  
![Original Phyllotaxis](/code/trajectories/trajectory_original_nSeg200_nShot89.gif)

- **Pole-to-Pole Phyllotaxis**  
![Original Phyllotaxis](/code/trajectories/trajectory_pole-to-pole_nSeg200_nShot89.gif)

- **Continuous Phyllotaxis**  
![Original Phyllotaxis](/code/trajectories/trajectory_continuous_nSeg200_nShot89.gif)

---

## Code

This repository contains MATLAB code to generate and plot the different phyllotaxis trajectories and compiled Pulseq sequences for each trajectory. It also provides code for 3D radial image reconstruction using the [gpuNUFFT](https://cai2r.net/resources/gpunufft-an-open-source-gpu-library-for-3d-gridding-with-direct-matlab-interface/).

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

The provided [Pulseq](https://pubmed.ncbi.nlm.nih.gov/27271292/) `.seq` files can be executed on any MRI system equipped with a Pulseq interpreter, subject to the following system definitions and hardware limits.

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
The compiled Pulseq `.seq`  files contain the sequences used to conduct the experiments described in Peper et al., 2025. These files can be directly executed on any MRI scanner equipped with a compatible Pulseq interpreter.

> **Disclaimer:**  
> Please verify that the system limits match your scanner hardware before execution.  
> Use of these sequences is at your own risk. Adapt parameters if necessary to ensure compliance with local safety regulations and hardware specifications.

---

## 3D Radial Phyllotaxis Reconstruction Code

All data can be retrieved from [**Zenodo**](https://zenodo.org/uploads/17428583)  
The following experiments from Peper et al., 2025 can be conducted using the provided data and code.

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

<!-- Peper et al. *Pole-to-Pole 3D Radial Trajectory Designs Improve Image Quality and Quantitative Parametric Mapping in the Brain and Heart.* MRM (2025)-->
Peper et al. [*Evaluation of 3D Radial Phyllotaxis Trajectories for Artifact-Free Imaging and Parametric Mapping.*](https://archive.ismrm.org/2025/0636_38aazwRbM.html) Proc. Intl. Soc. Mag. Reson. Med. (2025)

## Applications
Tagliabue et al. *FID-self-navigation to track physiological motion with high temporal resolution in 3D radial MRI of the heart.* Proc. Intl. Soc. Mag. Reson. Med. (2026)

Tagliabue et al. *Feasibility of free-breathing liver T1 and T2 mapping using 3D radial phase-cycled balanced steady-state free-precession.* Proc. Intl. Soc. Mag. Reson. Med. (2026)

Jia et al. *Vendor-agnostic implementation of 3D radial gradient echo sequence with LIBRE water-excitation pulses for eye imaging.* Proc. Intl. Soc. Mag. Reson. Med. (2026)
