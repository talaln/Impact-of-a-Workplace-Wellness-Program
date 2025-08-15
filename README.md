# Impact of a Workplace Wellness Program - Analysis

Reproducible SAS workflow and outputs for the analysis supporting:

> **Evaluating the Impact of a Workplace Wellness Program in Saudi Arabia: An Intra‑Department Study._ Journal of Occupational and Environmental Medicine.**

## 📌 Reference

Altwaijri, Y., Hyder, S., Bilal, L., **Naseem, M. T.**, AlSaqabi, D., AlSuwailem, F., Aradati, M., & DeVol, E. (2019). *Evaluating the Impact of a Workplace Wellness Program in Saudi Arabia: An Intra-Department Study.* **Journal of occupational and environmental medicine, 61(9), 760–766.** https://doi.org/10.1097/JOM.0000000000001656

## 🎯 Goal of this repository

- Provide a clean, **reproducible SAS workflow** to re-run the study’s descriptive and inferential analyses.
- Share code and **synthetic example data** for demonstration.
- Enable others to extend the analysis (e.g., stratified models, sensitivity checks).

## 🗂️ Repository structure

```
.
├─ data/
│  ├─ Base_DATA_synth.csv                    # Baseline Survey dataset (no real PII)
│  ├─ Base_Measurement_Data_synth.xlsx       # Baseline Measurements dataset (no real PII)
│  ├─ Post_DATA_synth.csv                    # Pots-Intervention Survey dataset (no real PII)
│  ├─ Post_Measurement_Data_synth.xlsx       # Pots-Intervention Measurements dataset (no real PHI)    
│  └─ hcw_data_dictionary.csv                # variable names, labels, codes
├─ script/
│  ├─ 00_setup.sas                           # paths, formats, recodes, derived *_c variables
│  ├─ 01_table2_demographics.sas             # Table 2 (RTF)
│  ├─ 02_table3_wilcoxon.sas                 # Table 3 (RTF)
│  ├─ 03_table4_ hotellingsT2.sas            # Table 4 (RTF)
│  └─ 99_run_all.sas                     	 # convenience wrapper to run 00→03 in order
├─ results/
│  ├─ Table2_Demographics.rtf
│  ├─ Table3_Wilcoxon.rtf
│  └─ Table4_Hotelling.rtf
└─ README.md
```

## 🔐 Data access & privacy

- **No real participant data are included.**  
- **Synthetic datasets** are provided so anyone can run the pipeline without access to real data.

## 🧰 Requirements

This repo uses **SAS**. It runs in SAS Studio (SAS OnDemand for Academics or on-prem) and in local SAS installations.

- SAS 9.4M6+ or Viya SAS procedures recommended.
- RTF output uses ODS RTF with `style=Journal`.

## ▶️ How to run (SAS)

### Option A — run everything
1. Open `script/99_run_all.sas`.
2. Edit the **project root** (if the script asks for it) so paths point to this repo.
3. Submit the program. It will:
   - Read all the datasets
   - Create derived variables and formats
   - Generate **Table 2–4** as RTF files in `results/`

### Option B — run step-by-step
1. `script/00_setup.sas` — sets librefs/paths, formats, recodes; creates character-coded variables used in the analysis.
2. `script/01_table2_demographics.sas` — writes **Table 2** (Baseline and post-intervention survey demographics) to RTF.
3. `script/02_table3_wilcoxon.sas` — writes **Table 3** (Comparison between baseline and post-intervention characteristics of study participants) to RTF.
4. `script/03_table3_hotellingsT2.sas` — writes **Table 4** (Comparison between baseline and post-intervention characteristics of study participants) to RTF.

Results appear in `results/` with the filenames listed in the tree above.

## 🧪 Reproducibility notes

- The synthetic datasets are fixed for consistency across runs.
- Nonparametric tests (Wilcoxon signed-rank) were used due to non-normality; multivariate differences assessed via Hotelling’s T².  
- All tables are rendered as **RTF** to match journal-style outputs.  
- Scripts use **relative paths** rooted at the repository to avoid hard-coding local directories.

## 📚 License & citation

- Code is provided under the **MIT License** (see `LICENSE`).
- If you use this repository, please cite the paper above and this repo.

```
Naseem, M.T., et al. (2025). Impact of a Workplace Wellness Program - Analysis. GitHub repository.
```

## 🙌 Acknowledgments

This repository reflects work by the SNMHS team and collaborators listed in the paper. Analytic code was prepared by **Mohammad Talal Naseem** and colleagues for reproducibility and educational purposes.

