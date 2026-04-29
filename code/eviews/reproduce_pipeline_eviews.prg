
'===============================================================================
' EViews reproduction program
' Article: Public Debt Sensitivity to Oil Shocks in the G7:
'          The Role of Public Sector Net Worth
'
' PURPOSE
'   Reproduce the econometric pipeline used in the manuscript:
'   - headline dynamic two-way FE model
'   - local projections
'   - country-level model-implied sensitivity
'   - supplementary auxiliary specifications
'   - robustness checks
'
' BEFORE RUNNING
'   1) Open the workfile that contains the panel data in LONG format.
'   2) Make sure the active page contains one row per Country-Year observation.
'   3) Edit the variable-name macros below only if your raw variable names differ.
'
' IMPORTANT
'   - This script uses conservative t-based small-cluster inference (df = G-1),
'     which is the fallback strategy adopted in the paper.
'   - The covariance option below is written as "cov=whitecross", which is the
'     usual EViews label for cross-section clustered covariance. If your EViews
'     version uses a different synonym, edit only the macro %CLUSTEROPT below.
'===============================================================================

'----------------------------
' 0. USER SETTINGS
'----------------------------
%CLUSTEROPT = "cov=whitecross"

' Raw variable names in the active page
%vCountry = "Country"
%vYear    = "Year"
%vDebt    = "Debt"
%vPSNW    = "PSNW"
%vOil     = "BerntOilPrice"
%vCPI     = "CPI"
%vPR      = "PolicyRate"
%vOG      = "OutputGap"
%vPB      = "PrimaryBalance"

' Small-cluster degrees of freedom
!df_full = 6
!df_drop = 5

'----------------------------
' 1. PANEL STRUCTURE
'----------------------------
pagestruct {%vCountry} {%vYear}
smpl @all

'----------------------------
' 2. BASIC TRANSFORMATIONS
'----------------------------
' 2.1 Crisis dummies (used only in companion specification)
series GFC0809  = @recode({%vYear}=2008 or {%vYear}=2009, 1, 0)
series COVID2020 = @recode({%vYear}=2020, 1, 0)

' 2.2 Pooled z-scores for all continuous RHS variables
series z_psnw           = ({%vPSNW}-@mean({%vPSNW}))/@stdev({%vPSNW})
series z_oilprice       = ({%vOil}-@mean({%vOil}))/@stdev({%vOil})
series z_cpi            = ({%vCPI}-@mean({%vCPI}))/@stdev({%vCPI})
series z_policyrate     = ({%vPR}-@mean({%vPR}))/@stdev({%vPR})
series z_outputgap      = ({%vOG}-@mean({%vOG}))/@stdev({%vOG})
series z_primarybalance = ({%vPB}-@mean({%vPB}))/@stdev({%vPB})

' 2.3 Lag structure
series l1_debt             = {%vDebt}(-1)
series l1_z_psnw           = z_psnw(-1)
series l1_z_cpi            = z_cpi(-1)
series l1_z_policyrate     = z_policyrate(-1)
series l1_z_outputgap      = z_outputgap(-1)
series l1_z_primarybalance = z_primarybalance(-1)

' 2.4 Main interaction term
series interaction_level = z_oilprice*l1_z_psnw

' 2.5 Change in debt
series d_debt = d({%vDebt})

' 2.6 Unexpected oil component
series log_oil = log({%vOil})
smpl if {%vYear}>=2001 and {%vYear}<=2020
equation eq_oil_ar1.ls log_oil c log_oil(-1)
eq_oil_ar1.makeresid unexpected_oil_raw
smpl @all
series z_unexpected_oil = (unexpected_oil_raw-@mean(unexpected_oil_raw))/@stdev(unexpected_oil_raw)
series interaction_unexpected = z_unexpected_oil*l1_z_psnw

'----------------------------
' 3. SAMPLE DEFINITIONS
'----------------------------
' Main estimation sample after lag structure
smpl if {%vYear}>=2001 and {%vYear}<=2020

'----------------------------
' 4. TABLE 1: DESCRIPTIVE STATISTICS
'----------------------------
smpl @all
table tbl_desc(8,6)
tbl_desc(1,1) = "Variable"
tbl_desc(1,2) = "N"
tbl_desc(1,3) = "Mean"
tbl_desc(1,4) = "SD"
tbl_desc(1,5) = "Min"
tbl_desc(1,6) = "Max"

tbl_desc(2,1) = "Debt"
tbl_desc(2,2) = @str(@obs({%vDebt}))
tbl_desc(2,3) = @str(@mean({%vDebt}),"f.3")
tbl_desc(2,4) = @str(@stdev({%vDebt}),"f.3")
tbl_desc(2,5) = @str(@min({%vDebt}),"f.3")
tbl_desc(2,6) = @str(@max({%vDebt}),"f.3")

tbl_desc(3,1) = "PSNW"
tbl_desc(3,2) = @str(@obs({%vPSNW}))
tbl_desc(3,3) = @str(@mean({%vPSNW}),"f.3")
tbl_desc(3,4) = @str(@stdev({%vPSNW}),"f.3")
tbl_desc(3,5) = @str(@min({%vPSNW}),"f.3")
tbl_desc(3,6) = @str(@max({%vPSNW}),"f.3")

tbl_desc(4,1) = "Brent oil price"
tbl_desc(4,2) = @str(@obs({%vOil}))
tbl_desc(4,3) = @str(@mean({%vOil}),"f.3")
tbl_desc(4,4) = @str(@stdev({%vOil}),"f.3")
tbl_desc(4,5) = @str(@min({%vOil}),"f.3")
tbl_desc(4,6) = @str(@max({%vOil}),"f.3")

tbl_desc(5,1) = "CPI"
tbl_desc(5,2) = @str(@obs({%vCPI}))
tbl_desc(5,3) = @str(@mean({%vCPI}),"f.3")
tbl_desc(5,4) = @str(@stdev({%vCPI}),"f.3")
tbl_desc(5,5) = @str(@min({%vCPI}),"f.3")
tbl_desc(5,6) = @str(@max({%vCPI}),"f.3")

tbl_desc(6,1) = "Policy rate"
tbl_desc(6,2) = @str(@obs({%vPR}))
tbl_desc(6,3) = @str(@mean({%vPR}),"f.3")
tbl_desc(6,4) = @str(@stdev({%vPR}),"f.3")
tbl_desc(6,5) = @str(@min({%vPR}),"f.3")
tbl_desc(6,6) = @str(@max({%vPR}),"f.3")

tbl_desc(7,1) = "Output gap"
tbl_desc(7,2) = @str(@obs({%vOG}))
tbl_desc(7,3) = @str(@mean({%vOG}),"f.3")
tbl_desc(7,4) = @str(@stdev({%vOG}),"f.3")
tbl_desc(7,5) = @str(@min({%vOG}),"f.3")
tbl_desc(7,6) = @str(@max({%vOG}),"f.3")

tbl_desc(8,1) = "Primary balance"
tbl_desc(8,2) = @str(@obs({%vPB}))
tbl_desc(8,3) = @str(@mean({%vPB}),"f.3")
tbl_desc(8,4) = @str(@stdev({%vPB}),"f.3")
tbl_desc(8,5) = @str(@min({%vPB}),"f.3")
tbl_desc(8,6) = @str(@max({%vPB}),"f.3")

'----------------------------
' 5. HEADLINE MODEL (TABLE 2)
'----------------------------
smpl if {%vYear}>=2001 and {%vYear}<=2020
equation eq_head.ls({%CLUSTEROPT}) {%vDebt} c l1_debt l1_z_psnw interaction_level l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)

' Coefficients and conservative p-values
!b_l1debt  = eq_head.@coefs(2)
!se_l1debt = @sqrt(eq_head.@coefcov(2,2))
!t_l1debt  = !b_l1debt/!se_l1debt
!p_l1debt  = 2*(1-@ctdist(@abs(!t_l1debt),!df_full))

!b_l1psnw  = eq_head.@coefs(3)
!se_l1psnw = @sqrt(eq_head.@coefcov(3,3))
!t_l1psnw  = !b_l1psnw/!se_l1psnw
!p_l1psnw  = 2*(1-@ctdist(@abs(!t_l1psnw),!df_full))

!b_inter   = eq_head.@coefs(4)
!se_inter  = @sqrt(eq_head.@coefcov(4,4))
!t_inter   = !b_inter/!se_inter
!p_inter   = 2*(1-@ctdist(@abs(!t_inter),!df_full))

!b_l1cpi   = eq_head.@coefs(5)
!se_l1cpi  = @sqrt(eq_head.@coefcov(5,5))
!t_l1cpi   = !b_l1cpi/!se_l1cpi
!p_l1cpi   = 2*(1-@ctdist(@abs(!t_l1cpi),!df_full))

!b_l1pr    = eq_head.@coefs(6)
!se_l1pr   = @sqrt(eq_head.@coefcov(6,6))
!t_l1pr    = !b_l1pr/!se_l1pr
!p_l1pr    = 2*(1-@ctdist(@abs(!t_l1pr),!df_full))

!b_l1og    = eq_head.@coefs(7)
!se_l1og   = @sqrt(eq_head.@coefcov(7,7))
!t_l1og    = !b_l1og/!se_l1og
!p_l1og    = 2*(1-@ctdist(@abs(!t_l1og),!df_full))

!b_l1pb    = eq_head.@coefs(8)
!se_l1pb   = @sqrt(eq_head.@coefcov(8,8))
!t_l1pb    = !b_l1pb/!se_l1pb
!p_l1pb    = 2*(1-@ctdist(@abs(!t_l1pb),!df_full))

table tbl_head(8,4)
tbl_head(1,1) = "Variable"
tbl_head(1,2) = "Coefficient"
tbl_head(1,3) = "SE"
tbl_head(1,4) = "p-value"

tbl_head(2,1) = "L1 Debt"
tbl_head(2,2) = @str(!b_l1debt,"f.3")
tbl_head(2,3) = @str(!se_l1debt,"f.3")
if !p_l1debt<0.001 then
  tbl_head(2,4) = "<0.001"
else
  tbl_head(2,4) = @str(!p_l1debt,"f.3")
endif

tbl_head(3,1) = "L1 z(PSNW)"
tbl_head(3,2) = @str(!b_l1psnw,"f.3")
tbl_head(3,3) = @str(!se_l1psnw,"f.3")
tbl_head(3,4) = @str(!p_l1psnw,"f.3")

tbl_head(4,1) = "z(Brent oil price) x L1 z(PSNW)"
tbl_head(4,2) = @str(!b_inter,"f.3")
tbl_head(4,3) = @str(!se_inter,"f.3")
tbl_head(4,4) = @str(!p_inter,"f.3")

tbl_head(5,1) = "L1 z(CPI)"
tbl_head(5,2) = @str(!b_l1cpi,"f.3")
tbl_head(5,3) = @str(!se_l1cpi,"f.3")
tbl_head(5,4) = @str(!p_l1cpi,"f.3")

tbl_head(6,1) = "L1 z(Policy rate)"
tbl_head(6,2) = @str(!b_l1pr,"f.3")
tbl_head(6,3) = @str(!se_l1pr,"f.3")
tbl_head(6,4) = @str(!p_l1pr,"f.3")

tbl_head(7,1) = "L1 z(Output gap)"
tbl_head(7,2) = @str(!b_l1og,"f.3")
tbl_head(7,3) = @str(!se_l1og,"f.3")
tbl_head(7,4) = @str(!p_l1og,"f.3")

tbl_head(8,1) = "L1 z(Primary balance)"
tbl_head(8,2) = @str(!b_l1pb,"f.3")
tbl_head(8,3) = @str(!se_l1pb,"f.3")
tbl_head(8,4) = @str(!p_l1pb,"f.3")

'----------------------------
' 6. FIGURE 1 DATA AND GRAPH
'----------------------------
!xmin = @min(l1_z_psnw)
!xmax = @max(l1_z_psnw)

pagecreate(page=fig1page) u 201
smpl @all
series psnw_grid = !xmin + (@obsnum-1)*(!xmax-!xmin)/200
series relsens   = !b_inter*psnw_grid
series upper95   = relsens + 1.96*@abs(psnw_grid)*!se_inter
series lower95   = relsens - 1.96*@abs(psnw_grid)*!se_inter
series zero_line = 0
group g_fig1 psnw_grid relsens upper95 lower95 zero_line
graph fig1.xyline g_fig1
fig1.label(d) Figure 1. Relative differential debt sensitivity to common oil-price conditions across levels of lagged standardized public sector net worth.
pageselect Untitled

'----------------------------
' 7. LOCAL PROJECTIONS (TABLE 3)
'----------------------------
table tbl_lp(5,6)
tbl_lp(1,1) = "Horizon"
tbl_lp(1,2) = "Coef. on interaction"
tbl_lp(1,3) = "SE"
tbl_lp(1,4) = "p-value"
tbl_lp(1,5) = "N"
tbl_lp(1,6) = "R2"

for !h = 0 to 3
  if !h=0 then
    %dep = "{%vDebt}"
  else
    %dep = "{%vDebt}(+"+@str(!h)+")"
  endif

  smpl if {%vYear}>=2001 and {%vYear}<=(2020-!h)
  %eqname = "eq_lp_"+@str(!h)
  equation {%eqname}.ls({%CLUSTEROPT}) {%dep} c l1_debt l1_z_psnw interaction_level l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)

  !b_lp  = {%eqname}.@coefs(4)
  !se_lp = @sqrt({%eqname}.@coefcov(4,4))
  !t_lp  = !b_lp/!se_lp
  !p_lp  = 2*(1-@ctdist(@abs(!t_lp),!df_full))

  !row = !h+2
  tbl_lp(!row,1) = @str(!h)
  tbl_lp(!row,2) = @str(!b_lp,"f.3")
  tbl_lp(!row,3) = @str(!se_lp,"f.3")
  if !p_lp<0.001 then
    tbl_lp(!row,4) = "<0.001"
  else
    tbl_lp(!row,4) = @str(!p_lp,"f.3")
  endif
  tbl_lp(!row,5) = @str({%eqname}.@regobs)
  tbl_lp(!row,6) = @str({%eqname}.@r2,"f.3")
next

'----------------------------
' 8. COUNTRY-LEVEL MODEL-IMPLIED SENSITIVITY (TABLE 4)
'----------------------------
smpl if {%vYear}>=2001 and {%vYear}<=2020

!m_can = @meanbys(l1_z_psnw,{%vCountry}="Canada")
!m_fra = @meanbys(l1_z_psnw,{%vCountry}="France")
!m_ger = @meanbys(l1_z_psnw,{%vCountry}="Germany")
!m_ita = @meanbys(l1_z_psnw,{%vCountry}="Italy")
!m_jpn = @meanbys(l1_z_psnw,{%vCountry}="Japan")
!m_uk  = @meanbys(l1_z_psnw,{%vCountry}="United Kingdom")
!m_usa = @meanbys(l1_z_psnw,{%vCountry}="United States")

table tbl_ctry(8,3)
tbl_ctry(1,1) = "Country"
tbl_ctry(1,2) = "Mean L1 z(PSNW)"
tbl_ctry(1,3) = "Relative differential sensitivity"

tbl_ctry(2,1) = "Canada"
tbl_ctry(2,2) = @str(!m_can,"f.3")
tbl_ctry(2,3) = @str(!b_inter*!m_can,"f.3")

tbl_ctry(3,1) = "United States"
tbl_ctry(3,2) = @str(!m_usa,"f.3")
tbl_ctry(3,3) = @str(!b_inter*!m_usa,"f.3")

tbl_ctry(4,1) = "Japan"
tbl_ctry(4,2) = @str(!m_jpn,"f.3")
tbl_ctry(4,3) = @str(!b_inter*!m_jpn,"f.3")

tbl_ctry(5,1) = "Germany"
tbl_ctry(5,2) = @str(!m_ger,"f.3")
tbl_ctry(5,3) = @str(!b_inter*!m_ger,"f.3")

tbl_ctry(6,1) = "France"
tbl_ctry(6,2) = @str(!m_fra,"f.3")
tbl_ctry(6,3) = @str(!b_inter*!m_fra,"f.3")

tbl_ctry(7,1) = "United Kingdom"
tbl_ctry(7,2) = @str(!m_uk,"f.3")
tbl_ctry(7,3) = @str(!b_inter*!m_uk,"f.3")

tbl_ctry(8,1) = "Italy"
tbl_ctry(8,2) = @str(!m_ita,"f.3")
tbl_ctry(8,3) = @str(!b_inter*!m_ita,"f.3")

' Country-year values used in Figure 2
smpl if {%vYear}>=2001 and {%vYear}<=2020
series relsens_it = !b_inter*l1_z_psnw

'----------------------------
' 9. SUPPLEMENTARY: COMPANION SPECIFICATION (TABLE S1)
'----------------------------
smpl if {%vYear}>=2001 and {%vYear}<=2020
equation eq_comp.ls({%CLUSTEROPT}) {%vDebt} c l1_debt l1_z_psnw z_oilprice interaction_level l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance GFC0809 COVID2020 @expand({%vCountry},@dropfirst)

table tbl_s1(11,4)
tbl_s1(1,1) = "Variable"
tbl_s1(1,2) = "Coef."
tbl_s1(1,3) = "Clustered SE"
tbl_s1(1,4) = "p-value"

for !i = 2 to 10
  !b  = eq_comp.@coefs(!i)
  !se = @sqrt(eq_comp.@coefcov(!i,!i))
  !t  = !b/!se
  !p  = 2*(1-@ctdist(@abs(!t),!df_full))

  if !i=2 then tbl_s1(!i,1)="L1 Debt"
  if !i=3 then tbl_s1(!i,1)="L1 z(PSNW)"
  if !i=4 then tbl_s1(!i,1)="z(Brent oil price)"
  if !i=5 then tbl_s1(!i,1)="z(Brent oil price) x L1 z(PSNW)"
  if !i=6 then tbl_s1(!i,1)="L1 z(CPI)"
  if !i=7 then tbl_s1(!i,1)="L1 z(Policy rate)"
  if !i=8 then tbl_s1(!i,1)="L1 z(Output gap)"
  if !i=9 then tbl_s1(!i,1)="L1 z(Primary balance)"
  if !i=10 then tbl_s1(!i,1)="GFC 2008-2009"
  tbl_s1(!i,2) = @str(!b,"f.3")
  tbl_s1(!i,3) = @str(!se,"f.3")
  if !p<0.001 then
    tbl_s1(!i,4) = "<0.001"
  else
    tbl_s1(!i,4) = @str(!p,"f.3")
  endif
next

!b  = eq_comp.@coefs(11)
!se = @sqrt(eq_comp.@coefcov(11,11))
!t  = !b/!se
!p  = 2*(1-@ctdist(@abs(!t),!df_full))
tbl_s1(11,1)="COVID-19 (2020)"
tbl_s1(11,2)=@str(!b,"f.3")
tbl_s1(11,3)=@str(!se,"f.3")
if !p<0.001 then
  tbl_s1(11,4)="<0.001"
else
  tbl_s1(11,4)=@str(!p,"f.3")
endif

'----------------------------
' 10. SUPPLEMENTARY: UNEXPECTED OIL COMPONENT (TABLE S2)
'----------------------------
equation eq_unexp.ls({%CLUSTEROPT}) {%vDebt} c l1_debt l1_z_psnw interaction_unexpected l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)

table tbl_s2(8,4)
tbl_s2(1,1)="Variable"
tbl_s2(1,2)="Coef."
tbl_s2(1,3)="Clustered SE"
tbl_s2(1,4)="p-value"

for !i = 2 to 8
  !b  = eq_unexp.@coefs(!i)
  !se = @sqrt(eq_unexp.@coefcov(!i,!i))
  !t  = !b/!se
  !p  = 2*(1-@ctdist(@abs(!t),!df_full))

  if !i=2 then tbl_s2(!i,1)="L1 Debt"
  if !i=3 then tbl_s2(!i,1)="L1 z(PSNW)"
  if !i=4 then tbl_s2(!i,1)="z(Unexpected oil component) x L1 z(PSNW)"
  if !i=5 then tbl_s2(!i,1)="L1 z(CPI)"
  if !i=6 then tbl_s2(!i,1)="L1 z(Policy rate)"
  if !i=7 then tbl_s2(!i,1)="L1 z(Output gap)"
  if !i=8 then tbl_s2(!i,1)="L1 z(Primary balance)"

  tbl_s2(!i,2)=@str(!b,"f.3")
  tbl_s2(!i,3)=@str(!se,"f.3")
  if !p<0.001 then
    tbl_s2(!i,4)="<0.001"
  else
    tbl_s2(!i,4)=@str(!p,"f.3")
  endif
next

'----------------------------
' 11. SUPPLEMENTARY: CHANGE IN DEBT (TABLE S3)
'----------------------------
equation eq_ddebt.ls({%CLUSTEROPT}) d_debt c l1_z_psnw interaction_level l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)

table tbl_s3(7,4)
tbl_s3(1,1)="Variable"
tbl_s3(1,2)="Coef."
tbl_s3(1,3)="Clustered SE"
tbl_s3(1,4)="p-value"

for !i = 2 to 7
  !b  = eq_ddebt.@coefs(!i)
  !se = @sqrt(eq_ddebt.@coefcov(!i,!i))
  !t  = !b/!se
  !p  = 2*(1-@ctdist(@abs(!t),!df_full))

  if !i=2 then tbl_s3(!i,1)="L1 z(PSNW)"
  if !i=3 then tbl_s3(!i,1)="z(Brent oil price) x L1 z(PSNW)"
  if !i=4 then tbl_s3(!i,1)="L1 z(CPI)"
  if !i=5 then tbl_s3(!i,1)="L1 z(Policy rate)"
  if !i=6 then tbl_s3(!i,1)="L1 z(Output gap)"
  if !i=7 then tbl_s3(!i,1)="L1 z(Primary balance)"

  tbl_s3(!i,2)=@str(!b,"f.3")
  tbl_s3(!i,3)=@str(!se,"f.3")
  if !p<0.001 then
    tbl_s3(!i,4)="<0.001"
  else
    tbl_s3(!i,4)=@str(!p,"f.3")
  endif
next

'----------------------------
' 12. SUPPLEMENTARY: CHANGE IN DEBT WITH UNEXPECTED OIL (TABLE S4)
'----------------------------
equation eq_ddebt_unexp.ls({%CLUSTEROPT}) d_debt c l1_z_psnw interaction_unexpected l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)

table tbl_s4(7,4)
tbl_s4(1,1)="Variable"
tbl_s4(1,2)="Coef."
tbl_s4(1,3)="Clustered SE"
tbl_s4(1,4)="p-value"

for !i = 2 to 7
  !b  = eq_ddebt_unexp.@coefs(!i)
  !se = @sqrt(eq_ddebt_unexp.@coefcov(!i,!i))
  !t  = !b/!se
  !p  = 2*(1-@ctdist(@abs(!t),!df_full))

  if !i=2 then tbl_s4(!i,1)="L1 z(PSNW)"
  if !i=3 then tbl_s4(!i,1)="z(Unexpected oil component) x L1 z(PSNW)"
  if !i=4 then tbl_s4(!i,1)="L1 z(CPI)"
  if !i=5 then tbl_s4(!i,1)="L1 z(Policy rate)"
  if !i=6 then tbl_s4(!i,1)="L1 z(Output gap)"
  if !i=7 then tbl_s4(!i,1)="L1 z(Primary balance)"

  tbl_s4(!i,2)=@str(!b,"f.3")
  tbl_s4(!i,3)=@str(!se,"f.3")
  if !p<0.001 then
    tbl_s4(!i,4)="<0.001"
  else
    tbl_s4(!i,4)=@str(!p,"f.3")
  endif
next

'----------------------------
' 13. SUPPLEMENTARY: LEAVE-ONE-COUNTRY-OUT (TABLE S5)
'----------------------------
table tbl_s5(8,7)
tbl_s5(1,1)="Excluded country"
tbl_s5(1,2)="Coef. on interaction"
tbl_s5(1,3)="Clustered SE"
tbl_s5(1,4)="p-value"
tbl_s5(1,5)="N"
tbl_s5(1,6)="Clusters"
tbl_s5(1,7)="R2"

' Without Canada
smpl if {%vYear}>=2001 and {%vYear}<=2020 and {%vCountry}<>"Canada"
equation eq_loo_can.ls({%CLUSTEROPT}) {%vDebt} c l1_debt l1_z_psnw interaction_level l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)
!b  = eq_loo_can.@coefs(4)
!se = @sqrt(eq_loo_can.@coefcov(4,4))
!t  = !b/!se
!p  = 2*(1-@ctdist(@abs(!t),!df_drop))
tbl_s5(2,1)="Canada"
tbl_s5(2,2)=@str(!b,"f.3")
tbl_s5(2,3)=@str(!se,"f.3")
tbl_s5(2,4)=@str(!p,"f.3")
tbl_s5(2,5)=@str(eq_loo_can.@regobs)
tbl_s5(2,6)="6"
tbl_s5(2,7)=@str(eq_loo_can.@r2,"f.3")

' Without France
smpl if {%vYear}>=2001 and {%vYear}<=2020 and {%vCountry}<>"France"
equation eq_loo_fra.ls({%CLUSTEROPT}) {%vDebt} c l1_debt l1_z_psnw interaction_level l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)
!b  = eq_loo_fra.@coefs(4)
!se = @sqrt(eq_loo_fra.@coefcov(4,4))
!t  = !b/!se
!p  = 2*(1-@ctdist(@abs(!t),!df_drop))
tbl_s5(3,1)="France"
tbl_s5(3,2)=@str(!b,"f.3")
tbl_s5(3,3)=@str(!se,"f.3")
tbl_s5(3,4)=@str(!p,"f.3")
tbl_s5(3,5)=@str(eq_loo_fra.@regobs)
tbl_s5(3,6)="6"
tbl_s5(3,7)=@str(eq_loo_fra.@r2,"f.3")

' Without Germany
smpl if {%vYear}>=2001 and {%vYear}<=2020 and {%vCountry}<>"Germany"
equation eq_loo_ger.ls({%CLUSTEROPT}) {%vDebt} c l1_debt l1_z_psnw interaction_level l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)
!b  = eq_loo_ger.@coefs(4)
!se = @sqrt(eq_loo_ger.@coefcov(4,4))
!t  = !b/!se
!p  = 2*(1-@ctdist(@abs(!t),!df_drop))
tbl_s5(4,1)="Germany"
tbl_s5(4,2)=@str(!b,"f.3")
tbl_s5(4,3)=@str(!se,"f.3")
tbl_s5(4,4)=@str(!p,"f.3")
tbl_s5(4,5)=@str(eq_loo_ger.@regobs)
tbl_s5(4,6)="6"
tbl_s5(4,7)=@str(eq_loo_ger.@r2,"f.3")

' Without Italy
smpl if {%vYear}>=2001 and {%vYear}<=2020 and {%vCountry}<>"Italy"
equation eq_loo_ita.ls({%CLUSTEROPT}) {%vDebt} c l1_debt l1_z_psnw interaction_level l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)
!b  = eq_loo_ita.@coefs(4)
!se = @sqrt(eq_loo_ita.@coefcov(4,4))
!t  = !b/!se
!p  = 2*(1-@ctdist(@abs(!t),!df_drop))
tbl_s5(5,1)="Italy"
tbl_s5(5,2)=@str(!b,"f.3")
tbl_s5(5,3)=@str(!se,"f.3")
tbl_s5(5,4)=@str(!p,"f.3")
tbl_s5(5,5)=@str(eq_loo_ita.@regobs)
tbl_s5(5,6)="6"
tbl_s5(5,7)=@str(eq_loo_ita.@r2,"f.3")

' Without Japan
smpl if {%vYear}>=2001 and {%vYear}<=2020 and {%vCountry}<>"Japan"
equation eq_loo_jpn.ls({%CLUSTEROPT}) {%vDebt} c l1_debt l1_z_psnw interaction_level l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)
!b  = eq_loo_jpn.@coefs(4)
!se = @sqrt(eq_loo_jpn.@coefcov(4,4))
!t  = !b/!se
!p  = 2*(1-@ctdist(@abs(!t),!df_drop))
tbl_s5(6,1)="Japan"
tbl_s5(6,2)=@str(!b,"f.3")
tbl_s5(6,3)=@str(!se,"f.3")
tbl_s5(6,4)=@str(!p,"f.3")
tbl_s5(6,5)=@str(eq_loo_jpn.@regobs)
tbl_s5(6,6)="6"
tbl_s5(6,7)=@str(eq_loo_jpn.@r2,"f.3")

' Without United Kingdom
smpl if {%vYear}>=2001 and {%vYear}<=2020 and {%vCountry}<>"United Kingdom"
equation eq_loo_uk.ls({%CLUSTEROPT}) {%vDebt} c l1_debt l1_z_psnw interaction_level l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)
!b  = eq_loo_uk.@coefs(4)
!se = @sqrt(eq_loo_uk.@coefcov(4,4))
!t  = !b/!se
!p  = 2*(1-@ctdist(@abs(!t),!df_drop))
tbl_s5(7,1)="United Kingdom"
tbl_s5(7,2)=@str(!b,"f.3")
tbl_s5(7,3)=@str(!se,"f.3")
tbl_s5(7,4)=@str(!p,"f.3")
tbl_s5(7,5)=@str(eq_loo_uk.@regobs)
tbl_s5(7,6)="6"
tbl_s5(7,7)=@str(eq_loo_uk.@r2,"f.3")

' Without United States
smpl if {%vYear}>=2001 and {%vYear}<=2020 and {%vCountry}<>"United States"
equation eq_loo_usa.ls({%CLUSTEROPT}) {%vDebt} c l1_debt l1_z_psnw interaction_level l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)
!b  = eq_loo_usa.@coefs(4)
!se = @sqrt(eq_loo_usa.@coefcov(4,4))
!t  = !b/!se
!p  = 2*(1-@ctdist(@abs(!t),!df_drop))
tbl_s5(8,1)="United States"
tbl_s5(8,2)=@str(!b,"f.3")
tbl_s5(8,3)=@str(!se,"f.3")
tbl_s5(8,4)=@str(!p,"f.3")
tbl_s5(8,5)=@str(eq_loo_usa.@regobs)
tbl_s5(8,6)="6"
tbl_s5(8,7)=@str(eq_loo_usa.@r2,"f.3")

'----------------------------
' 14. SUPPLEMENTARY: CANADA-EXCLUSION ROBUSTNESS (TABLE S6)
'----------------------------
smpl if {%vYear}>=2001 and {%vYear}<=2020 and {%vCountry}<>"Canada"
equation eq_nocan.ls({%CLUSTEROPT}) {%vDebt} c l1_debt l1_z_psnw interaction_level l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)

table tbl_s6(8,4)
tbl_s6(1,1)="Variable"
tbl_s6(1,2)="Coef."
tbl_s6(1,3)="Clustered SE"
tbl_s6(1,4)="p-value"

for !i = 2 to 8
  !b  = eq_nocan.@coefs(!i)
  !se = @sqrt(eq_nocan.@coefcov(!i,!i))
  !t  = !b/!se
  !p  = 2*(1-@ctdist(@abs(!t),!df_drop))

  if !i=2 then tbl_s6(!i,1)="L1 Debt"
  if !i=3 then tbl_s6(!i,1)="L1 z(PSNW)"
  if !i=4 then tbl_s6(!i,1)="z(Brent oil price) x L1 z(PSNW)"
  if !i=5 then tbl_s6(!i,1)="L1 z(CPI)"
  if !i=6 then tbl_s6(!i,1)="L1 z(Policy rate)"
  if !i=7 then tbl_s6(!i,1)="L1 z(Output gap)"
  if !i=8 then tbl_s6(!i,1)="L1 z(Primary balance)"

  tbl_s6(!i,2)=@str(!b,"f.3")
  tbl_s6(!i,3)=@str(!se,"f.3")
  if !p<0.001 then
    tbl_s6(!i,4)="<0.001"
  else
    tbl_s6(!i,4)=@str(!p,"f.3")
  endif
next

'----------------------------
' 15. SUPPLEMENTARY: LOCAL PROJECTIONS WITH UNEXPECTED OIL (TABLE S7)
'----------------------------
table tbl_s7(5,7)
tbl_s7(1,1) = "Horizon"
tbl_s7(1,2) = "Coef. on unexpected interaction"
tbl_s7(1,3) = "Clustered SE"
tbl_s7(1,4) = "t-cluster"
tbl_s7(1,5) = "p-value"
tbl_s7(1,6) = "N"
tbl_s7(1,7) = "R2"

for !h = 0 to 3
  if !h=0 then
    %dep = "{%vDebt}"
  else
    %dep = "{%vDebt}(+"+@str(!h)+")"
  endif

  smpl if {%vYear}>=2001 and {%vYear}<=(2020-!h)
  %eqname = "eq_lp_u_"+@str(!h)
  equation {%eqname}.ls({%CLUSTEROPT}) {%dep} c l1_debt l1_z_psnw interaction_unexpected l1_z_cpi l1_z_policyrate l1_z_outputgap l1_z_primarybalance @expand({%vCountry},@dropfirst) @expand({%vYear},@dropfirst)

  !b_lp  = {%eqname}.@coefs(4)
  !se_lp = @sqrt({%eqname}.@coefcov(4,4))
  !t_lp  = !b_lp/!se_lp
  !p_lp  = 2*(1-@ctdist(@abs(!t_lp),!df_full))

  !row = !h+2
  tbl_s7(!row,1) = @str(!h)
  tbl_s7(!row,2) = @str(!b_lp,"f.3")
  tbl_s7(!row,3) = @str(!se_lp,"f.3")
  tbl_s7(!row,4) = @str(!t_lp,"f.3")
  if !p_lp<0.001 then
    tbl_s7(!row,5) = "<0.001"
  else
    tbl_s7(!row,5) = @str(!p_lp,"f.3")
  endif
  tbl_s7(!row,6) = @str({%eqname}.@regobs)
  tbl_s7(!row,7) = @str({%eqname}.@r2,"f.3")
next

'----------------------------
' 16. OPTIONAL: DESCRIPTIVE FIGURE DATA
'----------------------------
' The paper's descriptive figures (Debt trajectories, PSNW trajectories, and
' the balance-sheet-composition chart) can be reproduced directly from the raw
' data once the final publication layout is chosen.
'
' Useful series already available in the active page:
'   {%vCountry}, {%vYear}, {%vDebt}, {%vPSNW}
'
' Additional series created by this program:
'   relsens_it                -> Figure 2 data (country-year values)
'   interaction_level         -> main interaction
'   interaction_unexpected    -> stricter oil interaction
'
' If desired, export the active page or selected series from EViews after the
' program finishes, and use the exported file for publication-quality figures.

'----------------------------
' 17. DISPLAY KEY OUTPUTS
'----------------------------
show tbl_desc
show tbl_head
show fig1
show tbl_lp
show tbl_ctry
show tbl_s1
show tbl_s2
show tbl_s3
show tbl_s4
show tbl_s5
show tbl_s6
show tbl_s7

' End of program
'===============================================================================
