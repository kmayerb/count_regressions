# count_regressions

Access R Count Regression Model as Command Line Scripts

The scripts run many counts regression, one feature at a time.
Script is intended to process a single tabular 
set of features. The flag `-c` specifies the column 
used to split data by feature. All results are 
appended and returned as a single tabular output.

In these models `W` refers to counts of a certain type 
(i.e., all TCRs in a sample spanned by a meta-clonotype, or all OTUs of a particular genus). 

`M` refers to the total counts present in a sample. 

In our outputs these are represented by `MEM+` and ('MEM+' + 'MEM-'). 
The columns containing 'MEM+' and 'MEM-' values can be respecified with the 
`-p, --positive` and `-n, --negative` flags, respectively.


## Scripts

### Dependencies 

These examples were tested in an R environment with 
the following:

* dplyr >= 0.8.3
* tidyr >= 1.1.0
* purrr >= 0.3.2
* readr >= 1.3.1
* magrittr >= 1.5.0
* corncob >= 1.0.0

### Binomial Model -- Mean (`cbind(W, M-W) ~ Covariates`)

```bash
RScript binomial_regressions.R --help
```

```bash
Options:
	-f CHARACTER, --file=CHARACTER
		dataset file name must be a tab delimited file, .tsv

	-c CHARACTER, --clonotype=CHARACTER
		column designating (meta)clonotypes [default= clone_df_index]

	-r CHARACTER, --formula=CHARACTER
		formula string [default= cbind(W, M-W) ~ Timepoint + ptid]

	-d CHARACTER, --dispersion_formula=CHARACTER
		phi formula string [default= ~1]

	-p CHARACTER, --positive=CHARACTER
		column with MEM+ [default= MEM+]

	-n CHARACTER, --negative=CHARACTER
		column with MEM- [default= MEM-]

	-o CHARACTER, --out=CHARACTER
		output file name [default= out.txt]

	-h, --help
		Show this help message and exit

```

```bash
RScript binomial_regressions.R \
	--file inputs/sample_tally_output_long.tsv \
	--out outputs/sample_tally_output_long.tsv.binom.tsv
```

#### Output 

```
            param   estimate    std_err          z       pvalue feature
45.1  (Intercept) -7.3596163 0.13053940 -56.378504 0.000000e+00      45
45.2 TimepointPre -0.4145740 0.07797674  -5.316636 1.057032e-07      45
45.3     ptidV002 -0.7853337 0.34131225  -2.300925 2.139590e-02      45
45.4     ptidV005  1.9479025 0.14901470  13.071882 4.767159e-39      45
45.5     ptidV008  0.2143532 0.19786280   1.083343 2.786563e-01      45
45.6     ptidV012 -0.8659807 0.21831324  -3.966689 7.287808e-05      45
```


### Beta-Binomial Model -- Mean(`cbind(W, M-W) ~ Covariates`) + Dispersion (`~1`)

#### Options

```bash
RScript beta_binomial_regressions.R --help
```

```bash
Options:
	-f CHARACTER, --file=CHARACTER
		dataset file name must be a tab delimited file, .tsv

	-c CHARACTER, --clonotype=CHARACTER
		column designating (meta)clonotypes [default= clone_df_index]

	-r CHARACTER, --formula=CHARACTER
		formula string [default= cbind(W, M-W) ~ Timepoint + ptid]

	-d CHARACTER, --dispersion_formula=CHARACTER
		phi formula string [default= ~1]

	-p CHARACTER, --positive=CHARACTER
		column with MEM+ [default= MEM+]

	-n CHARACTER, --negative=CHARACTER
		column with MEM- [default= MEM-]

	-o CHARACTER, --out=CHARACTER
		output file name [default= out.txt]

	-h, --help
		Show this help message and exit
```

#### Execution

```bash
RScript beta_binomial_regressions.R \
	--file inputs/sample_tally_output_long.tsv \
	--out outputs/sample_tally_output_long.tsv.bbml.tsv
```

#### Output 

```
feature	estimate	pvalue	param	type	type2
36365	-2.9833467112734344	1.4413000207605275e-7	mu.ptidV030	mu	covariate
13246	-2.967483681452091	1.4939704879127058e-7	mu.ptidV019	mu	covariate
36365	-2.895478316978555	1.6223146707418541e-7	mu.ptidV012	mu	covariate
18173	3.781668132982697	2.4152137724349045e-7	mu.ptidV002	mu	covariate
36365	-3.1901971352423293	2.635133607832124e-7	mu.ptidV021	mu	covariate
36365	-3.072323549690756	4.959079024059287e-7	mu.ptidV019	mu	covariate
36643	1.6892008528370006	5.261711138316098e-7	mu.ptidV019	mu	covariate
13246	-4.990894516881081	1.0693281310146958e-6	mu.ptidV012	mu	covariate
13527	3.2428003004239287	1.2005914123704507e-6	mu.ptidV002	mu	covariate
```

