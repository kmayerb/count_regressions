#!/usr/bin/env Rscript
library("optparse")
option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="dataset file name must be a tab delimited file, .tsv ", metavar="character"),
  make_option(c("-c", "--clonotype"), type="character", default='clone_df_index', NULL, 
              help="column designating (meta)clonotypes [default= %default]", metavar="character"),
  make_option(c("-r", "--formula"), type="character", default='cbind(W, M-W) ~ Timepoint + ptid', 
              help="formula string [default= %default]", metavar="character"),
  make_option(c("-p", "--positive"), type="character", default='MEM+', 
              help="column with MEM+ [default= %default]", metavar="character"),
  make_option(c("-n", "--negative"), type="character", default='MEM-', 
              help="column with MEM- [default= %default]", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="out.txt", 
              help="output file name [default= %default]", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
print(opt)
require(readr)
require(magrittr)
# Load tsv file
df = readr::read_tsv(opt$file)
#df = readr::read_tsv('sample_tally_output_long.tsv')

dfs = df %>% split(f=df[opt$clonotype])

# Preformat
preformat <- function(d){
  # X1, will be present if pandas.DataFrame.to_csv('f.csv', index = True), 
  # but will be absent if  pandas.DataFrame.to_csv('f.csv', index = False)
  if ("X1" %in% names(d)){
    d = d %>% dplyr::select(-X1)
  }
  d2=d %>% 
    tidyr::spread(key= 'cmember', value = 'count') 
  d2[['W']] = d2[[opt$positive]]
  d2[['M']] = d2[[opt$positive]] + d2[[opt$negative]]
  return(d2)
}

append_name_as_column <- function(d,name, feature_name = "feature"){
  d[ feature_name ] = name
  return(d)
}
# dataframe_formatted for regression
# PREFORMAT()
dfsr = purrr::map(dfs, ~preformat(.x))
# BIONOMIAL REGRESSOINS
binomialregs = purrr::map(dfsr, ~ as.data.frame(coef(summary(glm(as.formula(opt$formula), data = .x, family = 'binomial')))))
# APPEND FEATURE NAME INTO A COLUMN <feature>
all_results = purrr::map2(binomialregs, names(binomialregs), ~append_name_as_column(d = .x, name = .y))
# APPEND <param> COLUMN
all_results = purrr::map(all_results, ~tibble::rownames_to_column(.x, var = "param"))
# COMBINE  many dataframes into a single frame
all_results=do.call(rbind, all_results)
# Covert names, using a list as a dictionary
new_names = list('param' = 'param',
                 "Estimate" = 'estimate', 
     "Std. Error" = 'std_err', 
     "z value" = 'z', 
     "Pr(>|z|)" = 'pvalue', 
     "feature" = 'feature')[names(all_results)] %>% 
  as.character()

names(all_results) <- new_names
print(paste0('%>% readr::write_tsv(',opt$out,')'))
print(head(all_results))
all_results  %>% readr::write_tsv(opt$out)



# require(ggplot2)
# all_results %>% dplyr::mutate(priority = ifelse(param == '(Intercept)', 0,1)) %>% 
#   dplyr::mutate(priority = ifelse(param == 'TimepointPre', 2,priority)) %>%
#   dplyr::arrange(desc(priority), pvalue) %>% 
#   dplyr::filter(priority > 0) %>%
#   dplyr::filter(param == "TimepointPre") %>%
#   ggplot(aes(x = estimate, y = -1*log10(pvalue))) + geom_point(pch = 1) + facet_wrap(~param) + 
#   xlim(c(-5,5))+ geom_vline(xintercept = 0, col = "red") + theme_classic()