


import numpy as np
import pandas as pd
from scipy.stats import chi2_contingency
# SETTINGS
n_students = 100
n_simulations = 1000
# Generate students
np.random.seed(1234)

# Randomly assign categories
conditions = np.random.choice(
    ['Trauma', 'Stress and Anxiety', 'Depression'],
    size=n_students
)

# Assign doctors
doctors = []
for cond in conditions:
    if cond == 'Trauma':
        doctors.append('Dr_A_Trauma')
    elif cond == 'Stress and Anxiety':
        doctors.append('Dr_B_Stress_Anxiety')
    elif cond == 'Depression':
        doctors.append('Dr_C_Depression')

students_df = pd.DataFrame({
    'ID': range(1, n_students + 1),
    'Condition': conditions,
    'Doctor': doctors
})

print("Initial Distribution:")
print(students_df['Condition'].value_counts())

# Simulate outcomes
results = []

for sim in range(n_simulations):
    for idx, row in students_df.iterrows():
        rand = np.random.rand()
        if row['Condition'] == 'Trauma':
            recovered = 'Recovered' if rand < 0.60 else 'Not_Recovered'
        elif row['Condition'] == 'Stress and Anxiety':
            recovered = 'Recovered' if rand < 0.75 else 'Not_Recovered'
        elif row['Condition'] == 'Depression':
            recovered = 'Recovered' if rand < 0.50 else 'Not_Recovered'
        results.append({
            'ID': row['ID'],
            'Condition': row['Condition'],
            'Doctor': row['Doctor'],
            'Simulation': sim + 1,
            'Outcome': recovered
        })

results_df = pd.DataFrame(results)

# Tabulate outcomes
summary = pd.crosstab(
    results_df['Condition'],
    results_df['Outcome'],
    margins=True,
    normalize='index'
) * 100

print("\nRecovery Outcomes (%):")
print(summary)

# Chi-square test
contingency = pd.crosstab(
    results_df['Condition'],
    results_df['Outcome']
)

chi2, p, dof, expected = chi2_contingency(contingency)

print("\nChi-square Test:")
print(f"Chi2 Statistic: {chi2:.4f}")
print(f"p-value: {p:.4f}")

# Save to Excel
results_df.to_excel("results_python_simulation.xlsx", index=False)
print("\nResults exported to 'results_python_simulation.xlsx'")

