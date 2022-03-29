
// social distance discount model (SDD) - hyperbolic Model 6_amount default
// 2020/06 Jeunghyun Lee (jhleeangel@snu.ac.kr)

data {
  int<lower=1> N;
  int<lower=1> T;
  int<lower=1, upper=T> Tsubj[N];
  real<lower=0> social_distance[N, T]; //delay_later
  real<lower=0> amount_self[N, T];     //amount_later
  real<lower=0> amount_other[N, T];    //amount_sooner
  real<lower=0> amount_default[N, T];  // amount_default
  int<lower=-1, upper=1> split[N, T];  //0 for unsplit, 1 for split
}


parameters {
  // Hyper(group)-parameters
  vector[2] mu_pr;
  vector<lower=0>[2] sigma;
  
  // Subjective-level raw parameters (for Matt trick)
  vector[N] k_pr; //social discount rate
  vector[N] tau_pr; //individual sensitivity
}

transformed parameters{
  // Transform subject-level raw parameters
  vector<lower=0, upper=1>[N] k;
  vector<lower=0, upper=10>[N] tau;
    
  for (i in 1:N) {
    k[i] = Phi_approx(mu_pr[1] + sigma[1] + k_pr[i]) ;
    tau[i] = Phi_approx(mu_pr[2] + sigma[2] + tau_pr[i]) * 10;    
  }
}

model {
// Hyperbolic function
  // Hyperparameters
  mu_pr ~ normal(0, 1);
  sigma ~ cauchy(0, 5);
  
  // individual parameters
  k_pr ~ normal(0, 1);
  tau_pr ~ normal(0, 1);
  
  for (i in 1:N){
    real ev_self;
    real ev_other;
    
    for (t in 1:(Tsubj[i])){
      ev_self = amount_self[i, t] - amount_default[i, t];
      ev_other = (amount_other[i, t]) / (1 + k[i] * social_distance[i, t]);
      split[i, t] ~ bernoulli_logit(tau[i] * (ev_other - ev_self));
    }
  }
}

generated quantities {
  // For group level parameters
  real<lower=0, upper=1> mu_k;
  real<lower=0, upper=10> mu_tau;

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

  mu_k    = Phi_approx(mu_pr[1]) ;
  mu_tau = Phi_approx(mu_pr[2]) * 10;

  { // local section, this saves time and space
    for (i in 1:N) {
      // Define values
      real ev_self;
      real ev_other;

      log_lik[i] = 0;
      for (t in 1:(Tsubj[i])) {
        ev_self = amount_self[i, t] - amount_default[i, t];
        ev_other  = (amount_other[i, t]) / (1 + k[i] * social_distance[i, t]);
        log_lik[i] += bernoulli_logit_lpmf(split[i, t] | tau[i] * (ev_other - ev_self));

        // generate posterior prediction for current trial
        y_pred[i, t] = bernoulli_rng(inv_logit(tau[i] * (ev_other - ev_self)));
      }
    }
  }
}
