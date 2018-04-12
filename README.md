# dkl_conversion

This is a collection of routines for utilizing the DKL color space, written by Nicholas Blauch in the Cowell and Huber Labs at UMass Amherst. The raw RGB<-LMS->DKL pipeline was essentially copied from David Brainard's example script in Human Color Vision (1996). 

A good starting point to understanding these routines is the file dkl_example.m . 
This file demonstrates the production of an isoluminant plane and optional gamma-based (il)luminance-correction.

Explicit (il)luminance-correction was developed by NB in order to accomodate isoluminant colors with high dynamic range, given the observation
that explicit gamma-correction via a look-up-table (LUT) results in very washed out colors, and does not result in completely isoluminant colors. This method uses the slope of the gamma-function fit to measured (il)luminance readings to determine how to change each RGB phosphor in a way that modifies only (il)luminance and leaves chromaticity in tact. The two provided functions: correct_illuminance and correct_illuminance_img can be used for a wide variety of stimuli and result in isoluminant output stimuli with equivalent chromaticity as the (non-isoluminant) inputs. 

questions?
email nblauch@icloud.com or create an issue on github
