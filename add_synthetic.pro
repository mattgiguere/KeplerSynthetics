pro add_synthetic, $
fname=fname, $
rpl=rpl, $
rst=rst, $
per=per, $
inc=inc, $
mpl=mpl, $
mst=mst, $
phase=phase, $
hd209458=hd209458, $
output=output, $
timebaseline=timebaseline, $
postplot=postplot, $
dontstop=dontstop

;PURPOSE: To restore the kepler data, add a synthetic
;	transit signal, and plot the result. 
;
;INPUT:
;	fname: the filename
;	Rpl: the radius of the planet (in Earth radii)
;	Rst: the radius of the star (in solar radii)
;	PER: the orbital period (in days)
;	INC: the orbital inclination (in degrees)
;	Mpl: the mass of the planet (in earth masses)
;	Mst: the mass of the star (in solar masses)
;	timebaseline: The timebaseline of the Kepler
;		data to calculate the synthetic lightcurve for
;
;OPTIONAL INPUT:
;	phase: changes the start point of the curve (0 - 1)
;	hd209458: uses this system to test the output values
;	postplot: generate eps and png files of the LOSC
;		and BLS periodograms that go in the /exolib/kepler
;		directory.
;  dontstop: use this keyword if you want to do some
;		overplotting calling from an external procedure
;
;OPTIONAL OUTPUT:
;	output: the normalized lightcurve
;
; c. 2010.09.06 ~MJG

;ps_open, 'kep_syns', /encaps
;!p.multi=[0,2,2]

REARTH = 6.371d6 ;meters

;2 earth
if ~keyword_set(fname) then fname='kplr006508291-2009166043257_llc.fits'
if ~keyword_set(dontstop) then dontstop = 0d
;1 earth
;if ~keyword_set(fname) then fname='kplr004753224-2009166043257_llc.fits'
;4 earth
;if ~keyword_set(fname) then fname='kplr006224313-2009166043257_llc.fits'

res = read_kepler(fname=fname, header=header)
nelres = n_elements(res)
print, '# el in res is: ', nelres

rst = sxpar(header, 'RADIUS')
print, 'rst is: ', rst
;stop
timebaseline=nelres*30d

;Generate the synthetic transit using GEN_SYNTHETIC.PRO:
gen_synthetic, $
rpl=rpl, $
rst=rst, $
per=per, $
inc=inc, $
mpl=mpl, $
mst=mst, $
phase=phase, $
hd209458=hd209458, $
output=output, $
timebaseline=timebaseline


;stop

bnndout = dblarr(nelres)
;this will bin the gen_synthetic output to be the same 
;length as the 20 minute kepler observations:
for i=0LL, nelres-1d do begin
bnndout[i] = total(output[i*30d: (i*30d + 29d)])
endfor

;now to normalize:
bnndout /= max(bnndout)

if keyword_set(postplot) then begin
postnamesyn = nextnameeps('synthetics', /nosuf)
ps_open, postnamesyn, /encaps
endif
plot, res.barytime, bnndout, $
xtitle='Barytime', $
ytitle='Normalized Flux', /yst, $
yra=[min(bnndout)^2d, 1], ps=8
if keyword_set(postplot) then begin
ps_close
endif

kepflux = res.ap_corr_flux
normkepflux = kepflux/max(kepflux)

if keyword_set(postplot) then begin
postname = nextnameeps('syntheticsorig', /nosuf)
ps_open, postname, /encaps
endif

timearr = res.barytime - min(res.barytime)
plot, timearr, normkepflux, ps=8, $
xtitle = 'Days from Beginning of Quarter', $
ytitle = ' Normalized Flux', /yst, yra=[0.999*min(normkepflux), 1.001d], symsize=0.25

normerr = res.ap_corr_err/max(kepflux)
;oploterr, timearr, normkepflux, normerr, 3
errplot, timearr, normkepflux - normerr, $
normkepflux + normerr, color=200

oplot, timearr, normkepflux, ps=8

if keyword_set(postplot) then begin
ps_close
endif

kepflux *= bnndout

normkepflux = kepflux/median(kepflux)

;stop
!p.charthick=3
!p.thick=3

if keyword_set(postplot) then begin
postname = nextnameeps('syntheticssig', /nosuf)
ps_open, postname, /encaps
endif

timearr = res.barytime - min(res.barytime)
plot, timearr, normkepflux, ps=8, $
xtitle = 'Days from Beginning of Quarter', $
ytitle = ' Normalized Flux', /yst, yra=[0.999*min(normkepflux), 1.001d], symsize=0.25
;oploterr, timearr, normkepflux, normerr, 3
errplot, timearr, normkepflux - normerr, $
normkepflux + normerr, color=200
oplot, timearr, normkepflux, ps=8
xyouts, 0.2, 0.14, 'period (days)= '+ $
strt(per*29.426d/30d, f='(F4.1)'), /norm
xyouts, 0.2, 0.17, 'radius (in R_earth): '+ $
strt(rpl/REARTH, f='(F4.1)'), /norm

if keyword_set(postplot) then begin
ps_close
endif

keplerBLS, timearr=timearr, fluxarr=normkepflux, $
postplot=postplot, filename=fname


;save, filename='kepler4earth.dat', timearr, normkepflux, normerr

binkepler, timearr, normkepflux, newspline

if keyword_set(postplot) then begin
postname = nextnameeps('syntheticspline', /nosuf)
ps_open, postname, /encaps
endif

plot, timearr, newspline, ps=8, $
xtitle='Days from Beginning of Quarter', $
ytitle='Normalized Flux'
errplot, timearr, newspline - normerr, newspline + normerr, color=200
oplot, timearr, newspline, ps=8

if keyword_set(postplot) then begin
ps_close
endif

window, /free
keplerBLS, timearr=timearr, fluxarr=newspline, $
postplot=postplot, filename=fname


if keyword_set(postplot) then begin
postname = nextnameeps('syntheticlosc', /nosuf)
ps_open, postname, /encaps
endif

cf = create_struct('jd', timearr, 'mnvel', kepflux)
pergram, cf, nu_out, peri_out, lowper=0.04d, /noplot
title='Lomb Scargle Periodogram';of '+knum
yra = [-0.01,1.2*max(peri_out)]
xra = [0.8*min(1./nu_out),1.01*max(1./nu_out)]
plot,(1./nu_out),peri_out,xtitl='!6 Period (d)', $
/xlog,yr=yra,xr=xra, $
/xsty,/ysty,titl='!6'+title,ytitl='!6 Power'

if keyword_set(postplot) then begin
ps_close
endif

stop
end add_synthetic.pro