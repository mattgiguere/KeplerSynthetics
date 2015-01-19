;+
;
;  NAME: 
;     unitTests14B
;
;  PURPOSE: 
;   
;
;  CATEGORY:
;      UTILITIES
;
;  CALLING SEQUENCE:
;
;      unitTests14B
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
;      unitTests14B
;
;  MODIFICATION HISTORY:
;        c. Matt Giguere 2014.09.29 17:23:29
;
;-
pro unitTests14B, $
help = help, $
postplot = postplot

angstrom = '!6!sA!r!u!9 %!6!n'
!p.color=0
!p.background=255
loadct, 39, /silent
usersymbol, 'circle', /fill, size_of_sym = 0.5

rsun = 6.955d8

readcol, 'tests14B.dat', $
kepid, $
filenm, $
ijnk, jjnk, kjnk, ljnk, $
per_d, $
rpl_e, $
rstarr, $
kepmag, $
	format='L, A, L, L, L, L, D, D, D, D', delim=' ', skipline=1



;stop
for i=0, n_elements(per_d)-1 do begin
	print, '*****************************************'
	print, 'Element ', i, ' of ', n_elements(per_d), '. ', $
		strt(i/n_elements(per_d)*1d2, f='(F6.2)'), '% complete.'
	print, '*****************************************'
	rst = rstarr[i]
	print, 'R star input: ', rst
	
	add_synthetic, fname=filenm[i], $
	rpl=rpl_e[i], per=per_d[i], $
	rst=rst, postplot=postplot
	
	print, 'R star returned is: ', rst
	rstarr[i] = rst
endfor

for i=0, n_elements(phase)-1 do begin
	print, filenm[i], rpl_e[i], per_d[i], phase[i], rstarr[i]/rsun
endfor

stop
end;unitTests14B.pro