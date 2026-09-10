# Data Visualisation Project — Year 2

**Module:** DATA 2006 Data Visualisation, TU850/2
**Author:** Amy Webb (C24423456)
**Report Date:** 09-04-2026

## Overview

This project explores global CO2 emissions data from 1950–2024, examining trends across countries, fuel types, and time periods to assess whether international climate pledges (e.g. the Paris Agreement) have translated into meaningful reductions in emissions.

## Dataset

- **Source:** [Global CO2 Emissions by Country 1950–2024](https://www.kaggle.com/datasets/lucalullo/global-co2-emissions-by-country-1950-2024) (Kaggle, derived from Our World in Data)
- **Size:** ~14,900 records covering 199 countries
- **Key columns:**
  - `country`, `iso_code`, `year`
  - `co2` — total territorial CO2 emissions (MtCO2)
  - `co2_per_capita`
  - `coal_co2`, `oil_co2`, `gas_co2`, `cement_co2`
  - `consumption_co2` — includes emissions embedded in trade

## Why This Dataset

Chosen for its relevance to global climate action and accountability, and its suitability for country-level comparisons and world map visualisations.

## Exploratory Visualisations

1. **Histogram** — Distribution of CO2 per capita (2022): right-skewed, with a handful of oil-rich countries (e.g. Qatar, Kuwait) as high-emission outliers.
2. **Line graph** — US emissions trend (1990–2023): peak in 2005–2007, decline linked more to the 2008 recession and COVID-19 than to policy.
3. **Multi-line graph** — China, USA, Europe, India (1990–2023): Western nations declining post-Paris Agreement while China and India continue to rise.
4. **Choropleth map** — Global emissions (2022): China and USA dominate; large data gaps across Africa.

## The Big Idea

> Despite years of climate pledges and international conventions, global CO2 emissions continue to rise, driven by fuel types such as coal, oil, and gas. Until the world's largest emitters commit to fuel-specific goals rather than vague promises, the gap between rhetoric and data will only widen.

**Audience:** Government climate advisors and policymakers who use data to inform decisions affecting national and global climate strategy.

## Explanatory Visualisations

1. **Bar chart** — Emissions by fuel type (all years): coal accounts for ~400,000 MtCO2, more than oil and gas combined.
2. **Stacked bar chart** — Fuel mix of top 5 emitters (2022): China and India are coal-dominant; the USA is more balanced; Russia leans heavily on gas.
3. **Line graph** — Global emissions over time (1990–2024): the only significant dips occur during the 2008 financial crisis and the 2020 pandemic, both followed by sharp rebounds.

## Conclusion

The data shows a persistent gap between climate commitments and actual outcomes. Coal remains the largest single contributor to global emissions, led by China and India, while reductions in Europe and the USA are offset by growth elsewhere. Historical dips in emissions have been driven by economic or public health crises, not policy — reinforcing the need for binding, fuel-specific, country-level targets rather than broad net-zero pledges.

## References

- Lullo, L. (n.d.). *Global CO2 emissions by country 1950–2024* [Dataset]. Kaggle.
- DataCamp. (n.d.). *Free Introduction to R* & *Intermediate R*.
- Hatunic-Webster, E. (2026). Course materials, DATA 2006 Data Visualisation, TU Dublin.
