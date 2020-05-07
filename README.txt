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

The synergp function is the main function used to build synergy function models according to specifications set for any project (set in specProject_()).
Upon running synergp the first time, users are first prompted to locate the GPML toolbox (gpml-matlab-v4.2-2018-06-11). 
Users have the option of associating this directory with the GPML toolbox for later use. This information is stored in the gpmldir.mat file in lib/util. If the GPML toolbox directory ever changes, this file (gpmldir.mat) will need to be deleted.
The main output of the synergp function is a structure (Matlab struct()) called 'session' and users have the option of saving this structure (.mat file) for later analysis (see towards the end of the specProject_exampleProject.m file).
As described in the specProject_exampleProject.m file, synergy function model characteristics (including GP model details) are specified in the specProject_ function.
After synergp has finished, the details of each model trained/tested are in session.model(i).gpModel (i.e. the ith model).
Synergy models are muscle specific. The hyperparameters of model i, for subject s, and muscle m are in session.model(i).subject(s).muscle(m).optimization(end).hyperparameters
To use the model later, one also needs the training data. To have access to this, users must set synergyModel.keepTrainingSet = 1 in the specProject_() function (see exampleProject).
While synergp is running, status updates are constantly printed to the command window. These updates are also stored in a cell array field in the session structure called 'notes'.
Users can use lib/util/synergp_writeNotes to generate a .txt file with these notes.
During hyperparameter optimization, the minimize function in the GPML toolbox prints optimization status updates to the command window. By default, these are rather verbose.
To reduce the amount of space taken up by these updates, users can make the following changes to the the minimize.m file in the gpml-matlab-v4.2-2018-06-11 toolbox:

   (1) replace line 77: fprintf('%s %6i;  Value %4.6e\r', S, i, f0);
                  with: synergp_report = sprintf('%s: %d of %d, Current Minimum NLML: %4.6e',S,i,abs(length),f0); fprintf(synergp_report);

   (2) replace line 150: fprintf('%s %6i;  Value %4.6e\r', S, i, f0);
               with: fprintf(repmat('\b',[1 numel(synergp_report)])); synergp_report = sprintf('%s: %d of %d, Current Minimum NLML: %4.6e',S,i,abs(length),f0); fprintf(synergp_report);

   (3) replace line 171: fprintf('\n'); if exist('fflush','builtin') fflush(stdout); end
               with: fprintf(repmat('\b',[1 numel(synergp_report)])); synergp_report = sprintf('%s: %d of %d, Current Minimum NLML: %4.6e',S,i,abs(length),f0); fprintf(synergp_report); if exist('fflush','builtin') fflush(stdout); end 