
texdoc init YO, replace logdir(log) gropts(optargs(width=0.8\textwidth))
set linesize 100


/***

\documentclass[11pt]{article}
\usepackage{fullpage}
\usepackage{siunitx}
\usepackage{hyperref,graphicx,booktabs,dcolumn}
\usepackage{stata}
\usepackage[x11names]{xcolor}
\bibliographystyle{unsrt}
\usepackage{natbib}
\usepackage{pdflscape}
\usepackage{chngcntr}
\counterwithin{figure}{section}
\counterwithin{table}{section}
\usepackage[section]{placeins}

\usepackage{multirow}
\usepackage{booktabs}
\renewcommand{\bibsection}{}

\newcommand{\specialcell}[2][c]{%
  \begin{tabular}[#1]{@{}c@{}}#2\end{tabular}}
\newcommand{\thedate}{\today}

\usepackage{pgfplotstable}

\begin{document}


\begin{titlepage}
    \begin{flushright}
        \Huge
        \textbf{Trends in incidence of young-onset diabetes by diabetes type: 
a multi-national population-based study}
\color{black}
\rule{16cm}{2mm} \\
\vspace{0.3cm}
\textbf{Protocol} \\
\vspace{0.3cm}
\Large
\color{black}
\thedate \\
\color{blue}
https://github.com/jimb0w/YO \\
\color{black}
       \vfill
    \end{flushright}
        \Large

\noindent
Correspondence to: \\
Jedidiah Morton \\
\color{blue}
\href{mailto:Jedidiah.Morton@Monash.edu}{Jedidiah.Morton@monash.edu} \\ 
\color{black}
Research Fellow \\
\color{blue}
\color{black}
Monash University, Melbourne, Australia \\\
Baker Heart and Diabetes Institute, Melbourne, Australia \\
\end{titlepage}

\pagebreak
\tableofcontents


\pagebreak
\section{Preface}

This is the protocol for the paper ``Trends in incidence of young-onset diabetes by diabetes type: a multi-national population-based study'' (cite).
The methods used in this analyses are drawn heavily/almost entirely from Bendix Carstensen 
(see \cite{MaglianoLDE2021,CarstensenSTATMED2007}).
To generate this document, the Stata package texdoc \cite{Jann2016Stata} was used, which is 
available from: \color{blue} \url{http://repec.sowi.unibe.ch/stata/texdoc/} \color{black} (accessed 14 November 2022). The 
final Stata do file and this pdf are available at: \color{blue} \url{https://github.com/jimb0w/YO} \color{black}.
The ordinal colour schemes used are \emph{inferno} and \emph{viridis} from the
\emph{viridis} package \cite{GarnierR2021}.

\pagebreak
\section{Crude rates}

We start by examining crude incidence rates for each country.
We will generate a table showing the overall counts for each country, then plots of the crude incidence
of each type of diabetes by sex and year. 
Also, because the diabetes type definitions require two years of non-insulin use to
be effective, we will drop all data from 2021 or later. 

\color{Blue4}
***/


texdoc stlog, cmdlog nodo
cd "/Users/jed/Documents/YO"
set seed 1312
import delimited "Consortium young-onset diabetes database v9.csv", varnames(1) clear
replace inc_uncertaint = runiformint(1,2) if country == "Denmark" & inc_uncertaint==.
replace inc_t2d = runiformint(1,4) if country == "Scotland" & inc_t2d==.
replace inc_uncertaint = runiformint(1,3) if country == "Finland" & inc_uncertaint==.
replace inc_uncertaint = runiformint(1,9) if country == "Hungary" & inc_uncertaint==.
count if inc_t1d==.
count if inc_t2d==.
count if inc_uncertaint==.
save dbasev9, replace
use dbasev9, clear
drop if cal >= 2021
bysort country (cal sex age) : egen lb = min(cal)
bysort country (cal sex age) : egen ub = max(cal)
tostring lb ub, replace
gen rang = lb+ "-" + ub
collapse (sum) inc_t1d inc_t2d inc_uncertaint pys_nondm, by(country sex rang)
tostring inc_t1d-inc_u, replace format(%15.0fc) force
tostring pys, force replace format(%15.0fc)
bysort country (sex) : replace rang = "" if _n == 2
bysort country (sex) : replace country = "" if _n == 2
order country rang
replace sex = "Female" if sex == "F"
replace sex = "Male" if sex == "M"
export delimited using T1.csv, delimiter(":") novarnames replace
texdoc stlog close

/***
\color{black}

\begin{table}[h!]
  \begin{center}
    \caption{Incident diabetes cases and person-years of follow-up in people without diabetes for people aged 15-39, by country and sex.}
    \label{T1}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{2}{*}{##1}}}},
	  display columns/1/.style={column name=Period,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{2}{*}{##1}}}},
      display columns/2/.style={column name=Sex, column type={l}, text indicator="},
      display columns/3/.style={column name=Typical type 1 diabetes, column type={r}},
      display columns/4/.style={column name=Typical type 2 diabetes, column type={r}},
      display columns/5/.style={column name=Uncertain diabetes type, column type={r}},
      display columns/6/.style={column name=\specialcell{Person-years in people \\ without diabetes}, column type={r}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={2}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{T1.csv}
  \end{center}
\end{table}

\color{Blue4}
***/

texdoc stlog, cmdlog
use dbasev9, clear
drop if cal >= 2021
collapse (sum) inc_t1d inc_t2d inc_uncertaint pys_nondm, by(country calendar_yr)
gen inc1 = 100000*inc_t1d/pys_nondm
gen se1 = sqrt((1-(inc_t1d/pys_nondm))/inc_t1d)
gen lb1 = 100000*exp(ln(inc_t1d/pys_nondm)-1.96*se1)
gen ub1 = 100000*exp(ln(inc_t1d/pys_nondm)+1.96*se1)
gen inc2 = 100000*inc_t2d/pys_nondm
gen se2 = sqrt((1-(inc_t2d/pys_nondm))/inc_t2d)
gen lb2 = 100000*exp(ln(inc_t2d/pys_nondm)-1.96*se2)
gen ub2 = 100000*exp(ln(inc_t2d/pys_nondm)+1.96*se2)
gen inc3 = 100000*inc_unc/pys_nondm
gen se3 = sqrt((1-(inc_unc/pys_nondm))/inc_unc)
gen lb3 = 100000*exp(ln(inc_unc/pys_nondm)-1.96*se3)
gen ub3 = 100000*exp(ln(inc_unc/pys_nondm)+1.96*se3)
foreach i in 1 3 4 5 6 7 8 2 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
local co = "`c'"
if `i' == 2 {
local c = "Catalonia, Spain"
local co = "Spain (Catalonia)"
}
twoway ///
(line inc1 calendar if country == "`c'", color(dknavy)) ///
(line inc2 calendar if country == "`c'", color(cranberry)) ///
(line inc3 calendar if country == "`c'", color(magenta)) ///
(rarea ub1 lb1 calendar if country == "`c'", color(dknavy%30) fintensity(inten80) lwidth(none)) ///
(rarea ub2 lb2 calendar if country == "`c'", color(cranberry%30) fintensity(inten80) lwidth(none)) ///
(rarea ub3 lb3 calendar if country == "`c'", color(magenta%30) fintensity(inten80) lwidth(none)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "Typical type 1 diabetes" ///
2 "Typical type 2 diabetes" ///
3 "Uncertain type") ///
rows(3)) ///
graphregion(color(white)) ///
xlabel(2000(5)2020) ///
ylabel(0.5 "0.5" 1 2 5 10 20 50 100 500, angle(0) format(%9.0f)) ///
yscale(log range(0.5 500)) ///
ytitle("Incidence rate (per 100,000 person-years)") ///
xtitle("Calendar year") ///
title("`co'", placement(west) color(gs0) size(medium))
texdoc graph, label(`c'crude) figure(h!) caption(Crude incidence rates of diabetes in `co' among people aged 15-39 years, by diabetes type. Shaded areas represent 95\% confidence intervals.)
}
use dbasev9, clear
drop if cal >= 2021
collapse (sum) inc_t1d inc_t2d inc_uncertaint pys_nondm, by(country sex calendar_yr)
gen inc1 = 100000*inc_t1d/pys_nondm
gen se1 = sqrt((1-(inc_t1d/pys_nondm))/inc_t1d)
gen lb1 = 100000*exp(ln(inc_t1d/pys_nondm)-1.96*se1)
gen ub1 = 100000*exp(ln(inc_t1d/pys_nondm)+1.96*se1)
gen inc2 = 100000*inc_t2d/pys_nondm
gen se2 = sqrt((1-(inc_t2d/pys_nondm))/inc_t2d)
gen lb2 = 100000*exp(ln(inc_t2d/pys_nondm)-1.96*se2)
gen ub2 = 100000*exp(ln(inc_t2d/pys_nondm)+1.96*se2)
gen inc3 = 100000*inc_unc/pys_nondm
gen se3 = sqrt((1-(inc_unc/pys_nondm))/inc_unc)
gen lb3 = 100000*exp(ln(inc_unc/pys_nondm)-1.96*se3)
gen ub3 = 100000*exp(ln(inc_unc/pys_nondm)+1.96*se3)
foreach i in 1 3 4 5 6 7 8 2 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
local co = "`c'"
if `i' == 2 {
local c = "Catalonia, Spain"
local co = "Spain (Catalonia)"
}
twoway ///
(line inc1 calendar if country == "`c'" & sex == "F", color(dknavy)) ///
(line inc1 calendar if country == "`c'" & sex == "M", color(dknavy) lpattern(shortdash)) ///
(line inc2 calendar if country == "`c'" & sex == "F", color(cranberry)) ///
(line inc2 calendar if country == "`c'" & sex == "M", color(cranberry) lpattern(shortdash)) ///
(line inc3 calendar if country == "`c'" & sex == "F", color(magenta)) ///
(line inc3 calendar if country == "`c'" & sex == "M", color(magenta) lpattern(shortdash)) ///
(rarea ub1 lb1 calendar if country == "`c'" & sex == "F", color(dknavy%30) fintensity(inten80) lwidth(none)) ///
(rarea ub2 lb2 calendar if country == "`c'" & sex == "F", color(cranberry%30) fintensity(inten80) lwidth(none)) ///
(rarea ub3 lb3 calendar if country == "`c'" & sex == "F", color(magenta%30) fintensity(inten80) lwidth(none)) ///
(rarea ub1 lb1 calendar if country == "`c'" & sex == "M", color(dknavy%30) fintensity(inten80) lwidth(none)) ///
(rarea ub2 lb2 calendar if country == "`c'" & sex == "M", color(cranberry%30) fintensity(inten80) lwidth(none)) ///
(rarea ub3 lb3 calendar if country == "`c'" & sex == "M", color(magenta%30) fintensity(inten80) lwidth(none)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "Typical type 1 diabetes" ///
3 "Typical type 2 diabetes" ///
5 "Uncertain type") ///
rows(3)) ///
graphregion(color(white)) ///
xlabel(2000(5)2020) ///
ylabel(0.05 "0.05" 0.1 "0.1" 0.2 "0.2" 0.5 "0.5" 1 2 5 10 20 50 100 200 500, angle(0)) ///
yscale(log range(0.05 500)) ///
ytitle("Incidence rate (per 100,000 person-years)") ///
xtitle("Calendar year") ///
title("`co'", placement(west) color(gs0) size(medium))
texdoc graph, label(`c'crude) figure(h!) caption(Crude incidence rates of diabetes in `co' among people aged 15-39 years, by diabetes type and sex. Females = solid connecting lines; males = dashed connecting lines. Shaded areas represent 95\% confidence intervals.)
}
texdoc stlog close


/***
\color{black}
\clearpage
\section{Age and sex-specific rates}
\label{asrsec}

For the analyses, we are going to use Carstensen's Age-Period-Cohort model \cite{CarstensenSTATMED2007}
to estimate the age and sex-specific incidence rates of type 2 diabetes for each country. For this, 
we take the incidence and person-years in 5-year age groups, and fit a Poisson model with spline effects
of age, period (calendar time; measured from 2010 (i.e., 2010 is set to 0)), and cohort (calendar time minus age). 
This is done separately for each country and sex. 

Knot number was determined iteratively and selected based on best fit 
(and knot placement is based on evenly spaced quantiles of the data as recommended by Harrell \cite{Harrell2001Springer}). 
Best fit was determined based upon visual inspection of the relationship 
between modeled and crude rates, as well as inspection of the Pearson residuals by age, period, and cohort. 
Moreover, because of the different years covered by each dataset,
the knot locations are different for each country .

Then, we use this model to predict the incidence rates of diabetes by age and calendar time. 
These results are presented in figures showing the 
incidence rates of type 2 diabetes for each country.

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
forval i = 1/8 {
foreach ii in M F {
foreach iii in inc_t1d inc_t2d inc_uncertaint {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Catalonia, Spain"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
use dbasev9, clear
drop if cal >= 2021
if "`iii'" == "inc_t1d" {
drop if age_gp == "35-39"
}
keep if country == "`c'" & sex == "`ii'"
rename age_gp age
replace age = substr(age,1,2)
destring age, replace
replace age = age+2.5
replace calendar = calendar-2009.5
gen coh = calendar-age
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
local CK5 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `iii' agesp* timesp* cohsp*, exposure(pys)
predict pred
save APC_pred_`i'_`ii'_`iii', replace
keep age calendar pys
expand 50
replace pys=pys/50
bysort cal age : replace age = round(age+((_n/10)-2.6),0.1)
sort age cal
expand 10
sort age cal
bysort age cal : replace cal = cal+(_n/10)-0.1
replace pys = pys/10
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 7.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
predict errr, stdp
replace _Rate = _Rate*100000
gen lb = exp(ln(_Rate)-1.96*errr)
gen ub = exp(ln(_Rate)+1.96*errr)
gen country = "`c'"
gen sex = "`ii'"
gen OC = "`iii'"
replace cal = cal+2009.5
tostring age, replace force format(%9.1f)
destring age, replace
save APC_Rate_`i'_`ii'_`iii', replace
}
}
}
foreach i in 1 3 4 5 6 7 8 2 {
foreach ii in M F {
foreach iii in inc_t1d inc_t2d inc_uncertaint {
if `i' == 1 {
local c = "Australia"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
local co = "`c'"
if `i' == 2 {
local c = "Catalonia, Spain"
local co = "Spain (Catalonia)"
}
if "`ii'" == "M" {
local s = "Males"
use viridis, clear
local col1 = var6[6]
local col2 = var6[5]
local col3 = var6[4]
local col4 = var6[3]
local col5 = var6[2]
}
else {
local s = "Females"
use inferno, clear
local col1 = var6[6]
local col2 = var6[5]
local col3 = var6[4]
local col4 = var6[3]
local col5 = var6[2]
}
if "`iii'" == "inc_t1d" {
local oc = "Typical type 1 diabetes"
}
else if "`iii'" == "inc_t2d" {
local oc = "Typical type 2 diabetes"
}
else {
local oc = "Uncertain diabetes type"
}
use APC_pred_`i'_`ii'_`iii', clear
gen res = (`iii'-pred)/sqrt(pred)
twoway ///
(scatter res age, col(black)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(, format(%9.0f) grid angle(0)) ///
ytitle("Pearson residuals", margin(a+2)) ///
xtitle("Age (years)") ///
title("`co' - `oc' - `s'", placement(west) color(black) size(medium))
graph save CRJ_1_`i'_`ii'_`iii', replace
twoway ///
(scatter res cal, col(black)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(, format(%9.0f) grid angle(0)) ///
ytitle("Pearson residuals", margin(a+2)) ///
xtitle("Calendar time (years)") ///
title("`co' - `oc' - `s'", placement(west) color(black) size(medium))
graph save CRJ_2_`i'_`ii'_`iii', replace
twoway ///
(scatter res coh, col(black)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(, format(%9.0f) grid angle(0)) ///
ytitle("Pearson residuals", margin(a+2)) ///
xtitle("Cohort (years)") ///
title("`co' - `oc' - `s'", placement(west) color(black) size(medium))
graph save CRJ_3_`i'_`ii'_`iii', replace
use APC_Rate_`i'_`ii'_`iii', clear
twoway ///
(rarea ub lb calendar if age == 15, color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 15, color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if age == 20, color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 20, color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if age == 25, color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 25, color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if age == 30, color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 30, color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if age == 35, color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 35, color("`col5'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(10 "35" ///
8 "30" ///
6 "25" ///
4 "20" ///
2 "15") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.2 "0.2" ///
0.5 "0.5" ///
1 2 5 10 20 50 100 200 500, grid angle(0)) ///
yscale(range(0.1 505) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence rate (per 100,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`co' - `oc' - `s'", placement(west) color(black) size(medium))
graph save "Graph" Escape_`i'_`ii'_`iii', replace
egen calmin = min(calendar)
egen calmen = mean(calendar)
replace calmen = round(calmen,1)
egen calmax = max(calendar)
replace calmax = calmax-0.9
local cmn = calmin[1]
local cmu = calmen[1]
local cmx = calmax[1]
if "`iii'" == "inc_t1d" {
local ylab = "0(20)120"
local yft = "%9.0f"
}
if "`iii'" == "inc_t2d" {
local ylab = "0(100)1000"
local yft = "%9.0f"
}
if "`iii'" == "inc_uncertaint" {
local ylab = "0(40)280"
local yft = "%9.0f"
}
twoway ///
(rarea ub lb age if calendar == calmin, color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if calendar == calmin, color("`col1'") lpattern(solid)) ///
(rarea ub lb age if calendar == calmen, color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if calendar == calmen, color("`col3'") lpattern(solid)) ///
(rarea ub lb age if calendar == calmax, color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate age if calendar == calmax, color("`col5'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`cmn'" ///
4 "`cmu'" ///
6 "`cmx'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(`ylab', format(`yft') grid angle(0)) ///
xscale(range(15 40)) ///
xlabel(15(5)40, nogrid) ///
ytitle("Incidence rate (per 100,000 person-years)", margin(a+2)) ///
xtitle("Age (years)") ///
title("`co' - `oc' - `s'", placement(west) color(black) size(medium))
graph save "Graph" TTFATF_`i'_`ii'_`iii', replace
}
}
}
texdoc stlog close
texdoc stlog, cmdlog
foreach i in 1 3 4 5 6 7 8 2 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
local co = "`c'"
if `i' == 2 {
local c = "Catalonia, Spain"
local co = "Spain (Catalonia)"
}
graph combine ///
CRJ_1_`i'_F_inc_t1d.gph ///
CRJ_2_`i'_F_inc_t1d.gph ///
CRJ_3_`i'_F_inc_t1d.gph ///
CRJ_1_`i'_M_inc_t1d.gph ///
CRJ_2_`i'_M_inc_t1d.gph ///
CRJ_3_`i'_M_inc_t1d.gph ///
CRJ_1_`i'_F_inc_t2d.gph ///
CRJ_2_`i'_F_inc_t2d.gph ///
CRJ_3_`i'_F_inc_t2d.gph ///
CRJ_1_`i'_M_inc_t2d.gph ///
CRJ_2_`i'_M_inc_t2d.gph ///
CRJ_3_`i'_M_inc_t2d.gph ///
CRJ_1_`i'_F_inc_uncertaint.gph ///
CRJ_2_`i'_F_inc_uncertaint.gph ///
CRJ_3_`i'_F_inc_uncertaint.gph ///
CRJ_1_`i'_M_inc_uncertaint.gph ///
CRJ_2_`i'_M_inc_uncertaint.gph ///
CRJ_3_`i'_M_inc_uncertaint.gph ///
, altshrink cols(3) xsize(3.5) graphregion(color(white))
texdoc graph, label(`c' agespec) figure(h!) caption(Pearson residuals for the age-period-cohort model in `co', by diabetes type and sex)
graph combine ///
Escape_`i'_F_inc_t1d.gph ///
Escape_`i'_M_inc_t1d.gph ///
Escape_`i'_F_inc_t2d.gph ///
Escape_`i'_M_inc_t2d.gph ///
Escape_`i'_F_inc_uncertaint.gph ///
Escape_`i'_M_inc_uncertaint.gph ///
, altshrink rows(3) xsize(3.5) graphregion(color(white))
texdoc graph, label(`c' agespec) figure(h!) caption(Incidence rates of diabetes in `co' for people aged 15, 20, 25, 30, and 35 years, by diabetes type and sex. Shaded areas represent 95\% confidence intervals.)
graph combine ///
TTFATF_`i'_F_inc_t1d.gph ///
TTFATF_`i'_M_inc_t1d.gph ///
TTFATF_`i'_F_inc_t2d.gph ///
TTFATF_`i'_M_inc_t2d.gph ///
TTFATF_`i'_F_inc_uncertaint.gph ///
TTFATF_`i'_M_inc_uncertaint.gph ///
, altshrink rows(3) xsize(3.5) graphregion(color(white))
texdoc graph, label(`c' agespec) figure(h!) caption(Incidence rates of diabetes in `co' by age for the first, middle, and last calendar year of follow-up, by diabetes type and sex. Shaded areas represent 95\% confidence intervals.)
}
texdoc stlog close

/***
\color{black}

To make comparison between countries easier, we will plot all curves for age 25 on the same graph 
(and 20 and 30, to see if there is any difference depending on the age selected; figures ~\ref{agespec20} - ~\ref{agespec30}).

For these plots, we no longer use an ordinal colour scheme. We're using rainbow.

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
forval age = 20(5)30 {
foreach ii in M F {
foreach iii in inc_t1d inc_t2d inc_uncertaint {
if "`ii'" == "M" {
local s = "Males"
}
else {
local s = "Females"
}
if "`iii'" == "inc_t1d" {
local oc = "Typical type 1 diabetes"
}
else if "`iii'" == "inc_t2d" {
local oc = "Typical type 2 diabetes"
}
else {
local oc = "Uncertain diabetes type"
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 175 255"
local col8 = "0 0 0"
clear
forval i = 1/8 {
append using APC_Rate_`i'_`ii'_`iii'
}
replace country = "Spain (Catalonia)" if country == "Catalonia, Spain"
keep if age == `age'
preserve
bysort country : keep if _n == 1
forval i = 1/8 {
local C`i' = country[`i']
}
restore
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.2 "0.2" ///
0.5 "0.5" ///
1 2 5 10 20 50 100 200 500, grid angle(0)) ///
yscale(range(0.1 505) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence rate (per 100,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oc' - `s'", placement(west) color(black) size(medium))
graph save "Graph" Alive_`ii'_`iii'_`age', replace
}
}
}
texdoc stlog close
texdoc stlog, cmdlog
graph combine ///
Alive_F_inc_t1d_20.gph ///
Alive_M_inc_t1d_20.gph ///
Alive_F_inc_t2d_20.gph ///
Alive_M_inc_t2d_20.gph ///
Alive_F_inc_uncertaint_20.gph ///
Alive_M_inc_uncertaint_20.gph ///
, altshrink rows(3) xsize(4) graphregion(color(white))
texdoc graph, label(agespec20) figure(h!) caption(Incidence rates of diabetes for people aged 20 years, by diabetes type and sex. Shaded areas represent 95\% confidence intervals.)
graph combine ///
Alive_F_inc_t1d_25.gph ///
Alive_M_inc_t1d_25.gph ///
Alive_F_inc_t2d_25.gph ///
Alive_M_inc_t2d_25.gph ///
Alive_F_inc_uncertaint_25.gph ///
Alive_M_inc_uncertaint_25.gph ///
, altshrink rows(3) xsize(4) graphregion(color(white))
texdoc graph, label(agespec25) figure(h!) caption(Incidence rates of diabetes for people aged 25 years, by diabetes type and sex. Shaded areas represent 95\% confidence intervals.)
graph combine ///
Alive_F_inc_t1d_30.gph ///
Alive_M_inc_t1d_30.gph ///
Alive_F_inc_t2d_30.gph ///
Alive_M_inc_t2d_30.gph ///
Alive_F_inc_uncertaint_30.gph ///
Alive_M_inc_uncertaint_30.gph ///
, altshrink rows(3) xsize(4) graphregion(color(white))
texdoc graph, label(agespec30) figure(h!) caption(Incidence rates of diabetes for people aged 30 years, by diabetes type and sex. Shaded areas represent 95\% confidence intervals.)
texdoc stlog close

/***
\color{black}

\clearpage

Finally, we will formalise a comparison of the incidence rate between type 1 and type 2 diabetes. 
For this, we will fit a model with spline effects of calendar time and age, diabetes type,
and interactions between all 3. 
 
\color{Blue4}
***/

texdoc stlog, cmdlog nodo
forval i = 1/8 {
foreach ii in M F {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Catalonia, Spain"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
use dbasev9, clear
drop if cal >= 2021
drop if age_gp == "35-39"
keep if country == "`c'" & sex == "`ii'"
rename age_gp age
expand 2
bysort cal age : gen DT = _n
gen inc = inc_t1d if DT == 1
replace inc = inc_t2d if DT == 2
replace age = substr(age,1,2)
destring age, replace
replace age = age+2.5
replace calendar = calendar-2009.5
gen coh = calendar-age
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
preserve
clear
set obs 20
gen age = _n+14
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
forval a = 1/20 {
local A1`a' = agesp1[`a']
local A2`a' = agesp2[`a']
local A3`a' = agesp3[`a']
}
restore
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
preserve
clear
set obs 1
gen calendar=2017-2009.5
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
local T1=timesp1[1]
restore
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
preserve
clear
set obs 1
gen calendar=2017-2009.5
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
local T1=timesp1[1]
local T2=timesp2[1]
restore
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
preserve
clear
set obs 1
gen calendar=2017-2009.5
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
local T1=timesp1[1]
local T2=timesp2[1]
local T3=timesp3[1]
restore
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
local CK5 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
preserve
clear
set obs 1
gen calendar=2017-2009.5
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
local T1=timesp1[1]
local T2=timesp2[1]
local T3=timesp3[1]
local T4=timesp4[1]
restore
}
poisson inc i.DT##c.agesp*##c.timesp*, exposure(pys)
matrix A = (.,.,.)
if `rang' < 8 {
forval a = 1/20 {
margins, dydx(DT) at(agesp1==`A1`a'' agesp2==`A2`a'' agesp3==`A3`a'' timesp1==`T1') predict(xb)
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
else if inrange(`rang',8,11.9) {
forval a = 1/20 {
margins, dydx(DT) at(agesp1==`A1`a'' agesp2==`A2`a'' agesp3==`A3`a'' timesp1==`T1' timesp2==`T2') predict(xb)
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
else if inrange(`rang',12,15.9) {
forval a = 1/20 {
margins, dydx(DT) at(agesp1==`A1`a'' agesp2==`A2`a'' agesp3==`A3`a'' timesp1==`T1' timesp2==`T2' timesp3==`T3') predict(xb)
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
else {
forval a = 1/20 {
margins, dydx(DT) at(agesp1==`A1`a'' agesp2==`A2`a'' agesp3==`A3`a'' timesp1==`T1' timesp2==`T2' timesp3==`T3' timesp4==`T4') predict(xb)
matrix A = (A\r(table)[1,2],r(table)[5,2],r(table)[6,2])
}
}
clear
set obs 21
gen age = _n+13
svmat A
drop if age == 14
replace A1 = exp(A1)
replace A2 = exp(A2)
replace A3 = exp(A3)
gen country = "`c'"
gen sex = "`ii'"
save SMR_`i'_`ii', replace
}
}
foreach ii in M F {
if "`ii'" == "M" {
local iii = "Males"
}
if "`ii'" == "F" {
local iii = "Females"
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 0 0"
clear
forval i = 1/7 {
append using SMR_`i'_`ii'
}
replace country = "Spain (Catalonia)" if country == "Catalonia, Spain"
preserve
bysort country : keep if _n == 1
forval i = 1/7 {
local C`i' = country[`i']
}
restore
twoway ///
(rarea A3 A2 age if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea A3 A2 age if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line A1 age if country == "`C7'", color("`col7'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel( ///
0.02 "0.02" ///
0.05 "0.05" ///
0.1 "0.1" ///
0.2 "0.2" ///
0.5 "0.5" ///
1.0 "1.0" ///
2.0 "2.0" ///
5.0 "5.0" 10 "10.0" 20 "20.0", grid angle(0)) ///
yscale(range(0.02 30) log) ///
xlabel(15(5)35, nogrid) ///
ytitle("Incidence rate ratio T2D:T1D", margin(a+2)) ///
xtitle("Age (years)") yline(1, lcol(black)) ///
title("`iii'", placement(west) color(black) size(medium))
graph save "Graph" Possession_`ii', replace
}
texdoc stlog close
texdoc stlog, cmdlog
graph combine ///
Possession_F.gph ///
Possession_M.gph ///
, altshrink rows(1) xsize(10) graphregion(color(white))
texdoc graph, label(smr111) figure(h!) caption(Incidence rate ratio for typical type 2 diabetes (T2D) vs. typical type 1 diabetes (T1D), ///
by sex in 2017. South Korea is excluded due to insufficient numbers in type 1 diabetes. Shaded areas represent 95\% confidence intervals.)
graph export "/Users/jed/Documents/YO/Figure 3.pdf", as(pdf) name("Graph") replace
texdoc stlog close

/***
\color{black}

\clearpage
\section{Age-standardized rates}

Additionally, we will age-standardise the incidence rates to the European population in 2010. 
This will be done using the same Age-Period-Cohort models described above. In this analysis, we will take
the predicted rates from these models (in single years) and use these in direct standardisation. However,
to do this, we first need to convert the European standard population (available only in 5-year age groups)
to 1-year age groups (using linear regression).

\color{Blue4}
***/

texdoc stlog, cmdlog
use dbasev9, clear
drop if cal >= 2021
keep if _n<=5
keep age_gp esp2010
rename age_gp age
replace age = substr(age,1,2)
destring age, replace
expand 5
replace esp2010=esp2010/5
bysort age : replace age = age+_n-0.5
mkspline agesp = age, cubic knots(15(5)40)
reg esp2010 agesp*
predict A
preserve
replace esp2010 = esp2010/1000000
replace A = A/1000000
twoway ///
(scatter esp2010 age, col(dknavy)) ///
(line A age, col(magenta)) ///
, legend(symxsize(0.13cm) position(4) ring(0) region(lcolor(white) color(none)) ///
order(1 "Actual" ///
2 "Modelled") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(1.2(0.1)1.5, format(%9.1f) angle(0)) ///
ytitle("Population size (millions)") xtitle("Age (years)")
texdoc graph, label(ESP2010N) figure(h!) caption(European standard population in 2010)
restore
su(esp2010)
gen esp2010prop = esp2010/r(sum)
su(A)
gen B = A/r(sum)
twoway ///
(bar esp2010prop age, color(dknavy%70)) ///
(bar B age, color(magenta%50)) ///
, legend(symxsize(0.13cm) position(11) ring(0) region(lcolor(white) color(none)) ///
order(1 "Actual" ///
2 "Modelled") ///
cols(1)) /// 
ylabel(0(0.01)0.04, angle(0) format(%9.2f)) ///
graphregion(color(white)) ///
ytitle("Proportion") xtitle("Age (years)")
texdoc graph, label(ESP2010P) figure(h!) caption(European standard population proportions in 2010)
keep age B
replace age = age-0.5
save refpop, replace
use dbasev9, clear
drop if cal >= 2021
keep if _n<=5
keep age_gp esp2010
rename age_gp age
replace age = substr(age,1,2)
destring age, replace
expand 5
replace esp2010=esp2010/5
bysort age : replace age = age+_n-0.5
mkspline agesp = age, cubic knots(15(5)40)
reg esp2010 agesp*
predict A
drop if age > 35
su(esp2010)
gen esp2010prop = esp2010/r(sum)
su(A)
gen B = A/r(sum)
keep age B
replace age = age-0.5
save refpop1, replace
texdoc stlog close

/***
\color{black}

\clearpage

With that, we can calculate and plot the age-standardized rates.
Note: the method used to calculate the confidence intervals is the 
same as the Stata command \href{https://www.stata.com/manuals/rdstdize.pdf}{dstdize}, and it assumes that the person-years
are the same for each single age within the 5-year age group (which, if the 
populations we sample from are anything like the European population, is 
a safe assumption (figure~\ref{ESP2010P}, and is unlikely to affect the calculated
error even if included)).

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
quietly {
forval i = 1/8 {
foreach ii in M F {
foreach iii in inc_t1d inc_t2d inc_uncertaint {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Catalonia, Spain"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
use dbasev9, clear
drop if cal >= 2021
if "`iii'" == "inc_t1d" {
drop if age_gp == "35-39"
}
keep if country == "`c'" & sex == "`ii'"
rename age_gp age
replace age = substr(age,1,2)
destring age, replace
replace age = age+2.5
replace calendar = calendar-2009.5
gen coh = calendar-age
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
local CK5 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `iii' agesp* timesp* cohsp*, exposure(pys)
keep age calendar pys
expand 5
replace pys=pys/5
bysort cal age : replace age = age+_n-3.5
sort age cal
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 7.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
replace cal = cal+2009.5
keep cal age pys _Rate
if "`iii'" == "inc_t1d" {
merge m:1 age using refpop1
}
else {
merge m:1 age using refpop
}
drop _merge
gen double expdeath = _Rate*B
bysort cal : egen double expdeath1 = sum(expdeath)
gen stdrate = 100000*expdeath1
gen SEC1 = ((B^2)*(_Rate*(1-_Rate)))/pys_nondm
bysort cal : egen double SEC2 = sum(SEC1)
gen double SE = sqrt(SEC2)
gen lb = 100000*(expdeath1-1.96*SE)
gen ub = 100000*(expdeath1+1.96*SE)
bysort cal (age) : keep if _n == 1
noisily count if lb < 0
keep cal stdrate lb ub
gen country = "`c'"
gen sex = "`ii'"
gen OC = "`iii'"
save STD_Rate_`i'_`ii'_`iii', replace
}
}
}
}
foreach ii in M F {
foreach iii in inc_t1d {
if "`ii'" == "M" {
local s = "Males"
}
else {
local s = "Females"
}
if "`iii'" == "inc_t1d" {
local oc = "Typical type 1 diabetes"
}
else if "`iii'" == "inc_t2d" {
local oc = "Typical type 2 diabetes"
}
else {
local oc = "Uncertain diabetes type"
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 0 0"
clear
forval i = 1/7 {
append using STD_Rate_`i'_`ii'_`iii'
}
replace country = "Spain (Catalonia)" if country == "Catalonia, Spain"
preserve
bysort country : keep if _n == 1
forval i = 1/7 {
local C`i' = country[`i']
}
restore
if "`ii'" == "F" & "`iii'" == "inc_t2d" {
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(4) ring(0) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'") ///
cols(2)) ///
graphregion(color(white)) ///
ylabel(5 10 20 50 100 200 500, grid angle(0)) ///
yscale(range(5 500) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence rate (per 100,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oc' - `s'", placement(west) color(black) size(medium))
}
else {
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(5 10 20 50 100 200 500, grid angle(0)) ///
yscale(range(5 500) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence rate (per 100,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oc' - `s'", placement(west) color(black) size(medium))
}
graph save "Graph" Alive_`ii'_`iii'_STD, replace
}
}
foreach ii in M F {
foreach iii in inc_t2d inc_uncertaint {
if "`ii'" == "M" {
local s = "Males"
}
else {
local s = "Females"
}
if "`iii'" == "inc_t1d" {
local oc = "Typical type 1 diabetes"
}
else if "`iii'" == "inc_t2d" {
local oc = "Typical type 2 diabetes"
}
else {
local oc = "Uncertain diabetes type"
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 175 255"
local col8 = "0 0 0"
clear
forval i = 1/8 {
append using STD_Rate_`i'_`ii'_`iii'
}
replace country = "Spain (Catalonia)" if country == "Catalonia, Spain"
preserve
bysort country : keep if _n == 1
forval i = 1/8 {
local C`i' = country[`i']
}
restore
if "`ii'" == "F" & "`iii'" == "inc_t2d" {
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(4) ring(0) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'") ///
cols(2)) ///
graphregion(color(white)) ///
ylabel(5 10 20 50 100 200 500, grid angle(0)) ///
yscale(range(5 500) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence rate (per 100,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oc' - `s'", placement(west) color(black) size(medium))
}
else {
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(5 10 20 50 100 200 500, grid angle(0)) ///
yscale(range(5 500) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence rate (per 100,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oc' - `s'", placement(west) color(black) size(medium))
}
graph save "Graph" Alive_`ii'_`iii'_STD, replace
}
}
texdoc stlog close
texdoc stlog, cmdlog
graph combine ///
Alive_F_inc_t1d_STD.gph ///
Alive_M_inc_t1d_STD.gph ///
Alive_F_inc_t2d_STD.gph ///
Alive_M_inc_t2d_STD.gph ///
Alive_F_inc_uncertaint_STD.gph ///
Alive_M_inc_uncertaint_STD.gph ///
, altshrink rows(3) xsize(3.3) graphregion(color(white))
texdoc graph, label(STDfig) figure(h!) caption(Age-standardized incidence rates of diabetes for people aged 15-39 years, by diabetes type and sex. ///
South Korea is excluded from type 1 diabetes due to insufficent numbers. Shaded areas represent 95\% confidence intervals.)
graph export "/Users/jed/Documents/YO/Figure 1.pdf", as(pdf) name("Graph") replace
texdoc stlog close

/***
\color{black}

\clearpage
\section{Average Annual Percent Changes}

As a summary metric, we will also estimate the average annual change
in incidence - overall, and by sex. For this, we use a different model with a spline effect
of age, but only a (log-)linear effect of calendar time. This means we are assuming the effect of time
is constant throughout follow-up, which we already know is false for a few countries (e.g., Australia;
figure~\ref{agespec25}). \\

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
forval i = 1/8 {
forval ii = 0/2 {
forval iii = 1/4 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Catalonia, Spain"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
use dbasev9, clear
drop if cal >= 2021
if `iii' == 1 {
drop if age_gp == "35-39"
}
keep if country == "`c'" 
if `ii' == 1 {
keep if sex == "M"
}
if `ii' == 2 {
keep if sex == "F"
}
rename age_gp age
replace age = substr(age,1,2)
destring age, replace
replace age = age+2.5
su(calendar), detail
local lb = r(min)
local ub = r(max)
replace calendar = calendar-2009.5
gen coh = calendar-age
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `iii' == 1 {
poisson inc_t1d calendar agesp*, exposure(pys)
}
if `iii' == 2 {
poisson inc_t2d calendar agesp*, exposure(pys)
}
if `iii' == 3 {
poisson inc_uncertaint calendar agesp*, exposure(pys)
}
if `iii' == 4 {
gen totinc = inc_t1d+inc_t2d+inc_uncertaint
poisson totinc calendar agesp*, exposure(pys)
}
matrix A_`i'_`ii'_`iii' = (`lb',`ub',`i',`ii',`iii',r(table)[1,1], r(table)[5,1], r(table)[6,1])
}
}
matrix A_`i' = (A_`i'_0_1,A_`i'_0_2,A_`i'_0_3,A_`i'_0_4\ ///
A_`i'_1_1,A_`i'_1_2,A_`i'_1_3,A_`i'_1_4\ ///
A_`i'_2_1,A_`i'_2_2,A_`i'_2_3,A_`i'_2_4)
}
matrix A = (A_1\A_2\A_3\A_4\A_5\A_6\A_7\A_8)
clear
svmat A
gen country=""
bysort A3 (A2) : replace country = "Australia" if A3 == 1 & _n == 1
bysort A3 (A2) : replace country = "Spain (Catalonia)" if A3 == 2 & _n == 1
bysort A3 (A2) : replace country = "Denmark" if A3 == 3 & _n == 1
bysort A3 (A2) : replace country = "Finland" if A3 == 4 & _n == 1
bysort A3 (A2) : replace country = "Hungary" if A3 == 5 & _n == 1
bysort A3 (A2) : replace country = "Japan" if A3 == 6 & _n == 1
bysort A3 (A2) : replace country = "Scotland" if A3 == 7 & _n == 1
bysort A3 (A2) : replace country = "South Korea" if A3 == 8 & _n == 1
tostring A1 A2, replace format(%9.0f)
bysort A3 (A2) : gen time = A1+"-"+A2 if _n == 1
gen sex = "Overall" if A4 == 0
replace sex = "Males" if A4 == 1
replace sex = "Females" if A4 == 2
drop A9-A13 A17-A21 A25-A29
foreach var of varlist A6-A32 {
replace `var' = 100*(exp(`var')-1)
}
tostring A6-A32, replace force format(%9.1f)
gen T1 = "$" + A6 + "$ ($" + A7 + "$, $" + A8 + "$)"
gen T2 = "$" + A14 + "$ ($" + A15 + "$, $" + A16 + "$)"
gen T3 = "$" + A22 + "$ ($" + A23 + "$, $" + A24 + "$)"
gen T4 = "$" + A30 + "$ ($" + A31 + "$, $" + A32 + "$)"
gen njm = _n
gen nj =0
replace nj = 1 if _n == 4 | _n == 5 | _n == 6
sort nj njm
keep country time sex T1 T2 T3 T4
export delimited using APCs.csv, delimiter(":") novarnames replace
texdoc stlog close

/***
\color{black}

\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in the incidence rates of diabetes, by country, sex, and diabetes type. Adjusted for age. Numbers in brackets represent 95\% confidence intervals.}
    \label{APCs}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
	  display columns/1/.style={column name=Period,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/2/.style={column name=Sex, column type={l}, text indicator="},
      display columns/3/.style={column name=Typical type 1 diabetes, column type={r}, column type/.add={|}{}},
      display columns/4/.style={column name=Typical type 2 diabetes, column type={r}, column type/.add={|}{}},
      display columns/5/.style={column name=Uncertain diabetes type, column type={r}, column type/.add={|}{|}},
      display columns/6/.style={column name=Total diabetes, column type={r}, column type/.add={}{|}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{APCs.csv}
  \end{center}
\end{table}

It's also worth looking at variation in the incidence rates by age, as some of the figures in section~\ref{asrsec}
suggested a greater increase in type 2 diabetes at younger ages. For this, we will use two models: 
the first includes the interaction between a spline effect of age and a log-linear effect of calendar time (plotted in the left
panels of the combined figures),
whereas the second includes a spline effect of age and the product of log-linear effects of age and calendar time (plotted on the right in the figures). 

\color{Blue4}
***/

texdoc stlog, cmdlog nodo
quietly {
forval i = 1/8 {
foreach ii in M F {
foreach iii in inc_t1d inc_t2d inc_uncertaint {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Catalonia, Spain"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
use dbasev9, clear
drop if cal >= 2021
if "`iii'" == "inc_t1d" {
drop if age_gp == "35-39"
}
keep if country == "`c'" & sex == "`ii'"
rename age_gp age
replace age = substr(age,1,2)
destring age, replace
replace age = age+2.5
replace calendar = calendar-2009.5
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
preserve
clear
set obs 251
gen age = (_n/10)+14.9
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
forval a = 1/251 {
local A1`a' = agesp1[`a']
local A2`a' = agesp2[`a']
local A3`a' = agesp3[`a']
}
restore
poisson `iii' c.agesp*##c.cal , exposure(pys)
matrix A = (.,.,.,.)
forval a = 1/251 {
margins, dydx(cal) at(agesp1==`A1`a'' agesp2==`A2`a'' agesp3==`A3`a'') atmeans predict(xb)
matrix A = (A\(`a'/10)+14.9,r(table)[1,1],r(table)[5,1],r(table)[6,1])
}
preserve
clear 
svmat A
drop if A1==.
replace A2 = 100*(exp(A2)-1)
replace A3 = 100*(exp(A3)-1)
replace A4 = 100*(exp(A4)-1)
rename A1 age
rename A2 apc
rename A3 lb
rename A4 ub
gen country = "`c'"
gen sex = "`ii'"
gen OC = "`iii'"
save APC_age_`i'_`ii'_`iii'_1, replace
restore
poisson `iii' c.agesp* c.age##c.cal , exposure(pys)
matrix A = (.,.,.,.)
forval a = 1/251 {
margins, dydx(cal) at(age==`A1`a'' agesp1==`A1`a'' agesp2==`A2`a'' agesp3==`A3`a'') atmeans predict(xb)
matrix A = (A\(`a'/10)+14.9,r(table)[1,1],r(table)[5,1],r(table)[6,1])
}
clear 
svmat A
drop if A1==.
replace A2 = 100*(exp(A2)-1)
replace A3 = 100*(exp(A3)-1)
replace A4 = 100*(exp(A4)-1)
rename A1 age
rename A2 apc
rename A3 lb
rename A4 ub
gen country = "`c'"
gen sex = "`ii'"
gen OC = "`iii'"
save APC_age_`i'_`ii'_`iii'_2, replace
}
}
}
}
texdoc stlog close
texdoc stlog, cmdlog
foreach i in 1 3 4 5 6 7 8 2 {
foreach iii in inc_t1d inc_t2d inc_uncertaint {
if `i' == 1 {
local c = "Australia"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
local co = "`c'"
if `i' == 2 {
local c = "Catalonia, Spain"
local co = "Spain (Catalonia)"
}
if "`iii'" == "inc_t1d" {
local oc = "Typical type 1 diabetes"
}
else if "`iii'" == "inc_t2d" {
local oc = "Typical type 2 diabetes"
}
else {
local oc = "Uncertain diabetes type"
}

forval a = 1/2 {
clear
append using APC_age_`i'_M_`iii'_`a'
append using APC_age_`i'_F_`iii'_`a'
if "`iii'" == "inc_t1d" {
drop if age > 35
}
twoway ///
(rarea ub lb age if sex == "M", color("blue%30") fintensity(inten80) lwidth(none)) ///
(line apc age if sex == "M", color("blue") lpattern(solid)) ///
(rarea ub lb age if sex == "F", color("red%30") fintensity(inten80) lwidth(none)) ///
(line apc age if sex == "F", color("red") lpattern(solid)) ///
,legend(ring(0) symxsize(0.13cm) position(2) region(lcolor(white) color(none)) ///
order(2 "Males" ///
4 "Females")  ///
cols(1)) ///
bgcolor(white) graphregion(color(white)) ///
ytitle("Annual change in incidence rates (%)", xoffset(-1)) ///
yline(0, lcolor(gs0)) ///
ylabel(-5(5)15, angle(0)) ///
xtitle("Attained age (years)") ///
xlabel(15(5)40) ///
title("`co' - `oc'", placement(west) size(medium) color(gs0))
graph save "Graph" Apage_`i'_`iii'_`a', replace
}
}
graph combine ///
Apage_`i'_inc_t1d_1.gph ///
Apage_`i'_inc_t1d_2.gph ///
Apage_`i'_inc_t2d_1.gph ///
Apage_`i'_inc_t2d_2.gph ///
Apage_`i'_inc_uncertaint_1.gph ///
Apage_`i'_inc_uncertaint_2.gph ///
, altshrink rows(3) xsize(3.5) graphregion(color(white))
texdoc graph, label(`c' apcageg) figure(h!) caption(Annual change in the incidence rates of diabetes in `co' by age, by diabetes type and sex. ///
Values are predicted from a Poisson model with a spline effect of attained age, a log-linear effect of calendar time, and an interaction ///
between age and calendar time. The left panels use a spline term for age in the interaction, the right panels use the product of ///
age and calendar time in the interaction. Shaded areas represent 95\% confidence intervals.)
}
texdoc stlog close




/***
\color{black}

\clearpage
\section{Sensitivity analyses}

\subsection{Re-allocating uncertain diabetes type}

In this sensitivity analysis, we will re-allocated people in the uncertain diabetes type category
to either type 1 diabetes or type 2 diabetes, and assess the impact this has on age-adjusted trends 
and changes over time. 

\color{Blue4}
***/


texdoc stlog, cmdlog nodo
quietly {
forval i = 1/8 {
foreach ii in M F {
foreach iii in inc_t1d inc_t2d {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Catalonia, Spain"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
use dbasev9, clear
replace `iii' = `iii'+inc_uncertaint
drop if cal >= 2021
if "`iii'" == "inc_t1d" {
drop if age_gp == "35-39"
}
keep if country == "`c'" & sex == "`ii'"
rename age_gp age
replace age = substr(age,1,2)
destring age, replace
replace age = age+2.5
replace calendar = calendar-2009.5
gen coh = calendar-age
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
local CK5 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `iii' agesp* timesp* cohsp*, exposure(pys)
keep age calendar pys
expand 5
replace pys=pys/5
bysort cal age : replace age = age+_n-3.5
sort age cal
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 7.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
replace cal = cal+2009.5
keep cal age pys _Rate
if "`iii'" == "inc_t1d" {
merge m:1 age using refpop1
}
else {
merge m:1 age using refpop
}
drop _merge
gen double expdeath = _Rate*B
bysort cal : egen double expdeath1 = sum(expdeath)
gen stdrate = 100000*expdeath1
gen SEC1 = ((B^2)*(_Rate*(1-_Rate)))/pys_nondm
bysort cal : egen double SEC2 = sum(SEC1)
gen double SE = sqrt(SEC2)
gen lb = 100000*(expdeath1-1.96*SE)
gen ub = 100000*(expdeath1+1.96*SE)
bysort cal (age) : keep if _n == 1
noisily count if lb < 0
keep cal stdrate lb ub
gen country = "`c'"
gen sex = "`ii'"
gen OC = "`iii'"
save STD_Rate_`i'_`ii'_`iii'_US, replace
}
}
}
}
foreach ii in M F {
foreach iii in inc_t1d inc_t2d {
if "`ii'" == "M" {
local s = "Males"
}
else {
local s = "Females"
}
if "`iii'" == "inc_t1d" {
local oc = "Typical type 1 diabetes"
}
else if "`iii'" == "inc_t2d" {
local oc = "Typical type 2 diabetes"
}
else {
local oc = "Uncertain diabetes type"
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 175 255"
local col8 = "0 0 0"
clear
forval i = 1/8 {
append using STD_Rate_`i'_`ii'_`iii'_US
}
replace country = "Spain (Catalonia)" if country == "Catalonia, Spain"
preserve
bysort country : keep if _n == 1
forval i = 1/8 {
local C`i' = country[`i']
}
restore
if "`ii'" == "F" & "`iii'" == "inc_t2d" {
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(4) ring(0) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'") ///
cols(2)) ///
graphregion(color(white)) ///
ylabel(5 10 20 50 100 200 500, grid angle(0)) ///
yscale(range(5 500) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence rate (per 100,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oc' - `s'", placement(west) color(black) size(medium))
}
else {
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(5 10 20 50 100 200 500, grid angle(0)) ///
yscale(range(5 500) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence rate (per 100,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oc' - `s'", placement(west) color(black) size(medium))
}
graph save "Graph" Alive_`ii'_`iii'_STD_US, replace
}
}
texdoc stlog close
texdoc stlog, cmdlog
graph combine ///
Alive_F_inc_t1d_STD_US.gph ///
Alive_M_inc_t1d_STD_US.gph ///
Alive_F_inc_t2d_STD_US.gph ///
Alive_M_inc_t2d_STD_US.gph ///
, altshrink rows(2) xsize(5) graphregion(color(white))
texdoc graph, label(STDfigus) figure(h!) caption(Age-standardized incidence rates of diabetes for people aged 15-39 years, by diabetes type and sex. ///
Includes all uncertain diabetes cases as either type 1 or type 2 diabetes. Shaded areas represent 95\% confidence intervals.)
texdoc stlog close
texdoc stlog, cmdlog nodo
forval i = 1/8 {
forval ii = 0/2 {
forval iii = 1/2 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Catalonia, Spain"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
use dbasev9, clear
drop if cal >= 2021
if `iii' == 1 {
drop if age_gp == "35-39"
}
keep if country == "`c'" 
if `ii' == 1 {
keep if sex == "M"
}
if `ii' == 2 {
keep if sex == "F"
}
rename age_gp age
replace age = substr(age,1,2)
destring age, replace
replace age = age+2.5
su(calendar), detail
local lb = r(min)
local ub = r(max)
replace calendar = calendar-2009.5
gen coh = calendar-age
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `iii' == 1 {
replace inc_t1d = inc_t1d+inc_uncertaint
poisson inc_t1d calendar agesp*, exposure(pys)
}
if `iii' == 2 {
replace inc_t2d = inc_t2d+inc_uncertaint
poisson inc_t2d calendar agesp*, exposure(pys)
}
matrix A_`i'_`ii'_`iii' = (`lb',`ub',`i',`ii',`iii',r(table)[1,1], r(table)[5,1], r(table)[6,1])
}
}
matrix A_`i' = (A_`i'_0_1,A_`i'_0_2\ ///
A_`i'_1_1,A_`i'_1_2\ ///
A_`i'_2_1,A_`i'_2_2)
}
matrix A = (A_1\A_2\A_3\A_4\A_5\A_6\A_7\A_8)
clear
svmat A
gen country=""
bysort A3 (A2) : replace country = "Australia" if A3 == 1 & _n == 1
bysort A3 (A2) : replace country = "Spain (Catalonia)" if A3 == 2 & _n == 1
bysort A3 (A2) : replace country = "Denmark" if A3 == 3 & _n == 1
bysort A3 (A2) : replace country = "Finland" if A3 == 4 & _n == 1
bysort A3 (A2) : replace country = "Hungary" if A3 == 5 & _n == 1
bysort A3 (A2) : replace country = "Japan" if A3 == 6 & _n == 1
bysort A3 (A2) : replace country = "Scotland" if A3 == 7 & _n == 1
bysort A3 (A2) : replace country = "South Korea" if A3 == 8 & _n == 1
tostring A1 A2, replace format(%9.0f)
bysort A3 (A2) : gen time = A1+"-"+A2 if _n == 1
gen sex = "Overall" if A4 == 0
replace sex = "Males" if A4 == 1
replace sex = "Females" if A4 == 2
drop A9-A13
foreach var of varlist A6-A16 {
replace `var' = 100*(exp(`var')-1)
}
tostring A6-A16, replace force format(%9.1f)
gen T1 = "$" + A6 + "$ ($" + A7 + "$, $" + A8 + "$)"
gen T2 = "$" + A14 + "$ ($" + A15 + "$, $" + A16 + "$)"
gen njm = _n
gen nj =0
replace nj = 1 if _n == 4 | _n == 5 | _n == 6
sort nj njm
keep country time sex T1 T2
export delimited using APCs_US.csv, delimiter(":") novarnames replace
texdoc stlog close

/***
\color{black}

\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in the incidence rates of diabetes, by country, sex, and diabetes type. Adjusted for age.
Includes all uncertain diabetes cases as either type 1 or type 2 diabetes. Numbers in brackets represent 95\% confidence intervals.}
    \label{APCs}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
	  display columns/1/.style={column name=Period,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/2/.style={column name=Sex, column type={l}, text indicator="},
      display columns/3/.style={column name=Typical type 1 diabetes, column type={r}, column type/.add={|}{}},
      display columns/4/.style={column name=Typical type 2 diabetes, column type={r}, column type/.add={|}{}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{APCs_US.csv}
  \end{center}
\end{table}

\subsection{Excluding people aged 35-39 altogether}

This sensitivity analysis will restrict the analysis cohort to people aged 15-34 only. 

\color{Blue4}
***/


texdoc stlog, cmdlog nodo
quietly {
forval i = 1/8 {
foreach ii in M F {
foreach iii in inc_t1d inc_t2d inc_uncertaint {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Catalonia, Spain"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
use dbasev9, clear
drop if cal >= 2021
drop if age_gp == "35-39"
keep if country == "`c'" & sex == "`ii'"
rename age_gp age
replace age = substr(age,1,2)
destring age, replace
replace age = age+2.5
replace calendar = calendar-2009.5
gen coh = calendar-age
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
local CK5 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `iii' agesp* timesp* cohsp*, exposure(pys)
keep age calendar pys
expand 5
replace pys=pys/5
bysort cal age : replace age = age+_n-3.5
sort age cal
gen coh = calendar-age
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `rang' < 7.99 {
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.99) {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
predict _Rate, ir
replace cal = cal+2009.5
keep cal age pys _Rate
merge m:1 age using refpop1
drop _merge
gen double expdeath = _Rate*B
bysort cal : egen double expdeath1 = sum(expdeath)
gen stdrate = 100000*expdeath1
gen SEC1 = ((B^2)*(_Rate*(1-_Rate)))/pys_nondm
bysort cal : egen double SEC2 = sum(SEC1)
gen double SE = sqrt(SEC2)
gen lb = 100000*(expdeath1-1.96*SE)
gen ub = 100000*(expdeath1+1.96*SE)
bysort cal (age) : keep if _n == 1
noisily count if lb < 0
keep cal stdrate lb ub
gen country = "`c'"
gen sex = "`ii'"
gen OC = "`iii'"
save STD_Rate_`i'_`ii'_`iii'_DS, replace
}
}
}
}
foreach ii in M F {
foreach iii in inc_t1d {
if "`ii'" == "M" {
local s = "Males"
}
else {
local s = "Females"
}
if "`iii'" == "inc_t1d" {
local oc = "Typical type 1 diabetes"
}
else if "`iii'" == "inc_t2d" {
local oc = "Typical type 2 diabetes"
}
else {
local oc = "Uncertain diabetes type"
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 0 0"
clear
forval i = 1/7 {
append using STD_Rate_`i'_`ii'_`iii'_DS
}
replace country = "Spain (Catalonia)" if country == "Catalonia, Spain"
preserve
bysort country : keep if _n == 1
forval i = 1/7 {
local C`i' = country[`i']
}
restore
if "`ii'" == "F" & "`iii'" == "inc_t2d" {
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(4) ring(0) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'") ///
cols(2)) ///
graphregion(color(white)) ///
ylabel(5 10 20 50 100 200 500, grid angle(0)) ///
yscale(range(5 500) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence rate (per 100,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oc' - `s'", placement(west) color(black) size(medium))
}
else {
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(5 10 20 50 100 200 500, grid angle(0)) ///
yscale(range(5 500) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence rate (per 100,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oc' - `s'", placement(west) color(black) size(medium))
}
graph save "Graph" Alive_`ii'_`iii'_STD_DS, replace
}
}
foreach ii in M F {
foreach iii in inc_t2d inc_uncertaint {
if "`ii'" == "M" {
local s = "Males"
}
else {
local s = "Females"
}
if "`iii'" == "inc_t1d" {
local oc = "Typical type 1 diabetes"
}
else if "`iii'" == "inc_t2d" {
local oc = "Typical type 2 diabetes"
}
else {
local oc = "Uncertain diabetes type"
}
local col1 = "0 0 255"
local col2 = "75 0 130"
local col3 = "255 0 255"
local col4 = "255 0 0"
local col5 = "255 125 0"
local col6 = "0 125 0"
local col7 = "0 175 255"
local col8 = "0 0 0"
clear
forval i = 1/8 {
append using STD_Rate_`i'_`ii'_`iii'_DS
}
replace country = "Spain (Catalonia)" if country == "Catalonia, Spain"
preserve
bysort country : keep if _n == 1
forval i = 1/8 {
local C`i' = country[`i']
}
restore
if "`ii'" == "F" & "`iii'" == "inc_t2d" {
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(4) ring(0) region(lcolor(white) color(none)) ///
order(2 "`C1'" ///
4 "`C2'" ///
6 "`C3'" ///
8 "`C4'" ///
10 "`C5'" ///
12 "`C6'" ///
14 "`C7'" ///
16 "`C8'") ///
cols(2)) ///
graphregion(color(white)) ///
ylabel(5 10 20 50 100 200 500, grid angle(0)) ///
yscale(range(5 500) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence rate (per 100,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oc' - `s'", placement(west) color(black) size(medium))
}
else {
twoway ///
(rarea ub lb calendar if country == "`C1'", color("`col1'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C1'", color("`col1'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C2'", color("`col2'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C2'", color("`col2'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C3'", color("`col3'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C3'", color("`col3'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C4'", color("`col4'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C4'", color("`col4'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C5'", color("`col5'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C5'", color("`col5'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C6'", color("`col6'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C6'", color("`col6'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C7'", color("`col7'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C7'", color("`col7'") lpattern(solid)) ///
(rarea ub lb calendar if country == "`C8'", color("`col8'%30") fintensity(inten80) lwidth(none)) ///
(line stdrate calendar if country == "`C8'", color("`col8'") lpattern(solid)) ///
, legend(off) ///
graphregion(color(white)) ///
ylabel(5 10 20 50 100 200 500, grid angle(0)) ///
yscale(range(5 500) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence rate (per 100,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oc' - `s'", placement(west) color(black) size(medium))
}
graph save "Graph" Alive_`ii'_`iii'_STD_DS, replace
}
}
texdoc stlog close
texdoc stlog, cmdlog
graph combine ///
Alive_F_inc_t1d_STD_DS.gph ///
Alive_M_inc_t1d_STD_DS.gph ///
Alive_F_inc_t2d_STD_DS.gph ///
Alive_M_inc_t2d_STD_DS.gph ///
Alive_F_inc_uncertaint_STD_DS.gph ///
Alive_M_inc_uncertaint_STD_DS.gph ///
, altshrink rows(3) xsize(3.3) graphregion(color(white))
texdoc graph, label(STDfigds) figure(h!) caption(Age-standardized incidence rates of diabetes for people aged 15-34 years, by diabetes type and sex. ///
South Korea is excluded from type 1 diabetes due to insufficient numbers. Shaded areas represent 95\% confidence intervals.)
texdoc stlog close
texdoc stlog, cmdlog nodo
forval i = 1/8 {
forval ii = 0/2 {
forval iii = 1/4 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Catalonia, Spain"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
use dbasev9, clear
drop if cal >= 2021
drop if age_gp == "35-39"
keep if country == "`c'" 
if `ii' == 1 {
keep if sex == "M"
}
if `ii' == 2 {
keep if sex == "F"
}
rename age_gp age
replace age = substr(age,1,2)
destring age, replace
replace age = age+2.5
su(calendar), detail
local lb = r(min)
local ub = r(max)
replace calendar = calendar-2009.5
gen coh = calendar-age
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
if `iii' == 1 {
poisson inc_t1d calendar agesp*, exposure(pys)
}
if `iii' == 2 {
poisson inc_t2d calendar agesp*, exposure(pys)
}
if `iii' == 3 {
poisson inc_uncertaint calendar agesp*, exposure(pys)
}
if `iii' == 4 {
gen totinc = inc_t1d+inc_t2d+inc_uncertaint
poisson totinc calendar agesp*, exposure(pys)
}
matrix A_`i'_`ii'_`iii' = (`lb',`ub',`i',`ii',`iii',r(table)[1,1], r(table)[5,1], r(table)[6,1])
}
}
matrix A_`i' = (A_`i'_0_1,A_`i'_0_2,A_`i'_0_3,A_`i'_0_4\ ///
A_`i'_1_1,A_`i'_1_2,A_`i'_1_3,A_`i'_1_4\ ///
A_`i'_2_1,A_`i'_2_2,A_`i'_2_3,A_`i'_2_4)
}
matrix A = (A_1\A_2\A_3\A_4\A_5\A_6\A_7\A_8)
clear
svmat A
gen country=""
bysort A3 (A2) : replace country = "Australia" if A3 == 1 & _n == 1
bysort A3 (A2) : replace country = "Spain (Catalonia)" if A3 == 2 & _n == 1
bysort A3 (A2) : replace country = "Denmark" if A3 == 3 & _n == 1
bysort A3 (A2) : replace country = "Finland" if A3 == 4 & _n == 1
bysort A3 (A2) : replace country = "Hungary" if A3 == 5 & _n == 1
bysort A3 (A2) : replace country = "Japan" if A3 == 6 & _n == 1
bysort A3 (A2) : replace country = "Scotland" if A3 == 7 & _n == 1
bysort A3 (A2) : replace country = "South Korea" if A3 == 8 & _n == 1
tostring A1 A2, replace format(%9.0f)
bysort A3 (A2) : gen time = A1+"-"+A2 if _n == 1
gen sex = "Overall" if A4 == 0
replace sex = "Males" if A4 == 1
replace sex = "Females" if A4 == 2
drop A9-A13 A17-A21 A25-A29
foreach var of varlist A6-A32 {
replace `var' = 100*(exp(`var')-1)
}
tostring A6-A32, replace force format(%9.1f)
gen T1 = "$" + A6 + "$ ($" + A7 + "$, $" + A8 + "$)"
gen T2 = "$" + A14 + "$ ($" + A15 + "$, $" + A16 + "$)"
gen T3 = "$" + A22 + "$ ($" + A23 + "$, $" + A24 + "$)"
gen T4 = "$" + A30 + "$ ($" + A31 + "$, $" + A32 + "$)"
gen njm = _n
gen nj =0
replace nj = 1 if _n == 4 | _n == 5 | _n == 6
sort nj njm
keep country time sex T1 T2 T3 T4
export delimited using APCs_DS.csv, delimiter(":") novarnames replace
texdoc stlog close

/***
\color{black}

\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in the incidence rates of diabetes, by country, sex, and diabetes type. Adjusted for age.
Analysis restricted to ages 15-34. Numbers in brackets represent 95\% confidence intervals.}
    \label{APCs}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
	  display columns/1/.style={column name=Period,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/2/.style={column name=Sex, column type={l}, text indicator="},
      display columns/3/.style={column name=Typical type 1 diabetes, column type={r}, column type/.add={|}{}},
      display columns/4/.style={column name=Typical type 2 diabetes, column type={r}, column type/.add={|}{}},
      display columns/5/.style={column name=Uncertain diabetes type, column type={r}, column type/.add={|}{|}},
      display columns/6/.style={column name=Total diabetes, column type={r}, column type/.add={}{|}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{APCs_DS.csv}
  \end{center}
\end{table}


\clearpage
\section*{References}
\addcontentsline{toc}{section}{References}
\bibliography{/Users/jed/Documents/Library.bib}
\end{document}
***/

texdoc close

/*

import delimited using QA.csv, delimiter(":") clear 
label variable ass "Definition of diabetes"
Other changes
export excel myfile,  firstrow(varlabels) replace
import excel myfile.xls, clear
export delimited QA2, novarnames delimiter(":") replace

import delimited using CI.csv, delimiter(":") clear 
replace v6 = v6*100
replace v8 = v8*100
replace v10 = v10*100
tostring v6 v8 v10, force format(%9.0f) replace
export delimited CI2, novarnames delimiter(":") replace

import delimited using CI2.csv, delimiter(":") clear
replace v4 = subinstr(v4,",","",.)
replace v5 = subinstr(v5,",","",.)
replace v7 = subinstr(v7,",","",.)
replace v9 = subinstr(v9,",","",.)

destring v4 v5 v7 v9, replace

foreach i in 5 7 9 {
local j = `i'+1
gen inc = 100000*v`i'/v4
gen se = sqrt((1-(v`i'/v4))/v`i')
gen lb = 100000*exp(ln(v`i'/v4)-1.96*se)
gen ub = 100000*exp(ln(v`i'/v4)+1.96*se)
tostring v`j', replace
tostring inc lb ub, format(%9.1f) replace force
replace v`j' = inc + " (" + lb + ", " + ub + ")"
drop inc-ub
}


tostring v4 v5 v7 v9, replace force format(%15.0fc)
export delimited CI3, novarnames delimiter(":") replace



*/


texdoc init YO_SA, replace logdir(logsa) gropts(optargs(width=0.8\textwidth))
set linesize 100


/***

\documentclass[11pt]{article}
\usepackage{fullpage}
\usepackage{siunitx}
\usepackage{hyperref,graphicx,booktabs,dcolumn}
\usepackage{stata}
\usepackage[x11names]{xcolor}
\bibliographystyle{unsrt}
\usepackage{natbib}
\usepackage{pdflscape}
\usepackage[section]{placeins}

\usepackage{multirow}
\usepackage{booktabs}

\newcommand{\specialcell}[2][c]{%
  \begin{tabular}[#1]{@{}c@{}}#2\end{tabular}}
\newcommand{\thedate}{\today}

\usepackage{pgfplotstable}
\renewcommand{\figurename}{Supplementary Figure}
\renewcommand{\tablename}{Supplementary Table}

\begin{document}


\begin{titlepage}
    \begin{flushright}
        \Huge
        \textbf{Trends in incidence of young-onset diabetes by diabetes type: 
a multi-national population-based study}
\rule{16cm}{1.5mm} \\
\vspace{0.3cm}
\textbf{Appendix}
\Large
       \vfill
    \end{flushright}
        \Large

\noindent
Dianna J Magliano,
Lei Chen,
Jedidiah I Morton,
Agus Salim,
Bendix Carstensen,
Edward W Gregg,
Meda E Pavkov,
Martti Arffman,
Helen M Colhoun,
Kyoung Hwa Ha,
Tomoaki Imamura,
Gy{\"o}rgy Jermendy,
Dae Jung Kim,
Zolt{\'a}n Kiss,
Didac Mauricio,
Stuart McGurnaghan,
Yuichi Nishioka,
Sarah H Wild, 
Klas Winell, and
Jonathan E Shaw.

\end{titlepage}

\pagebreak
\tableofcontents

\listoftables
\listoffigures

\clearpage
\section{Quality score algorithm}
We used an adapted Newcastle-Ottawa Quality Assessment Scale.
The scale includes items that assess representativeness of the data sources, 
sample size at each time point, the method of defining diabetes, 
whether people with gestational diabetes were excluded, 
and completeness of the number of data points reported. 
The maximum score was 8. Quality was classified as high (7–8), 
medium (5–6), or low ($\leq$4). 
A study can be awarded a maximum of one or 
two points for each numbered item within each category.
 \\
 \\
\noindent \textbf{Selection}
\begin{enumerate} 
\item Representativeness of the general population (sampling frame).
\begin{enumerate} 
\item National scheme with $\geq$80\% coverage of national population (2 points) 
\item Random sample from national health insurance (1 point) 
or national population-based survey with $\geq$80\% response rate (1 point)
\item Regional representative or national scheme with $<$80\% coverage of national population (0 points)  
\end{enumerate}
\item Sample size at each time point.
\begin{enumerate} 
\item $>$10,000 (1 point)
\item $\leq$10,000 (0 points) 
\end{enumerate}
\end{enumerate}

\noindent \textbf{Outcome}
\begin{enumerate} 
\item Definition of diabetes.
\begin{enumerate} 
\item By blood glucose measurement (FPG, OGTT, HbA1c) or by multiple approaches
/administrative algorithm where 2 or more criteria used (2 points) 
\item Clinical diagnosis (e.g. ICD code or physician-diagnosed) (1 point) 
\item Anti-diabetic medication or self-report of physician-diagnosed diabetes  (0 points)	
\end{enumerate}
\item Exclusion of gestational diabetes
\begin{enumerate} 
\item Yes (1 point)
\item No (0 points)
\end{enumerate}
\end{enumerate}

\noindent \textbf{Completeness of trend data}
\begin{enumerate}
\item How many time points are provided?
\begin{enumerate}
\item $\geq$10 (2 points)
\item 6–9 (1 point)
\item $<$6 (0 points)
\end{enumerate}
\end{enumerate}

\noindent Thus, the total possible score is 8.

\clearpage
\section{Supplementary Tables}

\begin{table}[h!]
  \begin{center}
    \caption{Diabetes definition by data source}
    \label{DDef}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names=l,
      col sep=colon,
      header=false,
      string type,
      display columns/0/.style={column name=Jurisdiction, column type={l}, text indicator="},
      display columns/1/.style={column name=Diabetes definition, column type={l}, column type={p{7.5cm}}},
      display columns/2/.style={column name=Gestational diabetes excluded, column type={l}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every last row/.style={after row=\bottomrule},
    ]{Ddef.csv}
  \end{center}
ICD=International Classification of Diseases; ICD-10=International Classification of Diseases, 10th edition. 
\end{table}


\begin{table}[]
\centering
    \caption{A summary of how people with gestational diabetes were excluded in each data source}
\begin{tabular}{p{5cm}p{11cm}}
\hline
Jurisdiction & Method of exclusion of gestational diabetes \\
\hline
Australia &
The presence or absence of gestational diabetes is recorded by the registering clinician for each registrant. \\
Denmark &
If a woman is diagnosed with GDM in the National Patient Register (NPR), she is excluded from entering the diabetes register on any other criterion from 280 days before to 280 days after the GDM diagnosis, ensuring the exclusion of any potential pregnancy-related period and being conservatively thorough. \\
Finland &
The database separates individuals with gestational diabetes by searching for specific diagnosis codes across multiple healthcare registers, including the Hospital Discharge Register, Care Register for Health Care, Register of Primary Health Care Visits, and Cause of Death statistics. Any entry in the Medical Birth Register for gestational diabetes also qualifies. Individuals were classified as having gestational diabetes if no other diabetes diagnoses were found. For diagnoses before 1987, pregnancy and postpartum periods were calculated and compared with diabetes diagnosis dates. Similarly, post-1987 deliveries were checked against antidiabetic medication purchases. If diabetes diagnoses or medication purchases were limited to the pregnancy and postpartum period, the individual was classified as having gestational diabetes. This classification allows the FinDM database to be used for research on gestational diabetes. \\
Hungary &
Gestational diabetes was identified using the ICD-10 code of O244. \\
Japan &
Gestational diabetes was identified using the ICD-10 codes of O244 and O249. \\
Scotland &
Gestational diabetes was recorded as a reason for the diagnosis of diabetes in the clinical record. \\
South Korea &
Gestational diabetes was identified using ICD-10 codes. \\
Spain (Catalonia) &
Only people with ICD-10 codes of E10 or E11 in the clinical records were included. \\
\hline
\end{tabular}
\end{table}

\begin{landscape}
\begin{table}[h!]
  \begin{center}
    \caption{Quality assessment of the included data sources}
    \label{QA}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names=l,
      col sep=colon,
      header=false,
      string type,
      display columns/0/.style={column name=, column type={l}},
      display columns/1/.style={column name=, column type={l}, column type={p{4cm}}},
      display columns/2/.style={column name=, column type={l}, column type={p{2cm}}},
      display columns/3/.style={column name=, column type={l}, column type={p{2cm}}},
      display columns/4/.style={column name=, column type={l}, column type={p{2cm}}},
      display columns/5/.style={column name=, column type={l}, column type={p{2cm}}},
      display columns/6/.style={column name=, column type={l}, column type={p{2cm}}},
      display columns/7/.style={column name=, column type={l}, column type={p{2cm}}},
      every head row/.style={
        after row={\midrule}
            },
        every last row/.style={after row=\bottomrule},
		every row no 1/.style={before row=\hline},
		every row no 2/.style={before row=\hline},
    ]{QA2.csv}
  \end{center}
\end{table}

\clearpage
\pagenumbering{gobble}

\begin{table}[h!]
  \begin{center}
    \caption{Crude incidence rate of diagnosed diabetes for people aged 15-39 years, by jurisdiction. Numbers in brackets represent 95\% confidence intervals.}
    \hspace*{-1.5cm}
    \label{cleansumtab}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
	  display columns/1/.style={column name=Period,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/2/.style={column name=Sex, column type={l}, text indicator="},
      display columns/3/.style={column name=\specialcell{Person-years \\ of follow-up}, column type={r}},
      display columns/4/.style={column name=Incident cases, column type={r}},
      display columns/5/.style={column name=\specialcell{{Crude incidence} \\ {(per 100,000 person-years)}}, column type={r}},
      display columns/6/.style={column name=Incident cases, column type={r}},
      display columns/7/.style={column name=\specialcell{{Crude incidence} \\ {(per 100,000 person-years)}}, column type={r}},
      display columns/8/.style={column name=Incident cases, column type={r}},
      display columns/9/.style={column name=\specialcell{{Crude incidence} \\ {(per 100,000 person-years)}}, column type={r}},
      every head row/.style={
        before row={\toprule
					& & & & \multicolumn{2}{c}{Typical type 1 diabetes} & \multicolumn{2}{c}{Typical type 2 diabetes} & \multicolumn{2}{c}{Uncertain diabetes type} \\
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{CI3.csv}
  \end{center}
\end{table}

\end{landscape}

\clearpage
\pagenumbering{arabic}
\setcounter{page}{10}


\begin{table}[h!]
  \begin{center}
    \caption{Age distribution of people with incident diabetes and people without diabetes, by jurisdiction}
    \label{cleansumtab}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
      display columns/0/.style={column name=, column type={l}, text indicator="},
      display columns/1/.style={column name=\specialcell{15-19 \\ years}, column type={r}},
      display columns/2/.style={column name=\specialcell{20-24 \\ years}, column type={r}},
      display columns/3/.style={column name=\specialcell{25-29 \\ years}, column type={r}},
      display columns/4/.style={column name=\specialcell{30-34 \\ years}, column type={r}},
      display columns/5/.style={column name=\specialcell{35-39 \\ years}, column type={r}},
      display columns/6/.style={column name=\specialcell{15-19 \\ years}, column type={r}, column type/.add={|}{}},
      display columns/7/.style={column name=\specialcell{20-24 \\ years}, column type={r}},
      display columns/8/.style={column name=\specialcell{25-29 \\ years}, column type={r}},
      display columns/9/.style={column name=\specialcell{30-34 \\ years}, column type={r}},
      display columns/10/.style={column name=\specialcell{35-39 \\ years}, column type={r}},
      every head row/.style={
        before row={\toprule
					& \multicolumn{5}{c}{People with incident diabetes (\%)} & \multicolumn{5}{c}{People without diabetes (\%)} \\
					\cmidrule{2-11}
					},
        after row={\midrule}
            },
        every last row/.style={after row=\bottomrule},
    ]{AD.csv}
  \end{center}
\end{table}


\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in the incidence rates of diabetes, by country, sex, and diabetes type. Adjusted for age. Numbers in brackets represent 95\% confidence intervals.}
    \label{APCs}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
	  display columns/1/.style={column name=Period,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/2/.style={column name=Sex, column type={l}, text indicator="},
      display columns/3/.style={column name=Typical type 1 diabetes, column type={r}, column type/.add={|}{}},
      display columns/4/.style={column name=Typical type 2 diabetes, column type={r}, column type/.add={|}{}},
      display columns/5/.style={column name=Uncertain diabetes type, column type={r}, column type/.add={|}{|}},
      display columns/6/.style={column name=Total diabetes, column type={r}, column type/.add={}{|}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{APCs.csv}
  \end{center}
\end{table}


\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in the incidence rates of diabetes, by country, sex, and diabetes type. Adjusted for age.
Analysis restricted to ages 15-34. Numbers in brackets represent 95\% confidence intervals.}
    \label{APCs}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
	  display columns/1/.style={column name=Period,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/2/.style={column name=Sex, column type={l}, text indicator="},
      display columns/3/.style={column name=Typical type 1 diabetes, column type={r}, column type/.add={|}{}},
      display columns/4/.style={column name=Typical type 2 diabetes, column type={r}, column type/.add={|}{}},
      display columns/5/.style={column name=Uncertain diabetes type, column type={r}, column type/.add={|}{|}},
      display columns/6/.style={column name=Total diabetes, column type={r}, column type/.add={}{|}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{APCs_DS.csv}
  \end{center}
\end{table}


\begin{table}[h!]
  \begin{center}
    \caption{Average annual change in the incidence rates of diabetes, by country, sex, and diabetes type. Adjusted for age.
Includes all uncertain diabetes cases as either type 1 or type 2 diabetes. Numbers in brackets represent 95\% confidence intervals.}
    \label{APCs}
     \fontsize{7pt}{9pt}\selectfont\pgfplotstabletypeset[
      multicolumn names,
      col sep=colon,
      header=false,
      string type,
	  display columns/0/.style={column name=Country,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
	  display columns/1/.style={column name=Period,
		assign cell content/.code={
\pgfkeyssetvalue{/pgfplots/table/@cell content}
{\multirow{3}{*}{##1}}}},
      display columns/2/.style={column name=Sex, column type={l}, text indicator="},
      display columns/3/.style={column name=Typical type 1 diabetes, column type={r}, column type/.add={|}{}},
      display columns/4/.style={column name=Typical type 2 diabetes, column type={r}, column type/.add={|}{}},
      every head row/.style={
        before row={\toprule
					},
        after row={\midrule}
            },
        every nth row={3}{before row=\midrule},
        every last row/.style={after row=\bottomrule},
    ]{APCs_US.csv}
  \end{center}
\end{table}





\clearpage
\section{Supplementary Figures}

***/

texdoc stlog, nolog
use dbasev9, clear
drop if cal >= 2021
collapse (sum) inc_t1d inc_t2d inc_uncertaint pys_nondm, by(country calendar_yr)
gen inc1 = 100000*inc_t1d/pys_nondm
gen se1 = sqrt((1-(inc_t1d/pys_nondm))/inc_t1d)
gen lb1 = 100000*exp(ln(inc_t1d/pys_nondm)-1.96*se1)
gen ub1 = 100000*exp(ln(inc_t1d/pys_nondm)+1.96*se1)
gen inc2 = 100000*inc_t2d/pys_nondm
gen se2 = sqrt((1-(inc_t2d/pys_nondm))/inc_t2d)
gen lb2 = 100000*exp(ln(inc_t2d/pys_nondm)-1.96*se2)
gen ub2 = 100000*exp(ln(inc_t2d/pys_nondm)+1.96*se2)
gen inc3 = 100000*inc_unc/pys_nondm
gen se3 = sqrt((1-(inc_unc/pys_nondm))/inc_unc)
gen lb3 = 100000*exp(ln(inc_unc/pys_nondm)-1.96*se3)
gen ub3 = 100000*exp(ln(inc_unc/pys_nondm)+1.96*se3)
foreach i in 1 3 4 5 6 7 8 2 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
local co = "`c'"
if `i' == 2 {
local c = "Catalonia, Spain"
local co = "Spain (Catalonia)"
}
twoway ///
(line inc1 calendar if country == "`c'", color(dknavy)) ///
(line inc2 calendar if country == "`c'", color(cranberry)) ///
(line inc3 calendar if country == "`c'", color(magenta)) ///
(rarea ub1 lb1 calendar if country == "`c'", color(dknavy%30) fintensity(inten80) lwidth(none)) ///
(rarea ub2 lb2 calendar if country == "`c'", color(cranberry%30) fintensity(inten80) lwidth(none)) ///
(rarea ub3 lb3 calendar if country == "`c'", color(magenta%30) fintensity(inten80) lwidth(none)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "Typical type 1 diabetes" ///
2 "Typical type 2 diabetes" ///
3 "Uncertain type") ///
rows(3)) ///
graphregion(color(white)) ///
xlabel(2000(5)2020) ///
ylabel(0.5 "0.5" 1 2 5 10 20 50 100 500, angle(0) format(%9.0f)) ///
yscale(log range(0.5 500)) ///
ytitle("Incidence rate (per 100,000 person-years)") ///
xtitle("Calendar year") ///
title("`co'", placement(west) color(gs0) size(medium))
texdoc graph, label(`c'crude) figure(h!) caption(Crude incidence rates of diabetes in `co' among people aged 15-39 years, by diabetes type. Shaded areas represent 95\% confidence intervals.)
}
use dbasev9, clear
drop if cal >= 2021
collapse (sum) inc_t1d inc_t2d inc_uncertaint pys_nondm, by(country sex calendar_yr)
gen inc1 = 100000*inc_t1d/pys_nondm
gen se1 = sqrt((1-(inc_t1d/pys_nondm))/inc_t1d)
gen lb1 = 100000*exp(ln(inc_t1d/pys_nondm)-1.96*se1)
gen ub1 = 100000*exp(ln(inc_t1d/pys_nondm)+1.96*se1)
gen inc2 = 100000*inc_t2d/pys_nondm
gen se2 = sqrt((1-(inc_t2d/pys_nondm))/inc_t2d)
gen lb2 = 100000*exp(ln(inc_t2d/pys_nondm)-1.96*se2)
gen ub2 = 100000*exp(ln(inc_t2d/pys_nondm)+1.96*se2)
gen inc3 = 100000*inc_unc/pys_nondm
gen se3 = sqrt((1-(inc_unc/pys_nondm))/inc_unc)
gen lb3 = 100000*exp(ln(inc_unc/pys_nondm)-1.96*se3)
gen ub3 = 100000*exp(ln(inc_unc/pys_nondm)+1.96*se3)
foreach i in 1 3 4 5 6 7 8 2 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
local co = "`c'"
if `i' == 2 {
local c = "Catalonia, Spain"
local co = "Spain (Catalonia)"
}
twoway ///
(line inc1 calendar if country == "`c'" & sex == "F", color(dknavy)) ///
(line inc1 calendar if country == "`c'" & sex == "M", color(dknavy) lpattern(shortdash)) ///
(line inc2 calendar if country == "`c'" & sex == "F", color(cranberry)) ///
(line inc2 calendar if country == "`c'" & sex == "M", color(cranberry) lpattern(shortdash)) ///
(line inc3 calendar if country == "`c'" & sex == "F", color(magenta)) ///
(line inc3 calendar if country == "`c'" & sex == "M", color(magenta) lpattern(shortdash)) ///
(rarea ub1 lb1 calendar if country == "`c'" & sex == "F", color(dknavy%30) fintensity(inten80) lwidth(none)) ///
(rarea ub2 lb2 calendar if country == "`c'" & sex == "F", color(cranberry%30) fintensity(inten80) lwidth(none)) ///
(rarea ub3 lb3 calendar if country == "`c'" & sex == "F", color(magenta%30) fintensity(inten80) lwidth(none)) ///
(rarea ub1 lb1 calendar if country == "`c'" & sex == "M", color(dknavy%30) fintensity(inten80) lwidth(none)) ///
(rarea ub2 lb2 calendar if country == "`c'" & sex == "M", color(cranberry%30) fintensity(inten80) lwidth(none)) ///
(rarea ub3 lb3 calendar if country == "`c'" & sex == "M", color(magenta%30) fintensity(inten80) lwidth(none)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "Typical type 1 diabetes" ///
3 "Typical type 2 diabetes" ///
5 "Uncertain type") ///
rows(3)) ///
graphregion(color(white)) ///
xlabel(2000(5)2020) ///
ylabel(0.05 "0.05" 0.1 "0.1" 0.2 "0.2" 0.5 "0.5" 1 2 5 10 20 50 100 200 500, angle(0)) ///
yscale(log range(0.05 500)) ///
ytitle("Incidence rate (per 100,000 person-years)") ///
xtitle("Calendar year") ///
title("`co'", placement(west) color(gs0) size(medium))
texdoc graph, label(`c'crude) figure(h!) caption(Crude incidence rates of diabetes in `co' among people aged 15-39 years, by diabetes type and sex. Females = solid connecting lines; males = dashed connecting lines. Shaded areas represent 95\% confidence intervals.)
}
texdoc stlog close

/***

\begin{figure}
    \centering
    \includegraphics[width=0.8\textwidth]{APCfig1.pdf}
    \caption{Average annual change in the incidence rates of diabetes, by jurisdiction and diabetes type.}
    \label{AAPCfig1}
\end{figure}

***/

texdoc stlog, nolog
foreach i in 1 3 4 5 6 7 8 2 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
local co = "`c'"
if `i' == 2 {
local c = "Catalonia, Spain"
local co = "Spain (Catalonia)"
}
graph combine ///
TTFATF_`i'_F_inc_t1d.gph ///
TTFATF_`i'_M_inc_t1d.gph ///
TTFATF_`i'_F_inc_t2d.gph ///
TTFATF_`i'_M_inc_t2d.gph ///
TTFATF_`i'_F_inc_uncertaint.gph ///
TTFATF_`i'_M_inc_uncertaint.gph ///
, altshrink rows(3) xsize(3.5) graphregion(color(white))
texdoc graph, label(`c' agespec) figure(h!) caption(Incidence rates of diabetes in `co' by age for the first, middle, and last calendar year of follow-up, by diabetes type and sex. Shaded areas represent 95\% confidence intervals.)
}
foreach i in 1 3 4 5 6 7 8 2 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
local co = "`c'"
if `i' == 2 {
local c = "Catalonia, Spain"
local co = "Spain (Catalonia)"
}
graph combine ///
Escape_`i'_F_inc_t1d.gph ///
Escape_`i'_M_inc_t1d.gph ///
Escape_`i'_F_inc_t2d.gph ///
Escape_`i'_M_inc_t2d.gph ///
Escape_`i'_F_inc_uncertaint.gph ///
Escape_`i'_M_inc_uncertaint.gph ///
, altshrink rows(3) xsize(3.5) graphregion(color(white))
texdoc graph, label(`c' agespec) figure(h!) ///
caption(Incidence rates of diabetes in `co' for people aged 15, 20, 25, 30, and 35 years, by diabetes type and sex. Shaded areas represent 95\% confidence intervals.)
}
foreach i in 1 3 4 5 6 7 8 2 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
local co = "`c'"
if `i' == 2 {
local c = "Catalonia, Spain"
local co = "Spain (Catalonia)"
}
if "`iii'" == "inc_t1d" {
local oc = "Typical type 1 diabetes"
}
else if "`iii'" == "inc_t2d" {
local oc = "Typical type 2 diabetes"
}
else {
local oc = "Uncertain diabetes type"
}
graph combine ///
Apage_`i'_inc_t1d_1.gph ///
Apage_`i'_inc_t1d_2.gph ///
Apage_`i'_inc_t2d_1.gph ///
Apage_`i'_inc_t2d_2.gph ///
Apage_`i'_inc_uncertaint_1.gph ///
Apage_`i'_inc_uncertaint_2.gph ///
, altshrink rows(3) xsize(3.5) graphregion(color(white))
texdoc graph, label(`c' apcageg) figure(h!) caption(Annual change in the incidence rates of diabetes in `co' by age, by diabetes type and sex. ///
Values are predicted from a Poisson model with a spline effect of attained age, a log-linear effect of calendar time, and an interaction ///
between age and calendar time. The left panels use a spline term for age in the interaction, the right panels use the product of ///
age and calendar time in the interaction. Shaded areas represent 95\% confidence intervals.)
}
graph combine ///
Alive_F_inc_t1d_STD_DS.gph ///
Alive_M_inc_t1d_STD_DS.gph ///
Alive_F_inc_t2d_STD_DS.gph ///
Alive_M_inc_t2d_STD_DS.gph ///
Alive_F_inc_uncertaint_STD_DS.gph ///
Alive_M_inc_uncertaint_STD_DS.gph ///
, altshrink rows(3) xsize(3.3) graphregion(color(white))
texdoc graph, label(STDfigds) figure(h!) caption(Age-standardized incidence rates of diabetes for people aged 15-34 years, by diabetes type and sex. ///
South Korea is excluded from type 1 diabetes due to insufficient numbers. Shaded areas represent 95\% confidence intervals.)
graph combine ///
Alive_F_inc_t1d_STD_US.gph ///
Alive_M_inc_t1d_STD_US.gph ///
Alive_F_inc_t2d_STD_US.gph ///
Alive_M_inc_t2d_STD_US.gph ///
, altshrink rows(2) xsize(5) graphregion(color(white))
texdoc graph, label(STDfigus) figure(h!) caption(Age-standardized incidence rates of diabetes for people aged 15-39 years, by diabetes type and sex. ///
Includes all uncertain diabetes cases as either type 1 or type 2 diabetes. Shaded areas represent 95\% confidence intervals.)
texdoc stlog close


/***

\end{document}
***/

texdoc close

/*

*mkdir gof


forval i = 1/8 {
foreach ii in M F {
foreach iii in inc_t1d inc_t2d inc_uncertaint {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Catalonia, Spain"
}
if `i' == 3 {
local c = "Denmark"
}
if `i' == 4 {
local c = "Finland"
}
if `i' == 5 {
local c = "Hungary"
}
if `i' == 6 {
local c = "Japan"
}
if `i' == 7 {
local c = "Scotland"
}
if `i' == 8 {
local c = "South Korea"
}
use dbasev9, clear
drop if cal >= 2021
if "`iii'" == "inc_t1d" {
drop if age_gp == "35-39"
}
keep if country == "`c'" & sex == "`ii'"
rename age_gp age
replace age = substr(age,1,2)
destring age, replace
replace age = age+2.5
replace calendar = calendar-2009.5
gen coh = calendar-age
centile(age), centile(5 35 65 95)
local A1 = r(c_1)
local A2 = r(c_2)
local A3 = r(c_3)
local A4 = r(c_4)
mkspline agesp = age, cubic knots(`A1' `A2' `A3' `A4')
su(calendar), detail
local rang = r(max)-r(min)
if `rang' < 8 {
centile calendar, centile(25 75)
local CK1 = r(c_1)
local CK2 = r(c_2)
mkspline timesp = calendar, cubic knots(`CK1' `CK2')
}
else if inrange(`rang',8,11.9) {
centile calendar, centile(10 50 90)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3')
}
else if inrange(`rang',12,15.9) {
centile calendar, centile(5 35 65 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK4 = r(c_4)
local CK5 = r(c_5)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4' `CK5')
}
centile(coh), centile(5 35 65 95)
local CO1 = r(c_1)
local CO2 = r(c_2)
local CO3 = r(c_3)
local CO4 = r(c_4)
mkspline cohsp = coh, cubic knots(`CO1' `CO2' `CO3' `CO4')
poisson `iii' agesp* timesp* cohsp*, exposure(pys)
estat gof
clear
set obs 1
gen v1 = "`c'"
gen v2 = "`ii'"
gen v3 = "`iii'"
gen dgof = r(chi2_d)
gen df = r(df)
save gof/gof_`i'_`ii'_`iii', replace
}
}
}
clear
forval i = 1/8 {
foreach ii in M F {
foreach iii in inc_t1d inc_t2d inc_uncertaint {
append using gof/gof_`i'_`ii'_`iii'

}
}
}
gen rat = dgof/df
format dgof rat %9.2f
replace v2 = "Females" if v2 == "F"
replace v2 = "Males" if v2 == "M"
replace v3 = "Type 1 diabetes" if v3 == "inc_t1d"
replace v3 = "Type 2 diabetes" if v3 == "inc_t2d"
replace v3 = "Uncertain diabetes type" if v3 == "inc_uncertaint"


su rat, detail


*/
