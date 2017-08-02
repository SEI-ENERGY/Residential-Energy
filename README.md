# SEI-ENERGY - Residential-Energy
Residential Energy Consumption Model Scripts

In this repository we provide all the code used to 1) match the PUMS and RECS data and 2) impute energy consumption for unmatched PUMS records.

The code for this project is in R and Python using Jupter notebooks (see <a href = "http://jupyter.org/">Jupyter webpage</a>). The code is organized as follows:<br>

<b>step01_Statistics_Matching.R</b><br>
This R scripts aims to match PUMS records to RECS records. Both Georgia PUMS and Subdivision 5 RECS data 
are provided in the <i>data</i> folder and can be used to run the sample script. This script uses StatMatch package in R (see the 
<a href = "https://cran.r-project.org/web/packages/StatMatch/StatMatch.pdf">user manual</a> for more information regarding this package) to match records with similar number of rooms, heating fuel sources, and energy bills from both datasets. The match process
is performed seperately by energy sources. 

The major outputs of the script includes (saved in output folder):
<ul>
  <li> el_training.csv (matched pums records with electricity consumption from recs data)
  <li> el_imputing.csv (unmatched pums records for electricity consumption)
  <li> ng_training.csv (matched pums records with natural gas consumption from recs data)
  <li> ng_imputing.csv (unmatched pums records for natural gas consumption)
  <li> other_training.csv (matched pums records with other energy consumption from recs data)
  <li> other_imputing.csv (unmatched pums records for other energy consumption)
</ul>

The script is written and tested in R version 3.4.1.
R packages needed to run this script include<br>
<ul>
  <li>StatMatch
  <li>reshape
  <li>ade4
  <li>Hmisc
</ul>

<b>step02_impute electricity energy.ipynb</b><br>
This jupyter notebooks includes scripts used to train machine learning models using matched pums records and apply the best trained model 
to unmatched records. The scripts takes the outputs from R scripts as inputs and outputs the following files:<br>
<ul>
  <li> el_training_model_comparisons.csv (metrics for all the trained models)
  <li> el_imputed.csv (unmatched pums records with imputed electricity consumption)
  <li> ng_training_model_comparisons.csv (metrics for all the trained models)
  <li> ng_imputed.csv (unmatched pums records with imputed natural gas consumption)
  <li> other_training_model_comparisons.csv (metrics for all the trained models)
  <li> other_imputing.csv (unmatched pums records with imputed other energy consumption)
</ul>

To obtain all the above files, users need to the energy_source variables from "el" to "ng" to "other" and run the model three times.

The script is written and tested in Python 2.7.
Python Libraries needed to run this script include<br>
<ul>
  <li>Numpy
  <li>pandas
  <li>matplotlib
  <li>IPython
</ul>







