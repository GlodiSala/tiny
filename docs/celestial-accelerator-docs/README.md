# Celestial Accelerator Documentation

Welcome to the Celestial Accelerator project documentation. This documentation provides an overview of the accelerator designed to enhance the simulation of n-body problems in celestial mechanics. The accelerator aims to significantly improve computational efficiency by utilizing specialized modules for various tasks.

## Table of Contents

- [Overview](#overview)
- [Modules](#modules)
  - [Celestial Top Module](modules/celestial-top-module.md)
  - [Object Processing Unit](modules/object-processing-unit.md)
  - [Fast Negative Three-Half Exponent](modules/fast-negative-three-half.md)
  - [Switch Module](modules/switch-module.md)
  - [Arithmetic Units](modules/arithmetic-units.md)
- [Performance Analysis](performance/performance-analysis.md)
- [Security Risks](security/security-risks.md)
- [Guides](#guides)
  - [Getting Started](guides/getting-started.md)
  - [C Code Examples](guides/c-code-examples.md)
- [Assets](assets/images)

## Overview

The Celestial Accelerator is designed to simulate the gravitational interactions of multiple celestial bodies efficiently. By leveraging parallel processing and optimized algorithms, the accelerator reduces the computational complexity from O(N^2) to O(N), allowing for faster simulations and more accurate results.

## Modules

### Celestial Top Module
This module manages communication with the rocket core and handles data packets that control the accelerator's operations.

### Object Processing Unit
Responsible for updating the positions and velocities of celestial bodies, this unit utilizes various sub-modules to perform calculations efficiently.

### Fast Negative Three-Half Exponent
This module optimizes the velocity update process by implementing a fast algorithm for calculating the negative three-half exponent, crucial for gravitational simulations.

### Switch Module
The switch module facilitates data flow between the top module and body processing units, ensuring efficient communication during simulations.

### Arithmetic Units
These units perform the necessary arithmetic operations for position and velocity updates, playing a critical role in the accelerator's performance.

## Performance Analysis
The performance analysis section provides insights into the efficiency of the accelerator, comparing clock cycles with and without its use, and detailing the expected speedup in simulations.

## Security Risks
This section discusses potential security vulnerabilities associated with the accelerator and outlines measures taken to mitigate these risks.

## Guides

### Getting Started
This guide offers instructions for setting up the accelerator and configuring it for initial use.

### C Code Examples
Here, you will find example C code snippets that demonstrate how to utilize the accelerator's commands and functionalities in practical scenarios.

## Assets
The assets directory contains images and diagrams that support the documentation, providing visual aids for better understanding.

For further details on each module and their functionalities, please refer to the respective markdown files in the modules directory.