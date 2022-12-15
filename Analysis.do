
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

\usepackage{chngcntr}
\counterwithin{figure}{section}
\counterwithin{table}{section}

\usepackage{multirow}
\usepackage{booktabs}

\newcommand{\specialcell}[2][c]{%
  \begin{tabular}[#1]{@{}c@{}}#2\end{tabular}}
\newcommand{\thedate}{\today}

\usepackage{pgfplotstable}

\begin{document}


\begin{titlepage}
    \begin{flushright}
        \Huge
        \textbf{International trends in the incidence of diabetes in young people}
\color{Magenta1}
\rule{16cm}{2mm} \\
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
Jedidiah Morton \\
\color{blue}
\href{mailto:Jedidiah.Morton@Monash.edu}{Jedidiah.Morton@monash.edu} \\ 
\color{black}
Research Fellow \\
\color{blue}
\color{black}
Center for Medicine Use and Safety, Faculty of Pharmacy and Pharmaceutical Sciences, Monash University, Melbourne, Australia \\\
Baker Heart and Diabetes Institute, Melbourne, Australia \\
\\
\noindent
Lei Chen \\
Research Officer \\
Baker Heart and Diabetes Institute, Melbourne, Australia \\
\\
\noindent
Bendix Carstensen \\
Senior Statistician \\
Steno Diabetes Center Copenhagen, Gentofte, Denmark \\
Department of Biostatistics, University of Copenhagen \\
\\
\noindent
Dianna Magliano \\
Professor and Head of Diabetes and Population Health \\
Baker Heart and Diabetes Institute, Melbourne, Australia \\

\end{titlepage}

\pagebreak
\tableofcontents


\pagebreak
\section{Preface}

The methods used in this analyses are drawn heavily/almost entirely from Bendix Carstensen 
(see \cite{MaglianoLDE2021,CarstensenSTATMED2007}). \\
To generate this document, the Stata package texdoc \cite{Jann2016Stata} was used, which is 
available from: \color{blue} \url{http://repec.sowi.unibe.ch/stata/texdoc/} \color{black} (accessed 14 November 2022). The 
final Stata do file and this pdf are available at: \color{blue} \url{https://github.com/jimb0w/YO} \color{black}.
Throughout, the colour schemes used are \emph{inferno} and \emph{viridis} from the
\emph{viridis} package \cite{GarnierR2021}.

\pagebreak
\section{Crude rates}

We start by examining crude incidence rates for each country:

\color{Blue4}
***/


texdoc stlog, cmdlog
cd "/Users/jed/Documents/YO"
import delimited "Consortium young-onset diabetes_incidence v2.csv", varnames(1) clear
collapse (sum) inc_t1d inc_t2d inc_uncertaint pys_nondm, by(country calendar_yr)
gen inc1 = 1000*inc_t1d/pys_nondm
gen inc2 = 1000*inc_t2d/pys_nondm
gen inc3 = 1000*inc_unc/pys_nondm
forval i = 1/6 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Denmark"
}
if `i' == 3 {
local c = "Finland"
}
if `i' == 4 {
local c = "Hungary"
}
if `i' == 5 {
local c = "Scotland"
}
if `i' == 6 {
local c = "South Korea"
}
twoway ///
(connected inc1 calendar if country == "`c'", color(dknavy)) ///
(connected inc2 calendar if country == "`c'", color(cranberry)) ///
(connected inc3 calendar if country == "`c'", color(magenta)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "Type 1 diabetes" ///
2 "Type 2 diabetes" ///
3 "Uncertain type") ///
rows(3)) ///
graphregion(color(white)) ///
xlabel(1995(5)2020) ///
ylabel(0.1 0.2 0.5 1 2 5, angle(0) format(%9.1f)) ///
yscale(log range(0.05 6)) ///
ytitle("Incidence (per 1,000 person-years)") ///
xtitle("Calendar year") ///
title("`c'", placement(west) color(gs0) size(medium))
texdoc graph, label(`c'crude) caption(Crude incidence of diabetes in `c' among people aged 15-39 years, by diabetes type)
}
texdoc stlog close

/***
\color{black}

And by sex:

\color{Blue4}
***/


texdoc stlog, cmdlog
import delimited "Consortium young-onset diabetes_incidence v2.csv", varnames(1) clear
collapse (sum) inc_t1d inc_t2d inc_uncertaint pys_nondm, by(country sex calendar_yr)
gen inc1 = 1000*inc_t1d/pys_nondm
gen inc2 = 1000*inc_t2d/pys_nondm
gen inc3 = 1000*inc_unc/pys_nondm
forval i = 1/6 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Denmark"
}
if `i' == 3 {
local c = "Finland"
}
if `i' == 4 {
local c = "Hungary"
}
if `i' == 5 {
local c = "Scotland"
}
if `i' == 6 {
local c = "South Korea"
}

twoway ///
(connected inc1 calendar if country == "`c'" & sex == "F", color(dknavy)) ///
(connected inc1 calendar if country == "`c'" & sex == "M", color(dknavy) lpattern(shortdash)) ///
(connected inc2 calendar if country == "`c'" & sex == "F", color(cranberry)) ///
(connected inc2 calendar if country == "`c'" & sex == "M", color(cranberry) lpattern(shortdash)) ///
(connected inc3 calendar if country == "`c'" & sex == "F", color(magenta)) ///
(connected inc3 calendar if country == "`c'" & sex == "M", color(magenta) lpattern(shortdash)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "Type 1 diabetes" ///
3 "Type 2 diabetes" ///
5 "Uncertain type") ///
rows(3)) ///
graphregion(color(white)) ///
xlabel(1995(5)2020) ///
ylabel(0.1 0.2 0.5 1 2 5, angle(0) format(%9.1f)) ///
yscale(log range(0.05 6)) ///
ytitle("Incidence (per 1,000 person-years)") ///
xtitle("Calendar year") ///
title("`c'", placement(west) color(gs0) size(medium))
texdoc graph, label(`c'crude) caption(Crude incidence of diabetes in `c' among people aged 15-39 years, by diabetes type and sex. Females = solid connecting lines; males = dashed connecting lines.)
}
texdoc stlog close


/***
\color{black}
\clearpage
\section{Adjusted rates}

For the analyses, we are going to use Carstensen's Age-Period-Cohort model \cite{CarstensenSTATMED2007}
to estimate the age and sex-specific incidence of type 2 diabetes for each country. For this, 
we take the incidence and person-years in 5-year age groups, and fit a Poisson model with spline effects
of age, period (calendar time; measured from 2010 (i.e., 2010 is set to 0)), and cohort (calendar time minus age). 
This is done separately for each country and sex. Moreover, because of the different years covered by each dataset,
the knot locations are different for each country (and knot placement is as recommended by Harrell \cite{Harrell2001Springer} 
for period and cohort effects).
Then, we use this model to predict the incidence of type 2 diabetes
for specific ages. These results are presented in figures showing the age-specific
incidence of type 2 diabetes for each country (figures~\ref{Australia agespec} - ~\ref{South Korea agespec}).

\color{Blue4}
***/

texdoc stlog, cmdlog
forval i = 1/6 {
foreach ii in M F {
foreach iii in inc_t1d inc_t2d inc_uncertaint {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Denmark"
}
if `i' == 3 {
local c = "Finland"
}
if `i' == 4 {
local c = "Hungary"
}
if `i' == 5 {
local c = "Scotland"
}
if `i' == 6 {
local c = "South Korea"
}
import delimited "Consortium young-onset diabetes_incidence v2.csv", varnames(1) clear
keep if country == "`c'" & sex == "`ii'"
rename age_gp age
replace age = substr(age,1,2)
destring age, replace
replace age = age+2.5
replace calendar = calendar-2010
gen coh = calendar-age
mkspline agesp = age, cubic knots(16(8)40)
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
local CK3 = r(c_4)
mkspline timesp = calendar, cubic knots(`CK1' `CK2' `CK3' `CK4')
}
else {
centile calendar, centile(5 27.5 50 72.5 95)
local CK1 = r(c_1)
local CK2 = r(c_2)
local CK3 = r(c_3)
local CK3 = r(c_4)
local CK3 = r(c_5)
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
expand 10
sort age cal
bysort age cal : replace cal = cal+(_n/10)-0.1
replace pys = pys/10
gen coh = calendar-age
mkspline agesp = age, cubic knots(16(8)40)
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
replace _Rate = _Rate*1000
gen lb = exp(ln(_Rate)-1.96*errr)
gen ub = exp(ln(_Rate)+1.96*errr)
gen country = "`c'"
gen sex = "`ii'"
gen OC = "`iii'"
replace cal = cal+2010
save APC_Rate_`i'_`ii'_`iii', replace
}
}
}
forval i = 1/6 {
foreach ii in M F {
foreach iii in inc_t1d inc_t2d inc_uncertaint {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Denmark"
}
if `i' == 3 {
local c = "Finland"
}
if `i' == 4 {
local c = "Hungary"
}
if `i' == 5 {
local c = "Scotland"
}
if `i' == 6 {
local c = "South Korea"
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
local oc = "Type 1 diabetes"
}
else if "`iii'" == "inc_t2d" {
local oc = "Type 2 diabetes"
}
else {
local oc = "Uncertain diabetes type"
}
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
ylabel(0.002 "0.002" ///
0.005 "0.005" ///
0.01 "0.01" ///
0.02 "0.02" ///
0.05 "0.05" ///
0.1 "0.1" ///
0.2 "0.2" ///
0.5 "0.5" ///
1.0 "1.0" ///
2.0 "2.0" ///
5.0 "5.0", format(%9.3f) grid angle(0)) ///
yscale(range(0.001 5.05) log) ///
xscale(range(1995 2020)) ///
xlabel(1995(5)2020, nogrid) ///
ytitle("Incidence (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`c' - `oc' - `s'", placement(west) color(black) size(medium))
graph save "Graph" Escape_`i'_`ii'_`iii', replace
}
}
}
texdoc stlog close
texdoc stlog, cmdlog
forval i = 1/6 {
if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Denmark"
}
if `i' == 3 {
local c = "Finland"
}
if `i' == 4 {
local c = "Hungary"
}
if `i' == 5 {
local c = "Scotland"
}
if `i' == 6 {
local c = "South Korea"
}
graph combine ///
Escape_`i'_F_inc_t1d.gph ///
Escape_`i'_M_inc_t1d.gph ///
Escape_`i'_F_inc_t2d.gph ///
Escape_`i'_M_inc_t2d.gph ///
Escape_`i'_F_inc_uncertaint.gph ///
Escape_`i'_M_inc_uncertaint.gph ///
, altshrink rows(3) xsize(3.5) graphregion(color(white))
texdoc graph, label(`c' agespec) caption(Incidence of diabetes in `c' for people aged 15, 20, 25, 30, and 35 years, by diabetes type and sex)
}
texdoc stlog close

/***
\color{black}

To make comparison between countries easier, we will plot all curves for age 25 on the same graph 
(and 15 and 35, to see if there is any difference depending on the age selected; figures ~\ref{agespec15} - ~\ref{agespec35}). \\
Note: While these are not ordinal countries, I have elected to use an ordinal colour scheme, which is why I sort the legend
by country for each graph (to give some semblance of the countries being ordinal). Personally, I find this easiest to interpret, and it's
also a colour-blind friendly way to present the results.

\color{Blue4}
***/


texdoc stlog, cmdlog
forval age = 15(10)35 {
foreach ii in M F {
foreach iii in inc_t1d inc_t2d inc_uncertaint {
clear
forval i = 1/6 {
append using APC_Rate_`i'_`ii'_`iii'
}
keep if age == `age'
bysort country (calendar) : gen A = _Rate if _n==_N
bysort country (calendar) : egen B = min(A)
sort B cal
preserve
bysort B (cal) : keep if _n == 1
forval i = 1/6 {
local C`i' = country[`i']
}
if "`ii'" == "M" {
local s = "Males"
use viridis, clear
local col1 = var7[7]
local col2 = var7[6]
local col3 = var7[5]
local col4 = var7[4]
local col5 = var7[3]
local col6 = var7[2]
}
else {
local s = "Females"
use inferno, clear
local col1 = var7[7]
local col2 = var7[6]
local col3 = var7[5]
local col4 = var7[4]
local col5 = var7[3]
local col6 = var7[2]
}
if "`iii'" == "inc_t1d" {
local oc = "Type 1 diabetes"
}
else if "`iii'" == "inc_t2d" {
local oc = "Type 2 diabetes"
}
else {
local oc = "Uncertain diabetes type"
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
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(12 "`C6'" ///
10 "`C5'" ///
8 "`C4'" ///
6 "`C3'" ///
4 "`C2'" ///
2 "`C1'") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.002 "0.002" ///
0.005 "0.005" ///
0.01 "0.01" ///
0.02 "0.02" ///
0.05 "0.05" ///
0.1 "0.1" ///
0.2 "0.2" ///
0.5 "0.5" ///
1.0 "1.0" ///
2.0 "2.0" ///
5.0 "5.0", format(%9.3f) grid angle(0)) ///
yscale(range(0.001 5.05) log) ///
xscale(range(1995 2020)) ///
xlabel(1995(5)2020, nogrid) ///
ytitle("Incidence (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`oc' - `s'", placement(west) color(black) size(medium))
graph save "Graph" Alive_`ii'_`iii'_`age', replace
}
}
}
texdoc stlog close
texdoc stlog, cmdlog
graph combine ///
Alive_F_inc_t1d_15.gph ///
Alive_M_inc_t1d_15.gph ///
Alive_F_inc_t2d_15.gph ///
Alive_M_inc_t2d_15.gph ///
Alive_F_inc_uncertaint_15.gph ///
Alive_M_inc_uncertaint_15.gph ///
, altshrink rows(3) xsize(4) graphregion(color(white))
texdoc graph, label(agespec15) caption(Incidence of diabetes for people aged 15 years, by diabetes type and sex)
graph combine ///
Alive_F_inc_t1d_25.gph ///
Alive_M_inc_t1d_25.gph ///
Alive_F_inc_t2d_25.gph ///
Alive_M_inc_t2d_25.gph ///
Alive_F_inc_uncertaint_25.gph ///
Alive_M_inc_uncertaint_25.gph ///
, altshrink rows(3) xsize(4) graphregion(color(white))
texdoc graph, label(agespec25) caption(Incidence of diabetes for people aged 25 years, by diabetes type and sex)
graph combine ///
Alive_F_inc_t1d_35.gph ///
Alive_M_inc_t1d_35.gph ///
Alive_F_inc_t2d_35.gph ///
Alive_M_inc_t2d_35.gph ///
Alive_F_inc_uncertaint_35.gph ///
Alive_M_inc_uncertaint_35.gph ///
, altshrink rows(3) xsize(4) graphregion(color(white))
texdoc graph, label(agespec35) caption(Incidence of diabetes for people aged 35 years, by diabetes type and sex)
texdoc stlog close


/***
\color{black}

\clearpage
\section{Average Annual Percent Changes}

As a summary metric, we will also estimate the average annual percent change
in incidence - overall, and by sex. For this, we use a different model with a spline effect
of age, but only a (log-)linear effect of calendar time. This means we are assuming the effect of time
is constant throughout follow-up, which we already know is false for a few countries (e.g., Australia;
figure~\ref{agespec25}). \\

\color{red}
If we want, we can explore variation by age, but for now I've just done overall in a table. 
As an idea -- we could also fit joinpoints at the points where the trend changes direction?
Not sure what BC would think about that. 

\color{Blue4}
***/

texdoc stlog, cmdlog
forval i = 1/6 {
forval ii = 0/2 {
forval iii = 1/3 {

if `i' == 1 {
local c = "Australia"
}
if `i' == 2 {
local c = "Denmark"
}
if `i' == 3 {
local c = "Finland"
}
if `i' == 4 {
local c = "Hungary"
}
if `i' == 5 {
local c = "Scotland"
}
if `i' == 6 {
local c = "South Korea"
}
import delimited "Consortium young-onset diabetes_incidence v2.csv", varnames(1) clear
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
replace calendar = calendar-2010
gen coh = calendar-age
mkspline agesp = age, cubic knots(16(8)40)
if `iii' == 1 {
poisson inc_t1d calendar agesp*, exposure(pys)
}
if `iii' == 2 {
poisson inc_t2d calendar agesp*, exposure(pys)
}
if `iii' == 3 {
poisson inc_uncertaint calendar agesp*, exposure(pys)
}
matrix A_`i'_`ii'_`iii' = (`lb',`ub',`i',`ii',`iii',r(table)[1,1], r(table)[5,1], r(table)[6,1])
}
}
matrix A_`i' = (A_`i'_0_1,A_`i'_0_2,A_`i'_0_3\ ///
A_`i'_1_1,A_`i'_1_2,A_`i'_1_3\ ///
A_`i'_2_1,A_`i'_2_2,A_`i'_2_3)
}
matrix A = (A_1\A_2\A_3\A_4\A_5\A_6)
clear
svmat A
gen country=""
bysort A3 (A2) : replace country = "Australia" if A3 == 1 & _n == 1
bysort A3 (A2) : replace country = "Denmark" if A3 == 2 & _n == 1
bysort A3 (A2) : replace country = "Finland" if A3 == 3 & _n == 1
bysort A3 (A2) : replace country = "Hungary" if A3 == 4 & _n == 1
bysort A3 (A2) : replace country = "Scotland" if A3 == 5 & _n == 1
bysort A3 (A2) : replace country = "South Korea" if A3 == 6 & _n == 1
tostring A1 A2, replace format(%9.0f)
bysort A3 (A2) : gen time = A1+"-"+A2 if _n == 1
gen sex = "Overall" if A4 == 0
replace sex = "Males" if A4 == 1
replace sex = "Females" if A4 == 2
drop A9-A13 A17-A21
foreach var of varlist A6-A24 {
replace `var' = 100*(exp(`var')-1)
}
tostring A6-A24, replace force format(%9.2f)
gen T1 = A6 + " (" + A7 + ", " + A8 + ")"
gen T2 = A14 + " (" + A15 + ", " + A16 + ")"
gen T3 = A22 + " (" + A23 + ", " + A24 + ")"
keep country time sex T1 T2 T3
export delimited using APCs.csv, delimiter(":") novarnames replace
texdoc stlog close

/***
\color{black}

\begin{table}[h!]
  \begin{center}
    \caption{Average annual percent change in the incidence of diabetes, by country, sex, and diabetes type.}
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
      display columns/3/.style={column name=Type 1 diabetes, column type={r}, column type/.add={|}{}},
      display columns/4/.style={column name=Type 2 diabetes, column type={r}, column type/.add={|}{}},
      display columns/5/.style={column name=Uncertain diabetes type, column type={r}, column type/.add={|}{|}},
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

\clearpage
\bibliography{/Users/jed/Documents/Library.bib}
\end{document}
***/

texdoc close
