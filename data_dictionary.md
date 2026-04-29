# Data Dictionary

This file documents the variables in the processed dataset used for the replication package.

## Processed dataset

Main processed dataset:

`processed/data_processed_g7.xlsx`

The dataset is a balanced annual panel for the Group of Seven (G7) countries over 2000–2020.

Countries included:

- Canada
- France
- Germany
- Italy
- Japan
- United Kingdom
- United States

## Variables in the processed dataset

### Country

Country name.

- Unit: text
- Role: panel identifier
- Source: constructed

### Year

Calendar year.

- Unit: year
- Role: time identifier
- Source: constructed

### Debt

General government gross debt.

- Unit: percent of GDP
- Role: dependent variable
- Source: IMF World Economic Outlook (WEO)

### PSNW

Public sector net worth.

- Unit: percent of GDP
- Role: moderator
- Source: IMF Public Sector Balance Sheet (PSBS) Database

### BrentOilPrice

Brent crude oil price.

- Unit: US dollars per barrel
- Role: oil-price variable
- Source: U.S. Energy Information Administration (EIA)

### CPI

Consumer price inflation.

- Unit: annual percent
- Role: control variable
- Source: World Bank World Development Indicators (WDI), based on IMF International Financial Statistics (IFS)

### PolicyRate

Policy interest rate.

- Unit: percent
- Role: control variable
- Source: Bank for International Settlements (BIS), Central Bank Policy Rates

### OutputGap

Output gap.

- Unit: percent of potential GDP
- Role: control variable
- Source: IMF World Economic Outlook (WEO)

### PrimaryBalance

Government primary balance.

- Unit: percent of GDP
- Role: control variable
- Source: IMF DataMapper

### GFC0809

Global financial crisis dummy.

- Unit: 0/1
- Role: auxiliary variable
- Definition: equals 1 for 2008 and 2009, and 0 otherwise
- Source: constructed by the author

### COVID2020

COVID-19 dummy.

- Unit: 0/1
- Role: auxiliary variable
- Definition: equals 1 for 2020, and 0 otherwise
- Source: constructed by the author

## Raw source files

Raw source files are stored in:

`raw/`

The processed dataset is stored in:

`processed/`

The raw files are retained in their downloaded formats for transparency and replication.

## Variables constructed in the EViews code

The EViews replication program constructs the standardized variables, lagged variables, interaction terms, debt-change variable, and unexpected oil-price component used in the main and supplementary analyses.

Key constructed variables include:

- pooled z-scores of `PSNW`, `BrentOilPrice`, `CPI`, `PolicyRate`, `OutputGap`, and `PrimaryBalance`
- one-period lags of `Debt` and the standardized control variables
- the main interaction term: `z(BrentOilPrice) × L1 z(PSNW)`
- annual change in debt
- unexpected oil-price component from an AR(1) model of annual log Brent prices
- interaction between the unexpected oil-price component and lagged standardized PSNW

## Descriptive figure data

The main manuscript includes descriptive figures based on general government gross debt, public sector net worth, public-sector balance-sheet components, Brent oil prices, and oil-related exposure indicators.

Any raw file used only for descriptive visualization is not part of the headline econometric specification unless explicitly included in the processed dataset.

## Note

Raw data remain subject to the terms and conditions of the original data providers.
