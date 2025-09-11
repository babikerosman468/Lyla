
/*-----------------------------------------------------------
  Monte Carlo Simulation of Connor-Davidson Resilience Scale
  With Stress, HRV, and Coping Strategy
-----------------------------------------------------------*/

ods graphics on;

/* 1. Define number of Monte Carlo iterations */
%let Nsim = 10000;

/* 2. Simulate dataset */
data Resilience_MC;
   call streaminit(12345); /* reproducibility */
   do id = 1 to &Nsim;

      /* Stress: Normal(50, 10) */
      Stress = rand("Normal", 50, 10);

      /* HRV: Normal(70, 15) */
      HRV = rand("Normal", 70, 15);

      /* Coping Strategy: 0 = maladaptive, 1 = adaptive */
      Coping = rand("Bernoulli", 0.6);

      /* CD-RISC score influenced by Stress, HRV, and Coping */
      Resilience = 30 
                   - 0.3*Stress      /* higher stress reduces resilience */
                   + 0.5*HRV         /* higher HRV improves resilience */
                   + 5*Coping        /* adaptive coping boosts resilience */
                   + rand("Normal", 0, 5); /* random noise */

      /* Keep within plausible CD-RISC range (0–100) */
      if Resilience < 0 then Resilience = 0;
      if Resilience > 100 then Resilience = 100;

      output;
   end;
run;

/* 3. Descriptive statistics */
proc means data=Resilience_MC mean std min p25 median p75 max;
   var Resilience Stress HRV;
   class Coping;
run;

/* 4. Visualization */
proc sgplot data=Resilience_MC;
   histogram Resilience / transparency=0.2 fillattrs=(color=blue);
   density Resilience / type=kernel lineattrs=(color=red thickness=2);
   xaxis label="Connor-Davidson Resilience Score (CD-RISC)";
   yaxis label="Frequency";
   title "Monte Carlo Simulation of CD-RISC Resilience Scores";
run;

proc sgscatter data=Resilience_MC;
   matrix Resilience Stress HRV / group=Coping;
   title "Scatterplot Matrix: Resilience vs Stress & HRV by Coping Strategy";
run;


