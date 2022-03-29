

loo_model <- function(output) {
  log_lik <- extract_log_lik(output, merge_chains = FALSE)
  r_eff     <- relative_eff(exp(log_lik), cores = 2)
  loo_M     <-   loo(log_lik, r_eff = r_eff, cores = 2)
  return(loo_M)
}