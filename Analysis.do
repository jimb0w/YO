
texdoc init ADI, replace logdir(log) gropts(optargs(width=0.8\textwidth))
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
https://github.com/jimb0w/YOT \\
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
Dianna Magliano \\
Professor and Head of Diabetes and Population Health \\
Baker Heart and Diabetes Institute, Melbourne, Australia \\

\end{titlepage}


\pagebreak
\section{Denominators by SEIFA and ARIA}

I will start with IRSD. This comes directly from the ABS website \cite{IRSD2011} from which I download the file:
\emph{Postal Area, Indexes, SEIFA 2011.xls}. From this sheet I go to Table 2, and copy and paste the data into Stata, 
then stripping to just the necessary variables:

methods are just from

\cite{CarstensenSTATMED2007}
\cite{MaglianoLDE2021}

To generate this document, the Stata package texdoc \cite{Jann2016Stata} was used, which is 
available from: \color{blue} \url{http://repec.sowi.unibe.ch/stata/texdoc/} \color{black} (accessed 14 November 2022). The 
final Stata do file and this pdf are available at: \color{blue} \url{https://github.com/jimb0w/LDL} \color{black}.

Throughout, the colour schemes used are \emph{inferno} and \emph{viridis} from the
\emph{viridis} package \cite{GarnierR2021}.

\color{Blue4}

***/



cd "/Users/jed/Documents/YOT/Data"


*Crude rates
{
import delimited "/Users/jed/Documents/Young-onset/Data/Master_data.csv", varnames(1) clear
collapse (sum) inc_t1d inc_t2d inc_uncertaint pys_nondm, by(country calendar_yr)

gen inc1 = 1000*inc_t1d/pys_nondm
gen inc2 = 1000*inc_t2d/pys_nondm
gen inc3 = 1000*inc_unc/pys_nondm

twoway ///
(line inc1 calendar if country == "Australia", color(red)) ///
(line inc2 calendar if country == "Australia", color(blue)) ///
(line inc3 calendar if country == "Australia", color(green)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "Type 1 diabetes" ///
2 "Type 2 diabetes" ///
3 "Uncertain type") ///
rows(3)) ///
graphregion(color(white)) ///
ytitle("Incidence (per 1,000 person-years)") ///
xtitle("Calendar year") ///
title("Australia", placement(west) color(gs0))

twoway ///
(line inc1 calendar if country == "Finland", color(red)) ///
(line inc2 calendar if country == "Finland", color(blue)) ///
(line inc3 calendar if country == "Finland", color(green)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "Type 1 diabetes" ///
2 "Type 2 diabetes" ///
3 "Uncertain type") ///
rows(3)) ///
graphregion(color(white)) ///
ytitle("Incidence (per 1,000 person-years)") xtitle("Calendar year")

*Crude rates by sex
import delimited "/Users/jed/Documents/Young-onset/Data/Master_data.csv", varnames(1) clear
collapse (sum) inc_t1d inc_t2d inc_uncertaint pys_nondm, by(country sex calendar_yr)

gen inc1 = 1000*inc_t1d/pys_nondm
gen inc2 = 1000*inc_t2d/pys_nondm
gen inc3 = 1000*inc_unc/pys_nondm

twoway ///
(line inc1 calendar if country == "Australia" & sex == "M", color(red)) ///
(line inc1 calendar if country == "Australia" & sex == "F", color(red) lpattern(dash)) ///
(line inc2 calendar if country == "Australia" & sex == "M", color(blue)) ///
(line inc2 calendar if country == "Australia" & sex == "F", color(blue) lpattern(dash)) ///
(line inc3 calendar if country == "Australia" & sex == "M", color(green)) ///
(line inc3 calendar if country == "Australia" & sex == "F", color(green) lpattern(dash)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "Type 1 diabetes" ///
3 "Type 2 diabetes" ///
5 "Uncertain type") ///
rows(3)) ///
graphregion(color(white)) ///
ytitle("Incidence (per 1,000 person-years)") ///
xtitle("Calendar year") ///
title("Australia", placement(west) color(gs0))

twoway ///
(line inc1 calendar if country == "Finland" & sex == "M", color(red)) ///
(line inc1 calendar if country == "Finland" & sex == "F", color(red) lpattern(dash)) ///
(line inc2 calendar if country == "Finland" & sex == "M", color(blue)) ///
(line inc2 calendar if country == "Finland" & sex == "F", color(blue) lpattern(dash)) ///
(line inc3 calendar if country == "Finland" & sex == "M", color(green)) ///
(line inc3 calendar if country == "Finland" & sex == "F", color(green) lpattern(dash)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(1 "Type 1 diabetes" ///
2 "Type 2 diabetes" ///
3 "Uncertain type") ///
rows(3)) ///
graphregion(color(white)) ///
ytitle("Incidence (per 1,000 person-years)") xtitle("Calendar year")
}



*Euro std pop in single year ages
{
import delimited "/Users/jed/Documents/Young-onset/Data/Master_data.csv", varnames(1) clear
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

twoway ///
(scatter esp2010 age) ///
(line A age) ///
, legend(off) graphregion(color(white)) ///
ylabel(1200000(100000)1500000, format(%9.0fc)) ///
ytitle("Population") xtitle("Age")

*Or as proportions
su(esp2010)
gen esp2010prop = esp2010/r(sum)
su(A)
gen B = A/r(sum)

twoway ///
(bar esp2010prop age, color(gs9%50)) ///
(bar B age, color(red%50)) ///
, legend(off) graphregion(color(white)) ///
ytitle("Population proportion") xtitle("Age")

keep age B
replace age = age-0.5
save refpop, replace

}



*Single join point to M in 2013
{
import delimited "/Users/jed/Documents/Young-onset/Data/Master_data.csv", varnames(1) clear
collapse (sum) inc_t2d pys_nondm, by(country sex calendar_yr)
keep if sex == "M" & country == "Australia"
mkspline time1 2013 time2 = calendar
poisson inc_t2d time1 time2, exposure(pys)
matrix list r(table)
di 100*(exp(r(table)[1,1])-1)
di 100*(exp(r(table)[1,2])-1)
predict A, ir

gen inc2 = inc_t2d/pys_nondm

twoway ///
(scatter inc2 A calendar)
*Interesting, but not going to pursue yet. 
}


*APC-models
{

foreach i in Australia Finland {
foreach ii in M F {
foreach iii in inc_t1d inc_t2d inc_uncertaint {

import delimited "/Users/jed/Documents/Young-onset/Data/Master_data.csv", varnames(1) clear
keep if country == "`i'" & sex == "`ii'"

rename age_gp age
replace age = substr(age,1,2)
destring age, replace
replace age = age+2.5

gen coh = calendar-age

mkspline agesp = age, cubic knots(16(8)40)
mkspline timesp = calendar, cubic knots(2002(4)2016)
mkspline cohsp = coh, cubic knots(1970(10)2000)

poisson `iii' agesp* timesp* cohsp*, exposure(pys)

keep age calendar pys
expand 5
replace pys=pys/5
bysort cal age : replace age = age+_n-3.5
sort age cal
gen coh = calendar-age
mkspline agesp = age, cubic knots(16(8)40)
mkspline timesp = calendar, cubic knots(2002(4)2016)
mkspline cohsp = coh, cubic knots(1970(10)2000)

predict _Rate, ir
predict errr, stdp
predict _D
replace _Rate = _Rate*1000
gen lb = exp(ln(_Rate)-1.96*errr)
gen ub = exp(ln(_Rate)+1.96*errr)

gen country = "`i'"
gen sex = "`ii'"
gen OC = "`iii'"

save APC_Rate_`i'_`ii'_`iii', replace

*Standardize
replace _D = round(_D,1)
gen B = round(pys_nondm,1)
dstdize _D B age, by(cal) using(refpop)
matrix A = 1000*(r(adj)\r(lb_adj)\r(ub_adj))'
clear 
svmat A
gen calendar = r(c1)
replace calendar = substr(cal,3,4)
destring calendar, replace
replace calendar = calendar+_n-1
gen country = "`i'"
gen sex = "`ii'"
gen OC = "`iii'"
save APC_StdzRate_`i'_`ii'_`iii', replace

}
}
}

}


*Plots

*Age-standardized
{
clear
foreach i in Australia Finland {
foreach ii in M F {
append using APC_StdzRate_`i'_`ii'_inc_t1d
}
}

*STack graphs

twoway ///
(rarea A3 A2 calendar if country == "Australia" & sex == "M", color("blue%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "Australia" & sex == "M", color(blue) lpattern(solid)) ///
(rarea A3 A2 calendar if country == "Australia" & sex == "F", color("blue%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "Australia" & sex == "F", color(blue) lpattern(dash)) ///
(rarea A3 A2 calendar if country == "Finland" & sex == "M", color("red%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "Finland" & sex == "M", color(red) lpattern(solid)) ///
(rarea A3 A2 calendar if country == "Finland" & sex == "F", color("red%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "Finland" & sex == "F", color(red) lpattern(dash)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "Australia" ///
6 "Finland") ///
cols(1)) ///
graphregion(color(white)) ///
yscale(range(0 0.8)) ///
ylabel(0(0.1)0.8, format(%9.1f) nogrid angle(0)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence (per 1,000 person-years)") ///
xtitle("Calendar year") ///
title("Type 1 diabetes", placement(west) color(black) size(medium))
graph save "Graph" Dragonforce_1, replace


clear
foreach i in Australia Finland {
foreach ii in M F {
append using APC_StdzRate_`i'_`ii'_inc_t2d
}
}


twoway ///
(rarea A3 A2 calendar if country == "Australia" & sex == "M", color("blue%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "Australia" & sex == "M", color(blue) lpattern(solid)) ///
(rarea A3 A2 calendar if country == "Australia" & sex == "F", color("blue%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "Australia" & sex == "F", color(blue) lpattern(dash)) ///
(rarea A3 A2 calendar if country == "Finland" & sex == "M", color("red%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "Finland" & sex == "M", color(red) lpattern(solid)) ///
(rarea A3 A2 calendar if country == "Finland" & sex == "F", color("red%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "Finland" & sex == "F", color(red) lpattern(dash)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "Australia" ///
6 "Finland") ///
cols(1)) ///
graphregion(color(white)) ///
yscale(range(0 0.8)) ///
ylabel(0(0.1)0.8, format(%9.1f) nogrid angle(0)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence (per 1,000 person-years)") ///
xtitle("Calendar year") ///
title("Type 2 diabetes", placement(west) color(black) size(medium))
graph save "Graph" Dragonforce_2, replace



clear
foreach i in Australia Finland {
foreach ii in M F {
append using APC_StdzRate_`i'_`ii'_inc_uncertaint
}
}


twoway ///
(rarea A3 A2 calendar if country == "Australia" & sex == "M", color("blue%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "Australia" & sex == "M", color(blue) lpattern(solid)) ///
(rarea A3 A2 calendar if country == "Australia" & sex == "F", color("blue%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "Australia" & sex == "F", color(blue) lpattern(dash)) ///
(rarea A3 A2 calendar if country == "Finland" & sex == "M", color("red%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "Finland" & sex == "M", color(red) lpattern(solid)) ///
(rarea A3 A2 calendar if country == "Finland" & sex == "F", color("red%30") fintensity(inten80) lwidth(none)) ///
(line A1 calendar if country == "Finland" & sex == "F", color(red) lpattern(dash)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "Australia" ///
6 "Finland") ///
cols(1)) ///
graphregion(color(white)) ///
yscale(range(0 0.8)) ///
ylabel(0(0.1)0.8, format(%9.1f) nogrid angle(0)) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence (per 1,000 person-years)") ///
xtitle("Calendar year") ///
title("Uncertain diabetes type", placement(west) color(black) size(medium))
graph save "Graph" Dragonforce_3, replace



graph combine ///
Dragonforce_1.gph ///
Dragonforce_2.gph ///
Dragonforce_3.gph ///
, iscale(0.7) rows(3) xsize(2) graphregion(color(white))
graph export STDZ.pdf, as(pdf) name("Graph") replace




}


*Age-specific
{

*Do a country loop

forval a = 1/6 {
if `a' == 1 {
local i = "Australia"
local ii = "inc_t1d"
local j = "Type 1 diabetes"
}
if `a' == 2 {
local i = "Australia"
local ii = "inc_t2d"
local j = "Type 2 diabetes"
}
if `a' == 3 {
local i = "Australia"
local ii = "inc_uncertaint"
local j = "Uncertain diabetes type"
}
if `a' == 4 {
local i = "Finland"
local ii = "inc_t1d"
local j = "Type 1 diabetes"
}
if `a' == 5 {
local i = "Finland"
local ii = "inc_t2d"
local j = "Type 2 diabetes"
}
if `a' == 6 {
local i = "Finland"
local ii = "inc_uncertaint"
local j = "Uncertain diabetes type"
}


use APC_Rate_`i'_M_`ii', clear

twoway ///
(rarea ub lb calendar if age == 15, color("0 0 90%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 15, color("0 0 90") lpattern(solid)) ///
(rarea ub lb calendar if age == 20, color("0 60 120%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 20, color("0 60 120") lpattern(solid)) ///
(rarea ub lb calendar if age == 25, color("0 100 150%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 25, color("0 100 150") lpattern(solid)) ///
(rarea ub lb calendar if age == 30, color("0 140 180%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 30, color("0 140 180") lpattern(solid)) ///
(rarea ub lb calendar if age == 35, color("0 180 210%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 35, color("0 180 210") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "15" ///
4 "20" ///
6 "25" ///
8 "30" ///
10 "35") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.5 1.0 2.0, format(%9.3f) nogrid angle(0)) ///
yscale(range(0.0015 2.05) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`i' - Males - `j'", placement(west) color(black) size(medium))
graph save "Graph" Escape_`i'_M_`ii', replace



use APC_Rate_`i'_F_`ii', clear

twoway ///
(rarea ub lb calendar if age == 15, color("90 0 20%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 15, color("90 0 20") lpattern(solid)) ///
(rarea ub lb calendar if age == 20, color("130 0 40%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 20, color("130 0 40") lpattern(solid)) ///
(rarea ub lb calendar if age == 25, color("170 0 60%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 25, color("170 0 60") lpattern(solid)) ///
(rarea ub lb calendar if age == 30, color("210 0 80%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 30, color("210 0 80") lpattern(solid)) ///
(rarea ub lb calendar if age == 35, color("250 0 100%30") fintensity(inten80) lwidth(none)) ///
(line _Rate calendar if age == 35, color("250 0 100") lpattern(solid)) ///
, legend(symxsize(0.13cm) position(3) region(lcolor(white) color(none)) ///
order(2 "15" ///
4 "20" ///
6 "25" ///
8 "30" ///
10 "35") ///
cols(1)) ///
graphregion(color(white)) ///
ylabel(0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.5 1.0 2.0, format(%9.3f) nogrid angle(0)) ///
yscale(range(0.0015 2.05) log) ///
xscale(range(2000 2020)) ///
xlabel(2000(5)2020, nogrid) ///
ytitle("Incidence (per 1,000 person-years)", margin(a+2)) ///
xtitle("Calendar year") ///
title("`i' - Females - `j'", placement(west) color(black) size(medium))
graph save "Graph" Escape_`i'_F_`ii', replace

}

foreach i in Australia Finland {

graph combine ///
Escape_`i'_M_inc_t1d.gph ///
Escape_`i'_F_inc_t1d.gph ///
Escape_`i'_M_inc_t2d.gph ///
Escape_`i'_F_inc_t2d.gph ///
Escape_`i'_M_inc_uncertaint.gph ///
Escape_`i'_F_inc_uncertaint.gph ///
, iscale(0.4) rows(3) xsize(3.5) graphregion(color(white))
graph export AGE_`i'.pdf, as(pdf) name("Graph") replace


}

}



/***
\color{black}
\clearpage
\bibliography{/Users/jed/Documents/YO/lib.bib}
\end{document}

***/

texdoc close
