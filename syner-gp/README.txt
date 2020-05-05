Toolbox: syner-gp
Author: Reed Gurchiek, rgurchiek@gmail.com
Requirements: MATLAB R2019 or later, MATLAB Signal Processing Toolbox, GPML Toolbox (Carl E. Rasmussen and Hannes Nickisch, "Gaussian Processes for Machine Learning (GPML) Toolbox," Journal of Machine Learning Research, vol. 11, no. 100, pp. 3011-3015, 2010. http://www.gaussianprocess.org/gpml/code/matlab/doc/)

Description: syner-gp streamlines the development of muscle synergy function models which describe the relationship between excitations of a subset of 'input' muscles and an output muscle.
The syner-gp toolbox essentially organizes data in accordance with the notion of a synergy function so that a Gaussian process regression model can be developed for function approximation.
All aspects of GPR model training is performed using the GPML toolbox. It is recommended that users first become especially familiar with this toolbox before using syner-gp.

Details of approximating muscle synergy functions using syner-gp is specified by users according to a project.
A project specifies all aspects related to a given syner-gp session including data import, data pre-processing, synergy model structure (gp model and input muscle structure), validation, and evaluation.
To best learn how projects are specified and used to control a syner-gp session, users should first explore the exampleProject stored in syner-gp/projects. An example dataset for this project is available at: https://www.uvm.edu/~rsmcginn/lab.html.
The syner-gp/projects/specProject_exampleProject.m file specifies this example project and users can explore this (verbose) file for understanding how to create new projects to build models.

To run this example project:
(1) download the syner-gp toolbox
(2) download the GPML toolbox
(3) download the example dataset
(4) make the syner-gp directory the Current Folder in the MATLAB instance
(5) type 'synergp' in the Command Window and hit 'enter' (return) and follow the indicated prompts