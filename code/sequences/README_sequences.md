# 3D Radial Phyllotaxis Pulseq Sequences

[← Back to main project](../README.md)

This folder contains **PyPulseq `.seq` files** used in *Peper et al., 2025*.  
The sequences were designed and tested according to the manuscript, and the uploaded files reproduce the experimental results shown in the paper.

Only the **compiled `.seq` files** are shared here. Users may directly play out the sequences on any compatible MRI scanner equipped with a Pulseq interpreter.

> **Disclaimer:**  
> Please verify that the system limits match your scanner hardware before execution.  
> Use of these sequences is at your own risk. Adapt parameters if necessary to ensure compliance with local safety regulations and hardware specifications.

---

## System Definition

All sequences were generated with the following system settings (as defined in `mr.Opts`):

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

### `Scan03_PoleToPole_200x89_1389BW_TR5ms_FA20_Whisper`
- Trajectory: 3D radial, pole-to-pole phyllotaxis  
- Segments: 200  
- Interleaves: 89  
- Bandwidth: 1389 Hz/px  
- TR/TE: 5 ms / 2.5 ms  
- Base resolution: 80  
- FOV: 160 mm  

---

### `Scan04_Continuous_200x89_1389BW_TR5ms_FA20_Whisper`
- Trajectory: 3D radial, continuous phyllotaxis  
- Segments: 200  
- Interleaves: 89  
- Bandwidth: 1389 Hz/px  
- TR/TE: 5 ms / 2.5 ms  
- Base resolution: 80  
- FOV: 160 mm  

---

## Reference

Peper et al., 2025  
*Pole-to-pole spiral phyllotaxis trajectory design improves image quality and quantitative parametric maps of 3D radial MRI*.
