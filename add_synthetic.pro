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
postplot=postplot

;PURPOSE: To restore the kepler data, add a synthetic
;	transit signal, save the result to a FITS file and
;	optionally plot the synthetic LC. 
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
;
;OPTIONAL OUTPUT:
;	output: the normalized lightcurve
;
; c. 2010.09.06 ~MJG
; 2014.07.10 ~MJG heavily modified to work with latest lightcurves

REARTH = 6.371d6 ;meters
loadct, 39, /silent
plotdir = '/raw/kepler/synplots/'

res = readKeplerLC(fname=fname, header=header, head0=head0)
nelres = n_elements(res)
print, '# el in res is: ', nelres

rpl_init = rpl
rst = sxpar(head0, 'RADIUS')
print, 'rst is: ', rst
stop
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


bnndout = dblarr(nelres)
;this will bin the gen_synthetic output to be the same 
;length as the 20 minute kepler observations:
for i=0LL, nelres-1d do begin
bnndout[i] = total(output[i*30d: (i*30d + 29d)])
endfor

;now to normalize:
bnndout /= max(bnndout)

if keyword_set(postplot) then begin
postnamesyn = nextnameeps(plotdir+'synthetics', /nosuf)
ps_open, postnamesyn, /encaps
endif
plot, res.time, bnndout, $
xtitle='Time', $
ytitle='Normalized Flux', /yst, $
yra=[min(bnndout)^2d, 1], ps=8
if keyword_set(postplot) then begin
ps_close
endif
;stop

kepflux = res.pdcsap_flux
normkepflux = kepflux/max(kepflux)

if keyword_set(postplot) then begin
postname = nextnameeps(plotdir+'syntheticsorig', /nosuf)
ps_open, postname, /encaps
endif

timearr = res.time - min(res.time)
plot, timearr, normkepflux, ps=8, $
xtitle = 'Days from Beginning of Quarter', $
ytitle = ' Normalized Flux', /yst, yra=[0.999*min(normkepflux), 1.001d], symsize=0.25, /xsty

normerr = res.pdcsap_flux_err/max(kepflux)
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
!p.charthick=1
!p.thick=1

if keyword_set(postplot) then begin
!p.charthick=3
!p.thick=3
postname = nextnameeps(plotdir+'syntheticssig', /nosuf)
ps_open, postname, /encaps
endif

timearr = res.time - min(res.time)
plot, timearr, normkepflux, ps=8, $
xtitle = 'Days from Beginning of Quarter', $
ytitle = ' Normalized Flux', /yst, yra=[0.999*min(normkepflux), 1.001d], symsize=0.25
;oploterr, timearr, normkepflux, normerr, 3
errplot, timearr, normkepflux - normerr, $
normkepflux + normerr, color=200
oplot, timearr, normkepflux, ps=8
xyouts, 0.2, 0.14, 'period (days)= '+ $
strt(per*29.426d/30d, f='(F8.2)'), /norm
xyouts, 0.2, 0.17, 'radius (in R_earth): '+ $
strt(rpl/REARTH, f='(F4.1)'), /norm

if keyword_set(postplot) then begin
ps_close
endif


head0o = head0
h0el = n_elements(head0)
head0 = [head0o[0:(h0el - 2)], $
head0o[h0el-1]]

;filename with no directory:
fnamesplit = strsplit(fname, '/', /extract)
fnamend = fnamesplit[-1]
print, fnamend
fnamenofits = strmid(fnamend, 0, strlen(fnamend)-5)
fdir = '/raw/kepler/synthetics/'
fitsnm = fdir+fnamenofits+'_syn.fits'

fxaddpar, head0, 'SYNTHTIC', 'TRUE', 'A synthetic planet has been added'
fxaddpar, head0, 'PLRAD', strt(rpl_init, f='(F8.3)'), 'Synthetic planet radius (R_EARTH)'
fxaddpar, head0, 'PLPER', strt(per, f='(F10.3)'), 'Synthetic planet period (days)'
fxaddpar, head0, 'PLPHASE', strt(phase, f='(F10.4)'), 'Transit phase'
fxaddpar, head0, 'TRANELS', '5:10', 'Pixels with 1st transit event'
				
mwrfits, res0, fitsnm, head0, /create
mwrfits, synth_struct, fitsnm, header

end add_synthetic.pro