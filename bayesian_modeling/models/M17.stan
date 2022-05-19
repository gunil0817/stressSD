//  SD + ineqaulity aversion model
// Jeunghyun Lee (jhleeangel@snu.ac.kr)
//eidted by Kunil Kim 22. 03. 21

data {
  int<lower=1> N;
  int<lower=1> T;
  int<lower=1, upper=T> Tsubj[N];
  real<lower=0> social_distance[N, T];
  real<lower=0> amount_self[N, T];
  real<lower=0> amount_other[N, T];
  real<lower=0> amount_default[N, T];  //amount_default (non-split)
  real<lower=0> inequality[N, T]; // inequality aversion babbe
  real<lower=0> SDLike[N, T];
  int<lower=0, upper=1> split[N, T]; // 0 for non-split, 1 for split
}

transformed data {
}

parameters {
  // Declare all parameters as vectors for vectorizing
  // Hyper(group)-parameters
  vector[4] mu_pr;
  vector<lower=0>[4] sigma;
  
  // Subject-level raw parameters (for Matt trick)
  vector[N] k_pr; // social-discounting rate
  vector[N] beta_pr; // self-reward sensitivity parameter
  vector[N] eta_pr; // self-reward sensitivity parameter
  vector[N] tau_pr;
}

transformed parameters {
  // Transform subject-level raw parameters
  vector<lower = 0, upper = 1>[N] k;
  vector<lower = 0, upper = 2>[N] beta;
  vector<lower = 0, upper = 10>[N] tau;
  vector<lower = 0, upper = 1>[N] eta;
  
  for (i in 1:N) {
    k[i]    = Phi_approx(mu_pr[1] + sigma[1] * k_pr[i]);
    beta[i] = Phi_approx(mu_pr[2] + sigma[2] * beta_pr[i])*2;
    tau[i] = Phi_approx(mu_pr[3] + sigma[3] * tau_pr[i])*10;
    eta[i] = Phi_approx(mu_pr[4] + sigma[4] * eta_pr[i]);
  }
}

model {
  // Exponential function
  // Hyperparameters
  mu_pr  ~ normal(0, 1);
  sigma ~ normal(0, 0.2);
  
  // individual parameters
  k_pr    ~ normal(0, 1);
  beta_pr ~ normal(0, 1);
  tau_pr  ~ normal(0, 1);
  eta_pr ~ normal(0,1);
  
  for (i in 1:N) {
    // Define values
    real ev_self;
    real ev_other;
    
    for (t in 1:(Tsubj[i])) {
      ev_self = beta[i] * (amount_self[i, t] - amount_default[i,t]) ;
      ev_other = amount_other[i, t]  / (1 + k[i] * SDLike[i, t]) - eta[i] * inequality[i, t];
      split[i, t] ~ bernoulli_logit(tau[i]*(ev_other - ev_self));
    }
  }
}
generated quantities {
  // For group level parameters
  real<lower = 0, upper = 1> mu_k;
  real<lower = 0, upper = 2> mu_beta;
  real<lower = 0, upper = 10> mu_tau;
  real<lower = 0, upper = 1> mu_eta;
  
  // For log likelihood calculation
  real log_lik[N];
  
  // For posterior predictive check
  real y_pred[N, T];
  
  // Set all posterior predictions to 0 (avoids NULL values)
  for (i in 1:N) {
    for (t in 1:T) {
      y_pred[i, t] = -1;
    }
  }
  
  mu_k    = Phi_approx(mu_pr[1]);
  mu_beta = Phi_approx(mu_pr[2])*2;
  mu_tau = Phi_approx(mu_pr[3])*10;
  mu_eta = Phi_approx(mu_pr[4]);
  
  
  { // local section, this saves time and space
    for (i in 1:N) {
      // Define values
      real ev_self;
      real ev_other;
      
      log_lik[i] = 0;
      
      for (t in 1:(Tsubj[i])) {
        ev_self = beta[i] * (amount_self[i, t] - amount_default[i, t]) ;
        ev_other =  amount_other[i, t] / (1 + k[i] * SDLike[i, t])  - eta[i] * inequality[i, t];
        log_lik[i] += bernoulli_logit_lpmf(split[i, t] | tau[i] * (ev_other - ev_self));
        
        // generate posterior prediction for current trial
        y_pred[i, t] = bernoulli_rng(inv_logit(tau[i]*(ev_other - ev_self)));
      }
    }
  }
}
