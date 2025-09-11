a longitudinal Monte Carlo SAS simulation for CD-RISC with weekly time series, treatment vs control, coping styles, and dynamic stress/HRV. It simulates panel data, fits a mixed model per replicate, and aggregates treatment effects across replicates.

/*===============================================================
  Longitudinal Monte Carlo for CD-RISC (weekly panel data)
  - N subjects, T weeks, R Monte Carlo replicates
  - Dynamics: Stress_t, HRV_t (AR(1) processes)
  - Resilience (CDRISC) depends on Stress, HRV, Coping, Treatment x Post
  - Mixed model per replicate; meta-summarize treatment effect
===============================================================*/

options nocenter nodate nonumber mprint;
ods html close; ods listing close;
ods html style=HTMLBlue;  /* Colored, presentation-friendly output */
ods graphics on;

/*------------------------------*
 | User parameters (tunable)    |
 *------------------------------*/
%let N = 300;          /* subjects total                         */
%let T = 12;           /* weeks per subject                      */
%let R = 200;          /* Monte Carlo replicates                  */
%let treat_prop = 0.5; /* proportion assigned to treatment        */
%let post_week = 5;    /* intervention starts at week >= this     */
%let seed = 20250823;  /* RNG seed                                */

/* Effect sizes (conceptual, adjust freely) */
%let beta0  = 60;      /* baseline mean resilience                */
%let bStress= -0.30;   /* stress lowers resilience                */
%let bHRV   =  0.45;   /* HRV raises resilience                   */
%let bCoping=  4.00;   /* adaptive coping boost                   */
%let bTx    =  3.50;   /* treatment effect after post_week        */

/* Random effects & residual structure */
%let sd_int   =  8.0;  /* subject random intercept SD             */
%let sd_slope =  0.6;  /* subject random time slope SD            */
%let cor_ints =  0.20; /* corr(intercept, slope)                  */
%let sd_eps   =  5.0;  /* measurement noise SD                    */

/* AR(1) dynamics for Stress and HRV */
%let muStress = 50;
%let phiS     = 0.65;
%let sdS      = 6;

%let muHRV    = 70;
%let phiH     = 0.55;
%let sdH      = 7;

/*--------------------------------------------------------------*
 | Helper: draw bivariate normal (intercept, slope) per subject |
 *--------------------------------------------------------------*/
proc iml;
start draw_bvn(n, sd1, sd2, rho);
  call randseed(&seed);
  mu = {0,0};
  cov = (sd1||0)//(0||sd2);
  cov[1,2] = rho*sd1*sd2; cov[2,1] = cov[1,2];
  x = randnormal(n, mu, cov);
  return(x);
finish;
store module=draw_bvn;
quit;

/*--------------------------------------------------------------*
 | Macro: one replicate of longitudinal simulation + analysis   |
 *--------------------------------------------------------------*/
%macro one_rep(rep=1, outparm=pe_&rep);

  /* Subject-level design */
  data subj;
    call streaminit(&seed + &rep);
    do id = 1 to &N;
      treat = (rand("uniform") < &treat_prop);
      coping = rand("bernoulli", 0.6); /* 1=adaptive, 0=maladaptive */
      output;
    end;
  run;

  /* Random intercept/slope using IML helper */
  proc iml;
    load module=draw_bvn;
    x = draw_bvn(&N, &sd_int, &sd_slope, &cor_ints);
    int  = x[,1]; slope = x[,2];
    id   = t(1:&N);
    create re var {"id" "int" "slope"};
    append;
    close re;
  quit;

  /* Expand to panel; simulate AR(1) stress & HRV and resilience */
  data panel;
    merge subj re; by id;
    length group $8;
    call streaminit(&seed + 1000 + &rep);

    do week = 1 to &T;
      post = (week >= &post_week);
      group = ifc(treat=1, "Treat", "Control");

      /* AR(1): Stress */
      if week=1 then stress = rand("normal", &muStress, &sdS/sqrt(1-&phiS*&phiS));
      else stress = &muStress + &phiS*(stress - &muStress) + rand("normal", 0, &sdS);

      /* AR(1): HRV (independent AR(1) for demo; could couple via stress/theta) */
      if week=1 then hrv = rand("normal", &muHRV, &sdH/sqrt(1-&phiH*&phiH));
      else hrv = &muHRV + &phiH*(hrv - &muHRV) + rand("normal", 0, &sdH);

      /* Linear predictor for resilience */
      lin = &beta0
            + int
            + slope*(week-1)
            + &bStress*stress
            + &bHRV*hrv
            + &bCoping*coping
            + (&bTx)*(treat*post);

      /* Observation noise */
      eps = rand("normal", 0, &sd_eps);

      /* CD-RISC-like score (truncate to 0..100) */
      cdrisc = max(0, min(100, lin + eps));

      output;
    end;

    keep id treat group coping week post stress hrv cdrisc;
  run;

  /* Mixed model: CDRISC ~ treat*post + stress + hrv + coping + time + random int/slope */
  ods exclude all;
  ods output SolutionF=&outparm(keep=Effect Estimate StdErr DF tValue Probt)
             FitStatistics=fit_&rep;
  proc mixed data=panel method=REML;
    class id;
    model cdrisc = week treat|post stress hrv coping / solution ddfm=kr;
    random intercept week / subject=id type=un;
    repeated / subject=id type=ar(1);  /* residual AR(1) within subject */
  run;
  ods select all;

  /* Add replicate id */
  data &outparm; set &outparm; rep=&rep; run;

  /* Small set of plots for this replicate (optional) */
  %if &rep=1 %then %do;
    title "Replicate &rep: Mean CD-RISC Trajectories";
    proc means data=panel nway mean stderr;
      class group week;
      var cdrisc;
      output out=means_&rep mean=mean stderr=se;
    run;
    proc sgplot data=means_&rep;
      series x=week y=mean / group=group markers;
      band x=week lower=mean-1.96*se upper=mean+1.96*se / group=group transparency=0.6;
      yaxis label="CD-RISC (mean ±95% CI)";
      xaxis label="Week";
    run;
  %end;

%mend;

/*----------------------------------------------*
 | Run R replicates and collect parameter stats  |
 *----------------------------------------------*/
%macro run_mc;
  %do r=1 %to &R;
    %one_rep(rep=&r);
  %end;

  /* Stack parameter estimates */
  data all_pe; set pe_:; run;

  /* Focus on the post*treat interaction (treatment effect after intervention) */
  proc sql;
    create table txeff as
    select rep, Estimate as beta, StdErr as se
    from all_pe
    where Effect = "treat*post";
  quit;

  title "Monte Carlo Distribution of Treatment (treat*post) Effect";
  proc means data=txeff n mean std min p25 median p75 max;
    var beta se;
  run;

  /* Visualization of the treatment effect across replicates */
  proc sgplot data=txeff;
    histogram beta / transparency=0.2;
    density beta / type=normal;
    xaxis label="Estimated Treatment Effect (treat*post)";
    yaxis label="Frequency";
  run;

  /* 95% coverage vs true effect */
  data txeff_ci;
    set txeff;
    lcl = beta - 1.96*se;
    ucl = beta + 1.96*se;
    covered = (lcl <= &bTx) and (&bTx <= ucl);
  run;

  title "Coverage of 95% CIs for Treatment Effect";
  proc means data=txeff_ci mean;
    var covered;
  run;
%mend run_mc;

%run_mc;

ods graphics off;
ods html close; ods listing;

