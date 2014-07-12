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
RSUN = 6.955d8 ;meters

loadct, 39, /silent
plotdir = '/raw/kepler/synplots/'

res = readKeplerLC(fname=fname, header=header, head0=head0, /noplot)
nelres = n_elements(res)
print, '# el in res is: ', nelres

rpl_init = rpl
rst = sxpar(head0, 'RADIUS')
print, 'rst is: ', rst
rndmamp = max(res.time) - min(res.time) - 30d
starttime = rndmamp * randomu(seed)
startel = where(res.time gt starttime + min(res.time))
startel = startel[0]
endel = where(res.time ge res[startel].time + 30d)
endel = endel[0]
;figure out the timebaseline (in minutes) to feed to gen_synthetic:
timebaseline= (res[endel].time - res[startel].time)*24d * 60d

;now chop the "res" structure for the remainder of this program:
res = res[startel:endel]
nelres = n_elements(res)

;the time (in minutes) between observations:
timestep = (max(res.time) - min(res.time))/nelres * 24d * 60d

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


nbnndout = dblarr(nelres)
;this will bin the gen_synthetic output to be the same 
;length as the ~29.4 minute kepler observations:
for i=0LL, nelres-1d do nbnndout[i] = total(output[floor(i*timestep): floor((i+1)*timestep)-1L])/(floor((i+1)*timestep) - floor(i*timestep))

;now to list the spots where the transit occurs:
lowspots = where(nbnndout lt 1d)
beglow = lowspots[0]

;find the final element of the 1st transit:
il = 1
while (il lt n_elements(lowspots)-1) and (lowspots[il]-1L eq lowspots[il-1]) do begin
il++
endwhile
print, 'lowspots[il]: ', lowspots[il]
print, 'lowspots[il-1L]: ', lowspots[il-1L]
endlow = lowspots[il-1L]

if keyword_set(postplot) then begin
	!p.charthick=3
	!p.thick=3
	postnamesyn = nextnameeps(plotdir+'JustSynthetics', /nosuf)
	ps_open, postnamesyn, /encaps, /col
endif
plot, res.time, nbnndout, $
xtitle='Time', /xsty, $
ytitle='Normalized Flux', /yst, $
yra=[min(nbnndout)^2d, 1], ps=8

oplot, res[lowspots].time, nbnndout[lowspots], ps=8, col=250
if keyword_set(postplot) then begin
	ps_close
endif

kepflux = res.pdcsap_flux
normkepflux = kepflux/max(kepflux)

if keyword_set(postplot) then begin
	postname = nextnameeps(plotdir+'JustLC', /nosuf)
	ps_open, postname, /encaps, /color
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

kepflux *= nbnndout

normkepflux = kepflux/median(kepflux)

;stop
!p.charthick=1
!p.thick=1

if keyword_set(postplot) then begin
	postname = nextnameeps(plotdir+'SyntheticsAndLC', /nosuf)
	ps_open, postname, /encaps, /color
endif

timearr = res.time - min(res.time)
plot, timearr, normkepflux, ps=8, /xsty, $
xtitle = 'Days from Beginning of Quarter', $
ytitle = ' Normalized Flux', /yst, yra=[0.999*min(normkepflux), 1.001d*max(normkepflux)], symsize=0.25
;oploterr, timearr, normkepflux, normerr, 3
oploterr, timearr, normkepflux, normerr, 8
oplot, timearr, normkepflux, ps=8

xyouts, 0.2, 0.2, 'R_st (in R_sun): '+ $
strt(rst/rsun, f='(F5.2)'), /norm

xyouts, 0.2, 0.17, 'radius_pl (in R_earth): '+ $
strt(rpl/REARTH, f='(F4.1)'), /norm

xyouts, 0.2, 0.14, 'period (days): '+ $
strt(per, f='(F8.2)'), /norm

xyouts, 0.2, 0.11, 'phase: '+ $
strt(phase, f='(F8.2)'), /norm


oplot, timearr[lowspots], normkepflux[lowspots], ps=8, col=250

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
fxaddpar, head0, 'TRANELS', strt(beglow)+':'+strt(endlow), 'Elements with 1st transit event'
				
mwrfits, res0, fitsnm, head0, /create
mwrfits, synth_struct, fitsnm, header

end add_synthetic.pro