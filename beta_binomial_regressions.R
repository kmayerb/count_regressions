#!/usr/bin/env Rscript
library("optparse")
option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="dataset file name must be a tab delimitted file, .tsv ", metavar="character"),
  make_option(c("-c", "--clonotype"), type="character", default='clone_df_index', NULL, 
              help="column designating (meta)clonotypes [default= %default]", metavar="character"),
  make_option(c("-r", "--formula"), type="character", default='cbind(W, M-W) ~ Timepoint + ptid', 
              help="formula string [default= %default]", metavar="character"),
  make_option(c("-d", "--dispersion_formula"), type="character", default='~1', 
              help="phi formula string [default= %default]", metavar="character"),
  make_option(c("-p", "--positive"), type="character", default='MEM+', 
              help="column with MEM+ [default= %default]", metavar="character"),
  make_option(c("-n", "--negative"), type="character", default='MEM-', 
              help="column with MEM- [default= %default]", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="out.txt", 
              help="output file name [default= %default]", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
print(opt);
file = opt$file;
clonotype = opt$clonotype;
positive = opt$positive
negative = opt$negative
frm = opt$formula
out = opt$out
phifrm = opt$dispersion_formula
require("corncob")
require("magrittr")
# FOR TESTING ONLY:
# file = "sample_tally_output_long.tsv"
# clonotype  = 'clone_df_index'
# positive = 'MEM+'
# negative = 'MEM-'
# frm = 'cbind(W, M-W) ~ Timepoint + ptid'
# out = "out.tsv"

# Load tsv file
df = readr::read_tsv(file )
dfs = df %>% split(f=df[clonotype])

# Preformat
preformat <- function(d){
  # X1, will be present if pandas.DataFrame.to_csv('f.csv', index = True), 
  # but will be absent if  pandas.DataFrame.to_csv('f.csv', index = False)
  if ("X1" %in% names(d)){
    d = d %>% dplyr::select(-X1)
  }

  d2=d %>%
    tidyr::spread(key= 'cmember', value = 'count') 
  d2[['W']] = d2[[positive]]
  d2[['M']] = d2[[positive]] + d2[[negative]]
  return(d2)
}

append_name_as_column <- function(d,name, feature_name = "feature"){
  d[ feature_name ] = name
  return(d)
}

do_corncob <- function(mydata, frm = as.formula(frm)){
  cb1 = bbdml(formula = frm,
              phi.formula = as.formula(phifrm),
              data = mydata)
  return(cb1)
}

# This wrapper is useful for avoiding crashes do to errors:
possibly_do_corncob = purrr::possibly(do_corncob, otherwise = NA)

# dataframe_formatted for regression
# PREFORMAT()
dfsr = purrr::map(dfs, ~preformat(.x))
# BETA-BIONOMIAL REGRESSOINS
list_of_fit_models    = purrr::map(dfsr, ~possibly_do_corncob(mydata = .x, frm = as.formula(frm)))
                                   
list_of_fit_models    = list_of_fit_models[!is.na(list_of_fit_models)]
length(list_of_fit_models)
###########################################################################################
# Parse Models
###########################################################################################
#' get bbdml coefficients into a table
#' 
#' 
#' @param cb is object result of corncob::bbdml
#' @param i is a label for the feature name 
#' 
#' @example 
#' purrr::map2(list_of_fit_models, names(list_of_fit_models), ~parse_corncob(cb = .x, i = .y))
parse_corncob <- function(cb,i =1){
  y = summary(cb)$coefficients
  rdf = as.data.frame(y) 
  rdf$param = rownames(rdf)
  rdf = rdf %>% 
    dplyr::mutate(estimate = Estimate,  se = `Std. Error`, tvalue =  `t value`, pvalue = `Pr(>|t|)`, param) %>% 
    dplyr::mutate(type = ifelse(grepl(param, pattern = "phi"), "phi", "mu")) %>% 
    dplyr::mutate(type2 = ifelse(grepl(param, pattern = "Intercept"), "intercept", "covariate")) 
  rdf$feature = i
  return(rdf)
}

print(list_of_fit_models)

tabular_results = purrr::map2(list_of_fit_models, names(list_of_fit_models), ~parse_corncob(cb = .x, i = .y))
tabular_results = data.frame(do.call(rbind, tabular_results)) %>% tibble::remove_rownames()

# clean and output file
clean_tabular_results = tabular_results %>% 
     dplyr::select(feature, estimate, pvalue, param, type, type2) %>% 
     dplyr::arrange(type2, type, pvalue)%>% 
     readr::write_tsv(out)

