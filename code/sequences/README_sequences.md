# 3D Radial Phyllotaxis Pulseq Sequences

[← Back to main project](../README.md)

This folder contains [Pulseq](https://pubmed.ncbi.nlm.nih.gov/27271292/) `.seq` files, which can be executed on any MRI system equipped with a Pulseq interpreter, subject to the following system definitions and hardware limits.

> **Disclaimer:**  
> Please verify that the system limits match your scanner hardware before execution.  
> Use of these sequences is at your own risk. Adapt parameters if necessary to ensure compliance with local safety regulations and hardware specifications.

---

## System Definition

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

---

## Sequence Parameters
Sequence numbering follows the raw data provided on [**Zenodo**](https://zenodo.org/uploads/17428583)  

### `Scan01_Original_200x89_348BW_TR5ms_FA20_Whisper`
- Trajectory: 3D radial, original phyllotaxis  
- Segments: 200  
- Interleaves: 89  
- Bandwidth: 348 Hz/px  
- TR/TE: 5 ms / 2.5 ms  
- Base resolution: 80  
- FOV: 160 mm  

---

### `Scan02_Original_200x89_1389BW_TR5ms_FA20_Whisper`
- Trajectory: 3D radial, original phyllotaxis  
- Segments: 200  
- Interleaves: 89  
- Bandwidth: 1389 Hz/px  
- TR/TE: 5 ms / 2.5 ms  
- Base resolution: 80  
- FOV: 160 mm  

---

### `Scan07_PoleToPole_200x89_1389BW_TR5ms_FA20_Whisper`
- Trajectory: 3D radial, pole-to-pole phyllotaxis  
- Segments: 200  
- Interleaves: 89  
- Bandwidth: 1389 Hz/px  
- TR/TE: 5 ms / 2.5 ms  
- Base resolution: 80  
- FOV: 160 mm  

---

### `Scan12_Continuous_200x89_1389BW_TR5ms_FA20_Whisper`
- Trajectory: 3D radial, continuous phyllotaxis  
- Segments: 200  
- Interleaves: 89  
- Bandwidth: 1389 Hz/px  
- TR/TE: 5 ms / 2.5 ms  
- Base resolution: 80  
- FOV: 160 mm  

---

## References

<!-- Peper et al. *Pole-to-Pole 3D Radial Trajectory Designs Improve Image Quality and Quantitative Parametric Mapping in the Brain and Heart.* MRM (2025)-->
Peper et al. [*Evaluation of 3D Radial Phyllotaxis Trajectories for Artifact-Free Imaging and Parametric Mapping.*](https://archive.ismrm.org/2025/0636_38aazwRbM.html) Proc. Intl. Soc. Mag. Reson. Med. (2025)
