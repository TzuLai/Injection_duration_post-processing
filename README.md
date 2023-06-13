# Injection_duration_post-processing
source code for processing injection duration from simulator and ECU.
*  save_var.m: <br /> 
   Read in the raw injection duration information and re-structure.
*  compare.m: <br />
   Different simulator generates different simulation result.<br />
   The script compares the simulation results from different simulator.
*  process.m: <br />
   Remove the outliers and apply the linear regression model for simulation signal correction.<br />
   Output image shows the relation between information from simulationi and from ECU.
