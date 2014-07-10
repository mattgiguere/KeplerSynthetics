;+
;
;  NAME: 
;     phExampleSynthetics
;
;  PURPOSE: To generate ten example synthetics for Stewart to play with
;		and test out in planethunters.
;
;  CATEGORY:
;      PLANETHUNTERS
;
;  CALLING SEQUENCE:
;      phExampleSynthetics
;
;  INPUTS:
;
;  OPTIONAL INPUTS:
;
;  OUTPUTS:
;
;  OPTIONAL OUTPUTS:
;
;  KEYWORD PARAMETERS:
;    
;  EXAMPLE:
;      phExampleSynthetics
;
;  MODIFICATION HISTORY:
;        c. Matt Giguere 2014.07.14 10:35:12
;
;-
pro phExampleSynthetics, $
postplot=postplot

angstrom = '!6!sA!r!u!9 %!6!n'
!p.color=0
!p.background=255
loadct, 39, /silent
usersymbol, 'circle', /fill, size_of_sym = 0.5

rsun = 6.955d8
;filenm: the FITS Kepler filename of the lightcurve to use
;rpl_e: the radius of the planet [in R_Earth]
;per_d: the orbital period [in days]
;phase: the phase of the orbit
readcol, 'phexample.csv', filenm, rpl_e, per_d, phase, format='A, D, D, D', delim=','

;printt, filenm

firstfour = strmid(filenm, 4, 4)
;printt, firstfour

kic = strmid(filenm, 4, 9)
;printt, kic

filedir = '/raw/kepler/lightcurves/'+firstfour+'/'+kic+'/'
;printt, filedir+filenm

rstarr = dblarr(n_elements(filenm))

for i=0, n_elements(per_d)-1 do begin
	add_synthetic, fname=filedir[i]+filenm[i], $
	rpl=rpl_e[i], per=per_d[i], phase=phase[i], $
	rst=rst, postplot=postplot
	
	print, 'R star returned is: ', rst
	rstarr[i] = rst
	
endfor

for i=0, n_elements(phase)-1 do begin
	print, filenm[i], rpl_e[i], per_d[i], phase[i], rstarr[i]/rsun
endfor
stop
end;phExampleSynthetics.pro