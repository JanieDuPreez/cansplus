# CANS+ (English Translation) 

CANS+ is a high-order accuracy MHD (Magnetohydrodynamics) code developed from CANS (Coordinated Astronomical Numerical Software, [development homepage](http://www-space.eps.s.u-tokyo.ac.jp/~yokoyama/etc/cans/)). Its features include:

* Finite volume method using HLLD/HLL approximate Riemann solvers
* High-order interpolation (5th-order accuracy) using the MP5 method
* DivB cleaning using the 9-wave method
* Cartesian/Cylindrical coordinate systems
* Non-uniform mesh sizes
* 3D domain decomposition with MPI
* IDL-based loading and visualization routines

Following the structure of CANS, the system is divided into a common engine and specific physical problems, with libraries linked in such a way that the common engine can be utilized by each problem.

## Translated Documentation

This repository contains documents translated with online software, and may contain errors or inaccuracies.

## Original Documentation

For the original, unmodified documentation, please visit the original [github](https://github.com/chiba-aplab/cansplus) or [project website](http://www.astro.phys.s.chiba-u.ac.jp/cans/doc/index.html).
