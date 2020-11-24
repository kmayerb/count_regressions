# count_regressions

Access R Count Regression Model as Command Line Scripts

## Scripts

### Binomial Model

RScript binomial_regressions.R --help

```bash
RScript binomial_regressions.R --help
```

```bash
Options:
	-f CHARACTER, --file=CHARACTER
		dataset file name must be a tab delimitted file, .tsv

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
RScript binomial_regressions.R --file inputs/sample_tally_output_long.tsv --out outputs/sample_tally_output_long.tsv.binom.tsv
```

### Beta-Binomial Model 

#### Options

```bash
RScript beta_binomial_regressions.R --help
```

```bash
Options:
	-f CHARACTER, --file=CHARACTER
		dataset file name must be a tab delimitted file, .tsv

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
RScript beta_binomial_regressions.R --file inputs/sample_tally_output_long.tsv --out outputs/sample_tally_output_long.tsv.bbmdl.tsv
```